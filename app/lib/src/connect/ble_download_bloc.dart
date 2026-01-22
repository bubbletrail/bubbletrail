import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:libdivecomputer/libdivecomputer.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../dives_sites/dive_list_bloc.dart';
import '../providers/storage_provider.dart';
import 'ble_scan_bloc.dart';

part 'ble_download_bloc.g.dart';

final _log = Logger('ble_download_bloc.dart');

// Events
sealed class BleDownloadEvent extends Equatable {
  const BleDownloadEvent();

  const factory BleDownloadEvent.connectToDevice(BluetoothDevice device) = _ConnectToDevice;
  const factory BleDownloadEvent.connectToRemembered(Computer computer, ComputerDescriptor descriptor) = _ConnectToRemembered;
  const factory BleDownloadEvent.start(ComputerDescriptor computer) = _Start;
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
  final ComputerDescriptor descriptor;

  const _ConnectToRemembered(this.computer, this.descriptor);

  @override
  List<Object?> get props => [computer, descriptor];
}

class _Start extends BleDownloadEvent {
  final ComputerDescriptor computer;

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
  final DownloadProgress progress;

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

class _NewLastLogDate extends BleDownloadEvent {
  final DateTime lastLogDate;

  const _NewLastLogDate(this.lastLogDate);

  @override
  List<Object?> get props => [lastLogDate];
}

@CopyWith(copyWithNull: true)
class BleDownloadState extends Equatable {
  final BluetoothDevice? connectedDevice;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> discoveredServices;
  final bool isDiscoveringServices;
  final bool isDownloading;
  final DownloadProgress? downloadProgress;
  final List<Dive> downloadedDives;
  final String? error;
  final DateTime? lastLogDate;

  /// If connecting to a remembered computer, auto-start with this descriptor
  final ComputerDescriptor? autoStartDescriptor;

  const BleDownloadState({
    this.connectedDevice,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.discoveredServices = const [],
    this.isDiscoveringServices = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.downloadedDives = const [],
    this.error,
    this.lastLogDate,
    this.autoStartDescriptor,
  });

  bool get isConnected => connectionState == BluetoothConnectionState.connected;
  bool get isReadyToDownload => isConnected && discoveredServices.isNotEmpty && !isDownloading;

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
    lastLogDate,
    autoStartDescriptor,
  ];
}

// Bloc
class BleDownloadBloc extends Bloc<BleDownloadEvent, BleDownloadState> {
  final DiveListBloc _diveListBloc;
  final BleScanBloc _scanBloc;
  late final Store _store;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  StreamSubscription<DiveListState>? _diveListSubscription;

  BleDownloadBloc(this._diveListBloc, this._scanBloc) : super(const BleDownloadState()) {
    _log.fine('starting');

    on<BleDownloadEvent>(_onEvent, transformer: sequential());

    StorageProvider.store.then((store) {
      _store = store;
    });

    _processDiveListState(_diveListBloc.state);
    _diveListSubscription = _diveListBloc.stream.listen(_processDiveListState);
  }

  void _processDiveListState(DiveListState state) {
    if (state is! DiveListLoaded) return;
    final lastLogTime = state.dives.fold(DateTime.fromMillisecondsSinceEpoch(0), (dt, dive) {
      final diveT = dive.start.toDateTime();
      if (diveT.isAfter(dt)) return diveT;
      return dt;
    });
    add(_NewLastLogDate(lastLogTime));
  }

  Future<void> _onEvent(BleDownloadEvent event, Emitter<BleDownloadState> emit) async {
    switch (event) {
      case _NewLastLogDate(:final lastLogDate):
        emit(state.copyWith(lastLogDate: lastLogDate));
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
        await _onDiveReceived(emit, dive);
      case _Completed():
        _onDownloadCompleted(emit);
      case _Failed(:final error):
        emit(state.copyWith(isDownloading: false, error: error).copyWithNull(downloadProgress: true));
      case _Disconnect():
        await _onDisconnect(emit);
    }
  }

  Future<void> _onDiveReceived(Emitter<BleDownloadState> emit, Dive dive) async {
    emit(state.copyWith(downloadedDives: state.downloadedDives + [dive]));
  }

  Future<void> _onConnectToDevice(BluetoothDevice device, ComputerDescriptor? autoStart, Emitter<BleDownloadState> emit) async {
    // Stop scanning first
    await _scanBloc.stopScanningForDownload();

    emit(state.copyWith(autoStartDescriptor: autoStart).copyWithNull(error: true, autoStartDescriptor: autoStart == null));

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

  Future<void> _onConnectToRemembered(Computer computer, ComputerDescriptor descriptor, Emitter<BleDownloadState> emit) async {
    final device = BluetoothDevice.fromId(computer.remoteId);
    await _onConnectToDevice(device, descriptor, emit);
  }

  void _onConnectionStateChanged(BluetoothConnectionState connectionState, Emitter<BleDownloadState> emit) {
    if (connectionState == BluetoothConnectionState.disconnected && state.connectionState == BluetoothConnectionState.connected) {
      emit(
        state
            .copyWith(connectionState: connectionState, discoveredServices: [], isDiscoveringServices: false)
            .copyWithNull(connectedDevice: true, autoStartDescriptor: true),
      );
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

  Future<void> _onStartDownload(ComputerDescriptor computer, Emitter<BleDownloadState> emit) async {
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
    emit(state.copyWith(isDownloading: true, downloadedDives: []).copyWithNull(downloadProgress: true, error: true, autoStartDescriptor: true));

    // If we have a remembered computer already, grab the fingerprint from there
    final remembered = await _store.computers.getByRemoteId(device.remoteId.str);
    final ldcFingerprint = remembered?.ldcFingerprint;
    final lastLogDate = remembered?.hasLastLogDate() == true
        ? remembered!.lastLogDate.toDateTime()
        : state.lastLogDate ?? DateTime.fromMillisecondsSinceEpoch(0);
    _log.fine('current fingerprint is $ldcFingerprint and last log date $lastLogDate');

    // Remember this computer for future downloads
    await _store.computers.updateFields(remoteId: device.remoteId.str, advertisedName: device.platformName, vendor: computer.vendor, product: computer.model);

    // Set up BLE notifications on the RX characteristic
    try {
      await charPair.rx.setNotifyValue(true);
    } catch (e) {
      emit(state.copyWith(isDownloading: false, error: 'Failed to enable notifications: $e'));
      return;
    }

    // Create BLE characteristics wrapper for the download
    final ble = BleCharacteristics(read: charPair.rx.onValueReceived, write: charPair.rx.write);

    // Start the download and process events
    final dir = await getApplicationSupportDirectory();
    final sub = startDownload(ble: ble, computer: computer, fifoDirectory: dir.path, ldcFingerprint: ldcFingerprint, lastLogDate: lastLogDate).listen((event) {
      switch (event) {
        case DownloadStarted():
          _log.info('download started');
          WakelockPlus.enable();

        case DownloadProgressEvent(:final progress):
          add(_Progress(progress));

        case DownloadDeviceInfo(:final info):
          _log.fine('device info: $info');
          // Remember the device serial
          _store.computers.updateFields(remoteId: state.connectedDevice!.remoteId.str, serial: info.serial);

        case DownloadDiveReceived(dive: final log):
          _log.fine('received dive ${log.dateTime.toDateTime()} with fingerprint ${log.ldcFingerprint}');
          final cdive = convertDcDive(log);
          add(_DiveReceived(cdive));

        case DownloadCompleted():
          _log.info('download completed');
          add(const _Completed());
          WakelockPlus.disable();

        case DownloadError(:final message):
          _log.warning('download error: $message');
          add(_Failed(message));
          WakelockPlus.disable();

        case DownloadWaiting():
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
      // Remember the fingerprint & last log date on the downloading computer
      final ll = state.downloadedDives.first.logs.last;
      _store.computers.updateFields(remoteId: state.connectedDevice!.remoteId.str, ldcFingerprint: ll.ldcFingerprint, lastLogDate: ll.dateTime.toDateTime());
    } on StateError catch (_) {
      // no downloaded dive or no logs in dive
    }

    _diveListBloc.add(DownloadedDives(state.downloadedDives));

    // Refresh the remembered computers list in scan bloc
    _scanBloc.add(BleScanEvent.refreshRemembered());

    emit(state.copyWith(isDownloading: false).copyWithNull(downloadProgress: true));
  }

  Future<void> _onDisconnect(Emitter<BleDownloadState> emit) async {
    if (state.connectedDevice != null) {
      await state.connectedDevice!.disconnect();
      emit(
        state
            .copyWith(connectionState: BluetoothConnectionState.disconnected, discoveredServices: [])
            .copyWithNull(connectedDevice: true, autoStartDescriptor: true),
      );
    }
  }

  @override
  Future<void> close() {
    _connectionSubscription?.cancel();
    _diveListSubscription?.cancel();
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
