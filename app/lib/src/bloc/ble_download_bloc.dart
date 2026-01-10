import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:libdivecomputer/libdivecomputer.dart' as dc;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'ble_scan_bloc.dart';
import 'divelist_bloc.dart';
import 'sync_bloc.dart';

final _log = Logger('ble_download_bloc.dart');

// Events
sealed class BleDownloadEvent extends Equatable {
  const BleDownloadEvent();

  /// Connect to a scanned device. User will select descriptor afterwards.
  const factory BleDownloadEvent.connectToDevice(BluetoothDevice device) = _ConnectToDevice;

  /// Connect to a remembered computer and auto-start download.
  const factory BleDownloadEvent.connectToRemembered(Computer computer, dc.ComputerDescriptor descriptor) = _ConnectToRemembered;

  /// Start downloading with the selected computer descriptor.
  const factory BleDownloadEvent.start(dc.ComputerDescriptor computer) = _Start;

  /// Disconnect from the current device.
  const factory BleDownloadEvent.disconnect() = _Disconnect;

  @override
  List<Object?> get props => [];
}

class _ConnectToDevice extends BleDownloadEvent {
  final BluetoothDevice device;

  const _ConnectToDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class _ConnectToRemembered extends BleDownloadEvent {
  final Computer computer;
  final dc.ComputerDescriptor descriptor;

  const _ConnectToRemembered(this.computer, this.descriptor);

  @override
  List<Object?> get props => [computer, descriptor];
}

class _Start extends BleDownloadEvent {
  final dc.ComputerDescriptor computer;

  const _Start(this.computer);

  @override
  List<Object?> get props => [computer];
}

class _Disconnect extends BleDownloadEvent {
  const _Disconnect();
}

class _ConnectionStateChanged extends BleDownloadEvent {
  final BluetoothConnectionState connectionState;

  const _ConnectionStateChanged(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}

class _ServicesDiscovered extends BleDownloadEvent {
  final List<BluetoothService> services;

  const _ServicesDiscovered(this.services);

  @override
  List<Object?> get props => [services];
}

class _Progress extends BleDownloadEvent {
  final dc.DownloadProgress progress;

  const _Progress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class _DiveReceived extends BleDownloadEvent {
  final Dive dive;

  const _DiveReceived(this.dive);

  @override
  List<Object?> get props => [dive];
}

class _Completed extends BleDownloadEvent {
  const _Completed();
}

class _Failed extends BleDownloadEvent {
  final String error;

  const _Failed(this.error);

  @override
  List<Object?> get props => [error];
}

// State
class BleDownloadState extends Equatable {
  final BluetoothDevice? connectedDevice;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> discoveredServices;
  final bool isDiscoveringServices;
  final bool isDownloading;
  final dc.DownloadProgress? downloadProgress;
  final List<Dive> downloadedDives;
  final String? error;

  /// If connecting to a remembered computer, auto-start with this descriptor
  final dc.ComputerDescriptor? autoStartDescriptor;

  const BleDownloadState({
    this.connectedDevice,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.discoveredServices = const [],
    this.isDiscoveringServices = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.downloadedDives = const [],
    this.error,
    this.autoStartDescriptor,
  });

  bool get isConnected => connectionState == BluetoothConnectionState.connected;
  bool get isReadyToDownload => isConnected && discoveredServices.isNotEmpty && !isDownloading;

  BleDownloadState copyWith({
    BluetoothDevice? connectedDevice,
    bool clearConnectedDevice = false,
    BluetoothConnectionState? connectionState,
    List<BluetoothService>? discoveredServices,
    bool? isDiscoveringServices,
    bool? isDownloading,
    dc.DownloadProgress? downloadProgress,
    bool clearDownloadProgress = false,
    List<Dive>? downloadedDives,
    String? error,
    bool clearError = false,
    dc.ComputerDescriptor? autoStartDescriptor,
    bool clearAutoStartDescriptor = false,
  }) {
    return BleDownloadState(
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      connectionState: connectionState ?? this.connectionState,
      discoveredServices: discoveredServices ?? this.discoveredServices,
      isDiscoveringServices: isDiscoveringServices ?? this.isDiscoveringServices,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: clearDownloadProgress ? null : (downloadProgress ?? this.downloadProgress),
      downloadedDives: downloadedDives ?? this.downloadedDives,
      error: clearError ? null : (error ?? this.error),
      autoStartDescriptor: clearAutoStartDescriptor ? null : (autoStartDescriptor ?? this.autoStartDescriptor),
    );
  }

  @override
  List<Object?> get props => [
    connectedDevice,
    connectionState,
    discoveredServices,
    isDiscoveringServices,
    isDownloading,
    downloadProgress,
    downloadedDives,
    error,
    autoStartDescriptor,
  ];
}

// Bloc
class BleDownloadBloc extends Bloc<BleDownloadEvent, BleDownloadState> {
  final DiveListBloc _diveListBloc;
  final SyncBloc _syncBloc;
  final BleScanBloc _scanBloc;
  late final Store _store;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  BleDownloadBloc(this._diveListBloc, this._syncBloc, this._scanBloc) : super(const BleDownloadState()) {
    on<BleDownloadEvent>(_onEvent, transformer: sequential());

    _syncBloc.store.then((store) {
      _store = store;
    });
  }

  Future<void> _onEvent(BleDownloadEvent event, Emitter<BleDownloadState> emit) async {
    switch (event) {
      case _ConnectToDevice(:final device):
        await _onConnectToDevice(device, null, emit);
      case _ConnectToRemembered(:final computer, :final descriptor):
        await _onConnectToRemembered(computer, descriptor, emit);
      case _ConnectionStateChanged(:final connectionState):
        _onConnectionStateChanged(connectionState, emit);
      case _ServicesDiscovered(:final services):
        await _onServicesDiscovered(services, emit);
      case _Start(:final computer):
        await _onStartDownload(computer, emit);
      case _Progress(:final progress):
        emit(state.copyWith(downloadProgress: progress));
      case _DiveReceived(:final dive):
        emit(state.copyWith(downloadedDives: state.downloadedDives + [dive]));
      case _Completed():
        _onDownloadCompleted(emit);
      case _Failed(:final error):
        emit(state.copyWith(isDownloading: false, clearDownloadProgress: true, error: error));
      case _Disconnect():
        await _onDisconnect(emit);
    }
  }

  Future<void> _onConnectToDevice(BluetoothDevice device, dc.ComputerDescriptor? autoStart, Emitter<BleDownloadState> emit) async {
    // Stop scanning first
    await _scanBloc.stopScanningForDownload();

    emit(state.copyWith(clearError: true, autoStartDescriptor: autoStart, clearAutoStartDescriptor: autoStart == null));

    await _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen((connectionState) {
      add(_ConnectionStateChanged(connectionState));
    });

    try {
      await device.connect(license: License.free, timeout: const Duration(seconds: 15));
      emit(state.copyWith(connectedDevice: device, isDiscoveringServices: true));
      final services = await device.discoverServices();
      add(_ServicesDiscovered(services));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to connect: $e'));
    }
  }

  Future<void> _onConnectToRemembered(Computer computer, dc.ComputerDescriptor descriptor, Emitter<BleDownloadState> emit) async {
    final device = BluetoothDevice.fromId(computer.remoteId);
    await _onConnectToDevice(device, descriptor, emit);
  }

  void _onConnectionStateChanged(BluetoothConnectionState connectionState, Emitter<BleDownloadState> emit) {
    if (connectionState == BluetoothConnectionState.disconnected && state.connectionState == BluetoothConnectionState.connected) {
      emit(state.copyWith(
        connectionState: connectionState,
        clearConnectedDevice: true,
        discoveredServices: [],
        isDiscoveringServices: false,
        clearAutoStartDescriptor: true,
      ));
    } else {
      emit(state.copyWith(connectionState: connectionState));
    }
  }

  Future<void> _onServicesDiscovered(List<BluetoothService> services, Emitter<BleDownloadState> emit) async {
    emit(state.copyWith(discoveredServices: services, isDiscoveringServices: false));

    // Auto-start download if we have a descriptor (from remembered computer)
    final autoStart = state.autoStartDescriptor;
    if (autoStart != null) {
      add(BleDownloadEvent.start(autoStart));
    }
  }

  Future<void> _onStartDownload(dc.ComputerDescriptor computer, Emitter<BleDownloadState> emit) async {
    final device = state.connectedDevice;
    if (device == null) return;

    if (state.discoveredServices.isEmpty) {
      emit(state.copyWith(error: 'No services discovered'));
      return;
    }

    final charPair = findBleCharacteristics(state.discoveredServices);
    if (charPair == null) {
      emit(state.copyWith(error: 'No suitable BLE characteristics found'));
      return;
    }

    _log.info('starting download from ${device.remoteId.str} (${device.platformName})');
    emit(state.copyWith(
      isDownloading: true,
      clearDownloadProgress: true,
      downloadedDives: [],
      clearError: true,
      clearAutoStartDescriptor: true,
    ));

    // If we have a remembered computer already, grab the fingerprint from there
    final remembered = await _store.computers.getByRemoteId(device.remoteId.str);
    final ldcFingerprint = remembered?.ldcFingerprint;
    _log.fine('current fingerprint is $ldcFingerprint');

    // Remember this computer for future downloads
    await _store.computers.update(
      remoteId: device.remoteId.str,
      advertisedName: device.platformName,
      vendor: computer.vendor,
      product: computer.model,
    );

    // Set up BLE notifications on the RX characteristic
    try {
      await charPair.rx.setNotifyValue(true);
    } catch (e) {
      emit(state.copyWith(isDownloading: false, error: 'Failed to enable notifications: $e'));
      return;
    }

    // Create BLE characteristics wrapper for the download
    final ble = dc.BleCharacteristics(read: charPair.rx.onValueReceived, write: charPair.rx.write);

    // Start the download and process events
    final dir = await getApplicationSupportDirectory();
    final sub = dc.startDownload(ble: ble, computer: computer, fifoDirectory: dir.path, ldcFingerprint: ldcFingerprint).listen((event) {
      switch (event) {
        case dc.DownloadStarted():
          _log.info('download started');
          WakelockPlus.enable();

        case dc.DownloadProgressEvent(:final progress):
          add(_Progress(progress));

        case dc.DownloadDeviceInfo(:final info):
          _log.fine('device info: $info');
          // Remember the device serial
          _store.computers.update(remoteId: state.connectedDevice!.remoteId.str, serial: info.serial.toString());

        case dc.DownloadDiveReceived(:final dive):
          _log.fine('received dive ${dive.dateTime.toDateTime()}');
          final cdive = convertDcDive(dive);
          add(_DiveReceived(cdive));

        case dc.DownloadCompleted():
          _log.info('download completed');
          add(const _Completed());
          WakelockPlus.disable();

        case dc.DownloadError(:final message):
          _log.warning('download error: $message');
          add(_Failed(message));
          WakelockPlus.disable();

        case dc.DownloadWaiting():
          _log.info('waiting for user action on device');
      }
    });
    sub.onError((e) {
      add(_Failed('Download exception: $e'));
    });
    sub.onDone(() async {
      try {
        await charPair.rx.setNotifyValue(false);
      } catch (_) {}
    });
  }

  void _onDownloadCompleted(Emitter<BleDownloadState> emit) {
    try {
      // Remember the fingerprint on the downloading computer
      _store.computers.update(
        remoteId: state.connectedDevice!.remoteId.str,
        ldcFingerprint: state.downloadedDives.first.logs.first.ldcFingerprint,
      );
    } on StateError catch (_) {}

    _diveListBloc.add(DownloadedDives(state.downloadedDives));

    // Refresh the remembered computers list in scan bloc
    _scanBloc.add(BleScanEvent.refreshRemembered());

    emit(state.copyWith(isDownloading: false, clearDownloadProgress: true));
  }

  Future<void> _onDisconnect(Emitter<BleDownloadState> emit) async {
    if (state.connectedDevice != null) {
      await state.connectedDevice!.disconnect();
      emit(state.copyWith(
        clearConnectedDevice: true,
        connectionState: BluetoothConnectionState.disconnected,
        discoveredServices: [],
        clearAutoStartDescriptor: true,
      ));
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    return super.close();
  }
}

class BleCharacteristicPair {
  final BluetoothCharacteristic rx;
  final BluetoothCharacteristic tx;

  BleCharacteristicPair({required this.rx, required this.tx});
}

BleCharacteristicPair? findBleCharacteristics(List<BluetoothService> services) {
  for (final service in services) {
    BluetoothCharacteristic? rxChar;
    BluetoothCharacteristic? txChar;

    for (final characteristic in service.characteristics) {
      if (characteristic.properties.notify || characteristic.properties.indicate) {
        rxChar ??= characteristic;
      }
      if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
        txChar ??= characteristic;
      }
    }

    if (rxChar != null && txChar != null) {
      return BleCharacteristicPair(rx: rxChar, tx: txChar);
    }
  }
  return null;
}
