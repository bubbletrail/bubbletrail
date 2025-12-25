import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:libdivecomputer/libdivecomputer.dart';
import 'package:path_provider/path_provider.dart';

// Events
abstract class BleEvent extends Equatable {
  const BleEvent();

  @override
  List<Object?> get props => [];
}

class BleStarted extends BleEvent {
  const BleStarted();
}

class BleStartScan extends BleEvent {
  const BleStartScan();
}

class BleStopScan extends BleEvent {
  const BleStopScan();
}

class BleConnectToDevice extends BleEvent {
  final BluetoothDevice device;

  const BleConnectToDevice(this.device);

  @override
  List<Object?> get props => [device];
}

class BleDisconnect extends BleEvent {
  const BleDisconnect();
}

class BleTurnOn extends BleEvent {
  const BleTurnOn();
}

class BleToggleShowAllDevices extends BleEvent {
  const BleToggleShowAllDevices();
}

class _BleAdapterStateChanged extends BleEvent {
  final BluetoothAdapterState adapterState;

  const _BleAdapterStateChanged(this.adapterState);

  @override
  List<Object?> get props => [adapterState];
}

class _BleScanResultsUpdated extends BleEvent {
  final List<ScanResult> results;

  const _BleScanResultsUpdated(this.results);

  @override
  List<Object?> get props => [results];
}

class _BleScanStatusChanged extends BleEvent {
  final bool scanning;

  const _BleScanStatusChanged(this.scanning);

  @override
  List<Object?> get props => [scanning];
}

class _BleConnectionStateChanged extends BleEvent {
  final BluetoothConnectionState connectionState;

  const _BleConnectionStateChanged(this.connectionState);

  @override
  List<Object?> get props => [connectionState];
}

class _BleServicesDiscovered extends BleEvent {
  final List<BluetoothService> services;

  const _BleServicesDiscovered(this.services);

  @override
  List<Object?> get props => [services];
}

class BleStartDownload extends BleEvent {
  final ComputerDescriptor computer;

  const BleStartDownload(this.computer);

  @override
  List<Object?> get props => [computer];
}

class _BleDownloadCompleted extends BleEvent {
  final List<Dive> dives;

  const _BleDownloadCompleted(this.dives);

  @override
  List<Object?> get props => [dives];
}

class _BleDownloadFailed extends BleEvent {
  final String error;

  const _BleDownloadFailed(this.error);

  @override
  List<Object?> get props => [error];
}

class _BleDownloadProgress extends BleEvent {
  final DownloadProgress progress;

  const _BleDownloadProgress(this.progress);

  @override
  List<Object?> get props => [progress];
}

class _BleLoadedSupportedComputers extends BleEvent {
  final List<ComputerDescriptor> computers;

  const _BleLoadedSupportedComputers(this.computers);

  @override
  List<Object?> get props => [computers];
}

// State
class BleState extends Equatable {
  final List<ComputerDescriptor> supportedComputers;
  final BluetoothAdapterState adapterState;
  final List<(ScanResult, List<ComputerDescriptor>)> scanResults;
  final bool isScanning;
  final bool showAllDevices;
  final BluetoothDevice? connectedDevice;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> discoveredServices;
  final bool isDiscoveringServices;
  final bool isDownloading;
  final DownloadProgress? downloadProgress;
  final List<Dive> downloadedDives;
  final String? error;

  const BleState({
    this.supportedComputers = const [],
    this.adapterState = BluetoothAdapterState.unknown,
    this.scanResults = const [],
    this.isScanning = false,
    this.showAllDevices = false,
    this.connectedDevice,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.discoveredServices = const [],
    this.isDiscoveringServices = false,
    this.isDownloading = false,
    this.downloadProgress,
    this.downloadedDives = const [],
    this.error,
  });

  /// Returns scan results filtered to only known dive computers,
  /// unless [showAllDevices] is true.
  List<ScanResult> get filteredScanResults {
    if (showAllDevices) return scanResults.map((e) => e.$1).toList();
    return scanResults.where((e) => e.$2.isNotEmpty).map((e) => e.$1).toList();
  }

  BleState copyWith({
    List<ComputerDescriptor>? supportedComputers,
    BluetoothAdapterState? adapterState,
    List<(ScanResult, List<ComputerDescriptor>)>? scanResults,
    bool? isScanning,
    bool? showAllDevices,
    BluetoothDevice? connectedDevice,
    bool clearConnectedDevice = false,
    BluetoothConnectionState? connectionState,
    List<BluetoothService>? discoveredServices,
    bool? isDiscoveringServices,
    bool? isDownloading,
    DownloadProgress? downloadProgress,
    bool clearDownloadProgress = false,
    List<Dive>? downloadedDives,
    String? error,
    bool clearError = false,
  }) {
    return BleState(
      supportedComputers: supportedComputers ?? this.supportedComputers,
      adapterState: adapterState ?? this.adapterState,
      scanResults: scanResults ?? this.scanResults,
      isScanning: isScanning ?? this.isScanning,
      showAllDevices: showAllDevices ?? this.showAllDevices,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      connectionState: connectionState ?? this.connectionState,
      discoveredServices: discoveredServices ?? this.discoveredServices,
      isDiscoveringServices: isDiscoveringServices ?? this.isDiscoveringServices,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadProgress: clearDownloadProgress ? null : (downloadProgress ?? this.downloadProgress),
      downloadedDives: downloadedDives ?? this.downloadedDives,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    supportedComputers,
    adapterState,
    scanResults,
    isScanning,
    showAllDevices,
    connectedDevice,
    connectionState,
    discoveredServices,
    isDiscoveringServices,
    isDownloading,
    downloadProgress,
    downloadedDives,
    error,
  ];
}

// Bloc
class BleBloc extends Bloc<BleEvent, BleState> {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanStatusSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;
  final _matchedDevices = <String, List<ComputerDescriptor>>{};

  BleBloc() : super(const BleState()) {
    on<BleEvent>(_onEvent, transformer: sequential());

    dcDescriptorIterate().then((comps) => add(_BleLoadedSupportedComputers(comps)));
  }

  Future<void> _onEvent(BleEvent event, Emitter<BleState> emit) async {
    switch (event) {
      case BleStarted():
        await _onStarted(emit);
      case _BleAdapterStateChanged(:final adapterState):
        emit(state.copyWith(adapterState: adapterState));
      case _BleLoadedSupportedComputers(:final computers):
        emit(state.copyWith(supportedComputers: computers));
      case BleStartScan():
        await _onStartScan(emit);
      case _BleScanResultsUpdated(:final results):
        await _onScanResultsUpdated(results, emit);
      case _BleScanStatusChanged(:final scanning):
        emit(state.copyWith(isScanning: scanning));
      case BleStopScan():
        await _onStopScan(emit);
      case BleConnectToDevice(:final device):
        await _onConnectToDevice(device, emit);
      case _BleConnectionStateChanged(:final connectionState):
        _onConnectionStateChanged(connectionState, emit);
      case _BleServicesDiscovered(:final services):
        emit(state.copyWith(discoveredServices: services, isDiscoveringServices: false));
      case BleToggleShowAllDevices():
        emit(state.copyWith(showAllDevices: !state.showAllDevices));
      case BleStartDownload(:final computer):
        await _onStartDownload(computer, emit);
      case _BleDownloadCompleted(:final dives):
        emit(state.copyWith(isDownloading: false, clearDownloadProgress: true, downloadedDives: dives));
      case _BleDownloadFailed(:final error):
        emit(state.copyWith(isDownloading: false, clearDownloadProgress: true, error: error));
      case _BleDownloadProgress(:final progress):
        emit(state.copyWith(downloadProgress: progress));
      case BleDisconnect():
        await _onDisconnect(emit);
      case BleTurnOn():
        await FlutterBluePlus.turnOn();
    }
  }

  Future<void> _onStarted(Emitter<BleState> emit) async {
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      add(_BleAdapterStateChanged(state));
    });
    await FlutterBluePlus.setLogLevel(LogLevel.none);
  }

  Future<void> _onStartScan(Emitter<BleState> emit) async {
    if (state.isScanning) return;
    emit(state.copyWith(scanResults: [], clearError: true));

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) => r.device.platformName.isNotEmpty).toList();
      filtered.sort((a, b) => a.device.platformName.toLowerCase().compareTo(b.device.platformName.toLowerCase()));
      add(_BleScanResultsUpdated(filtered));
    });

    _scanStatusSubscription?.cancel();
    _scanStatusSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      add(_BleScanStatusChanged(scanning));
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> _onScanResultsUpdated(List<ScanResult> results, Emitter<BleState> emit) async {
    for (final res in results) {
      if (!_matchedDevices.containsKey(res.device.platformName)) {
        _matchedDevices[res.device.platformName] = await dcDescriptorIterate(filterForName: res.device.platformName);
      }
    }
    final scanResults = results.map((e) => (e, _matchedDevices[e.device.platformName] ?? [])).toList();
    emit(state.copyWith(scanResults: scanResults));
  }

  Future<void> _onStopScan(Emitter<BleState> emit) async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onConnectToDevice(BluetoothDevice device, Emitter<BleState> emit) async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(state.copyWith(isScanning: false, clearError: true));

    _connectionSubscription?.cancel();
    _connectionSubscription = device.connectionState.listen((connectionState) {
      add(_BleConnectionStateChanged(connectionState));
    });

    try {
      await device.connect(license: License.free, timeout: const Duration(seconds: 15));
      emit(state.copyWith(connectedDevice: device, isDiscoveringServices: true));
      final services = await device.discoverServices();
      add(_BleServicesDiscovered(services));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to connect: $e'));
    }
  }

  void _onConnectionStateChanged(BluetoothConnectionState connectionState, Emitter<BleState> emit) {
    if (connectionState == BluetoothConnectionState.disconnected && state.connectionState == BluetoothConnectionState.connected) {
      emit(state.copyWith(connectionState: connectionState, clearConnectedDevice: true, discoveredServices: [], isDiscoveringServices: false));
    } else {
      emit(state.copyWith(connectionState: connectionState));
    }
  }

  Future<void> _onStartDownload(ComputerDescriptor computer, Emitter<BleState> emit) async {
    if (state.discoveredServices.isEmpty) {
      emit(state.copyWith(error: 'No services discovered'));
      return;
    }

    final charPair = findBleCharacteristics(state.discoveredServices);
    if (charPair == null) {
      emit(state.copyWith(error: 'No suitable BLE characteristics found'));
      return;
    }

    emit(state.copyWith(isDownloading: true, clearDownloadProgress: true, downloadedDives: [], clearError: true));

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
    final sub = startDownload(ble: ble, computer: computer, fifoDirectory: dir.path).listen((event) {
      switch (event) {
        case DownloadStarted():
          print('Download started');
        case DownloadProgressEvent(:final progress):
          add(_BleDownloadProgress(progress));
        case DownloadDeviceInfo(:final info):
          print('Device info: $info');
        case DownloadDiveReceived(:final dive):
          print('Received dive: $dive');
        case DownloadCompleted(:final diveCount):
          print('Download completed: $diveCount dives');
          add(_BleDownloadCompleted(const []));
        case DownloadError(:final message):
          print('Download error: $message');
          add(_BleDownloadFailed(message));
        case DownloadWaiting():
          print('Download waiting');
      }
    });
    sub.onError((e) {
      add(_BleDownloadFailed('Download exception: $e'));
    });
    sub.onDone(() async {
      try {
        await charPair.rx.setNotifyValue(false);
      } catch (_) {}
    });
  }

  Future<void> _onDisconnect(Emitter<BleState> emit) async {
    if (state.connectedDevice != null) {
      await state.connectedDevice!.disconnect();
      emit(state.copyWith(clearConnectedDevice: true, connectionState: BluetoothConnectionState.disconnected, discoveredServices: []));
    }
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanStatusSubscription?.cancel();
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
