import 'dart:async';

import 'package:dive_computer/dive_computer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'ble_iostream.dart';

/// Filters supported BLE computers based on device name patterns from libdivecomputer.
/// Returns computers that match the device name, or all BLE computers if no match.
List<Computer> filterComputersByDeviceName(List<Computer> computers, String deviceName) {
  final name = deviceName.toLowerCase();
  final matches = <Computer>[];

  for (final computer in computers) {
    if (_matchesDeviceName(computer, name)) {
      matches.add(computer);
    }
  }

  // If we found matches, return them; otherwise return all computers
  return matches.isNotEmpty ? matches : computers;
}

bool _matchesDeviceName(Computer computer, String deviceName) {
  final vendor = computer.vendor.toLowerCase();
  final product = computer.product.toLowerCase();

  // Check vendor-specific patterns based on libdivecomputer's dc_descriptor_filter
  switch (vendor) {
    case 'shearwater':
      return _matchesAny(deviceName, ['predator', 'petrel', 'nerd', 'perdix', 'teric', 'peregrine', 'tern']);
    case 'suunto':
      return _matchesPrefix(deviceName, ['eon steel', 'eon core', 'suunto d5', 'eon steel black']);
    case 'scubapro':
    case 'uwatec':
      return _matchesAny(deviceName, ['g2', 'g3', 'aladin', 'hud', 'a1', 'a2', 'galileo', 'luna 2.0']);
    case 'mares':
      return _matchesPrefix(deviceName, ['mares bluelink', 'mares genius']);
    case 'heinrichs weikamp':
      return _matchesPrefix(deviceName, ['ostc', 'frog']);
    case 'aqualung':
      // Oceanic/Aqualung BLE devices use model number prefixes
      return _matchesOceanicPattern(deviceName, product);
    case 'oceanic':
    case 'sherwood':
      return _matchesOceanicPattern(deviceName, product);
    case 'deep six':
    case 'crest':
    case 'genesis':
    case 'scorpena':
      return _matchesAny(deviceName, ['excursion', 'crest-cr4', 'centauri', 'alpha']);
    case 'deepblu':
      return deviceName.contains('cosmiq');
    case 'oceans':
      return _matchesPrefix(deviceName, ['s1']);
    case 'divesoft':
      return _matchesPrefix(deviceName, ['freedom', 'liberty']);
    case 'ratio':
      return _matchesPrefix(deviceName, ['ds', 'ix5m', 'ratio-']);
    case 'mclean':
      return deviceName.contains('mclean extreme');
    default:
      // Try matching product name as fallback
      return deviceName.contains(product);
  }
}

bool _matchesAny(String deviceName, List<String> patterns) {
  return patterns.any((p) => deviceName.contains(p));
}

bool _matchesPrefix(String deviceName, List<String> prefixes) {
  return prefixes.any((p) => deviceName.startsWith(p));
}

bool _matchesOceanicPattern(String deviceName, String product) {
  // Oceanic BLE devices often use model codes like "EF12345"
  // For simplicity, check if device name contains part of product name
  final productWords = product.split(' ');
  return productWords.any((word) => word.length > 2 && deviceName.contains(word.toLowerCase()));
}

/// Known BLE device name patterns for dive computers from libdivecomputer.
const _knownDiveComputerPatterns = [
  // Shearwater
  'predator', 'petrel', 'nerd', 'perdix', 'teric', 'peregrine', 'tern',
  // Suunto
  'eon steel', 'eon core', 'suunto d5',
  // Scubapro/Uwatec
  'g2', 'g3', 'aladin', 'hud', 'luna 2.0', 'galileo',
  // Mares
  'mares bluelink', 'mares genius',
  // Heinrichs Weikamp
  'ostc', 'frog',
  // Deep Six / Crest / Genesis / Scorpena
  'excursion', 'crest-cr4', 'centauri', 'alpha',
  // Deepblu
  'cosmiq',
  // Oceans
  's1',
  // Divesoft
  'freedom', 'liberty',
  // Ratio
  'ratio-', 'ix5m',
  // McLean
  'mclean extreme',
];

/// Checks if a device name matches any known dive computer pattern.
bool isKnownDiveComputer(String deviceName) {
  final name = deviceName.toLowerCase();
  return _knownDiveComputerPatterns.any((pattern) => name.contains(pattern));
}

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

class _BleScanCompleted extends BleEvent {
  const _BleScanCompleted();
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

class _BleSupportedComputersLoaded extends BleEvent {
  final List<Computer> computers;

  const _BleSupportedComputersLoaded(this.computers);

  @override
  List<Object?> get props => [computers];
}

class BleStartDownload extends BleEvent {
  final Computer computer;

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

// State
class BleState extends Equatable {
  final BluetoothAdapterState adapterState;
  final List<ScanResult> scanResults;
  final bool isScanning;
  final bool showAllDevices;
  final BluetoothDevice? connectedDevice;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> discoveredServices;
  final bool isDiscoveringServices;
  final List<Computer> supportedBleComputers;
  final bool isDownloading;
  final List<Dive> downloadedDives;
  final String? error;

  const BleState({
    this.adapterState = BluetoothAdapterState.unknown,
    this.scanResults = const [],
    this.isScanning = false,
    this.showAllDevices = false,
    this.connectedDevice,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.discoveredServices = const [],
    this.isDiscoveringServices = false,
    this.supportedBleComputers = const [],
    this.isDownloading = false,
    this.downloadedDives = const [],
    this.error,
  });

  /// Returns scan results filtered to only known dive computers,
  /// unless [showAllDevices] is true.
  List<ScanResult> get filteredScanResults {
    if (showAllDevices) return scanResults;
    return scanResults.where((r) => isKnownDiveComputer(r.device.platformName)).toList();
  }

  BleState copyWith({
    BluetoothAdapterState? adapterState,
    List<ScanResult>? scanResults,
    bool? isScanning,
    bool? showAllDevices,
    BluetoothDevice? connectedDevice,
    bool clearConnectedDevice = false,
    BluetoothConnectionState? connectionState,
    List<BluetoothService>? discoveredServices,
    bool? isDiscoveringServices,
    List<Computer>? supportedBleComputers,
    bool? isDownloading,
    List<Dive>? downloadedDives,
    String? error,
    bool clearError = false,
  }) {
    return BleState(
      adapterState: adapterState ?? this.adapterState,
      scanResults: scanResults ?? this.scanResults,
      isScanning: isScanning ?? this.isScanning,
      showAllDevices: showAllDevices ?? this.showAllDevices,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      connectionState: connectionState ?? this.connectionState,
      discoveredServices: discoveredServices ?? this.discoveredServices,
      isDiscoveringServices: isDiscoveringServices ?? this.isDiscoveringServices,
      supportedBleComputers: supportedBleComputers ?? this.supportedBleComputers,
      isDownloading: isDownloading ?? this.isDownloading,
      downloadedDives: downloadedDives ?? this.downloadedDives,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    adapterState,
    scanResults,
    isScanning,
    showAllDevices,
    connectedDevice,
    connectionState,
    discoveredServices,
    isDiscoveringServices,
    supportedBleComputers,
    isDownloading,
    downloadedDives,
    error,
  ];
}

// Bloc
class BleBloc extends Bloc<BleEvent, BleState> {
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<BluetoothConnectionState>? _connectionSubscription;

  BleBloc() : super(const BleState()) {
    on<BleStarted>(_onStarted);
    on<BleStartScan>(_onStartScan);
    on<BleStopScan>(_onStopScan);
    on<BleConnectToDevice>(_onConnectToDevice);
    on<BleDisconnect>(_onDisconnect);
    on<BleTurnOn>(_onTurnOn);
    on<_BleAdapterStateChanged>(_onAdapterStateChanged);
    on<_BleScanResultsUpdated>(_onScanResultsUpdated);
    on<_BleScanCompleted>(_onScanCompleted);
    on<_BleConnectionStateChanged>(_onConnectionStateChanged);
    on<_BleServicesDiscovered>(_onServicesDiscovered);
    on<_BleSupportedComputersLoaded>(_onSupportedComputersLoaded);
    on<BleStartDownload>(_onStartDownload);
    on<_BleDownloadCompleted>(_onDownloadCompleted);
    on<_BleDownloadFailed>(_onDownloadFailed);
    on<BleToggleShowAllDevices>(_onToggleShowAllDevices);
  }

  Future<void> _onStarted(BleStarted event, Emitter<BleState> emit) async {
    _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      add(_BleAdapterStateChanged(state));
    });

    _loadSupportedBleComputers();
  }

  Future<void> _loadSupportedBleComputers() async {
    try {
      final allComputers = await DiveComputer.instance.supportedComputers;
      final bleComputers = allComputers.where((c) => c.transports.contains(ComputerTransport.ble)).toList();
      add(_BleSupportedComputersLoaded(bleComputers));
    } catch (e) {
      // Silently fail - computers list will remain empty
    }
  }

  void _onAdapterStateChanged(_BleAdapterStateChanged event, Emitter<BleState> emit) {
    emit(state.copyWith(adapterState: event.adapterState));
  }

  Future<void> _onStartScan(BleStartScan event, Emitter<BleState> emit) async {
    if (state.isScanning) return;

    emit(state.copyWith(scanResults: [], isScanning: true, clearError: true));

    _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) => r.device.platformName.isNotEmpty).toList();
      filtered.sort((a, b) => b.rssi.compareTo(a.rssi));
      add(_BleScanResultsUpdated(filtered));
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    add(const _BleScanCompleted());
  }

  void _onScanResultsUpdated(_BleScanResultsUpdated event, Emitter<BleState> emit) {
    emit(state.copyWith(scanResults: event.results));
  }

  void _onScanCompleted(_BleScanCompleted event, Emitter<BleState> emit) {
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onStopScan(BleStopScan event, Emitter<BleState> emit) async {
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onConnectToDevice(BleConnectToDevice event, Emitter<BleState> emit) async {
    // Stop scanning first
    await FlutterBluePlus.stopScan();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(state.copyWith(isScanning: false, clearError: true));

    // Set up connection state listener
    _connectionSubscription?.cancel();
    _connectionSubscription = event.device.connectionState.listen((connectionState) {
      add(_BleConnectionStateChanged(connectionState));
    });

    try {
      await event.device.connect(license: License.free, timeout: const Duration(seconds: 15));
      emit(state.copyWith(connectedDevice: event.device));

      // Discover services
      emit(state.copyWith(isDiscoveringServices: true));
      final services = await event.device.discoverServices();
      add(_BleServicesDiscovered(services));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to connect: $e'));
    }
  }

  void _onConnectionStateChanged(_BleConnectionStateChanged event, Emitter<BleState> emit) {
    if (event.connectionState == BluetoothConnectionState.disconnected) {
      emit(state.copyWith(connectionState: event.connectionState, clearConnectedDevice: true, discoveredServices: [], isDiscoveringServices: false));
    } else {
      emit(state.copyWith(connectionState: event.connectionState));
    }
  }

  void _onServicesDiscovered(_BleServicesDiscovered event, Emitter<BleState> emit) {
    emit(state.copyWith(discoveredServices: event.services, isDiscoveringServices: false));
  }

  void _onSupportedComputersLoaded(_BleSupportedComputersLoaded event, Emitter<BleState> emit) {
    emit(state.copyWith(supportedBleComputers: event.computers));
  }

  void _onToggleShowAllDevices(BleToggleShowAllDevices event, Emitter<BleState> emit) {
    emit(state.copyWith(showAllDevices: !state.showAllDevices));
  }

  Future<void> _onStartDownload(BleStartDownload event, Emitter<BleState> emit) async {
    if (state.discoveredServices.isEmpty) {
      emit(state.copyWith(error: 'No services discovered'));
      return;
    }

    final charPair = findBleCharacteristics(state.discoveredServices);
    if (charPair == null) {
      emit(state.copyWith(error: 'No suitable BLE characteristics found'));
      return;
    }

    emit(state.copyWith(isDownloading: true, downloadedDives: [], clearError: true));

    try {
      final iostream = BleIOStream(rxCharacteristic: charPair.rx, txCharacteristic: charPair.tx);
      await iostream.setupNotifications();

      final dives = await _performDownload(event.computer, iostream);
      add(_BleDownloadCompleted(dives));
    } catch (e) {
      add(_BleDownloadFailed(e.toString()));
    }
  }

  Future<List<Dive>> _performDownload(Computer computer, BleIOStream iostream) async {
    // TODO: Integrate with DiveComputerFfi for BLE download
    // For now, this is a placeholder that demonstrates the flow
    // The actual implementation needs to handle the isolate/main thread
    // bridging for BLE communication
    throw UnimplementedError(
      'BLE download not yet implemented. '
      'Selected: ${computer.vendor} ${computer.product}',
    );
  }

  void _onDownloadCompleted(_BleDownloadCompleted event, Emitter<BleState> emit) {
    emit(state.copyWith(isDownloading: false, downloadedDives: event.dives));
  }

  void _onDownloadFailed(_BleDownloadFailed event, Emitter<BleState> emit) {
    emit(state.copyWith(isDownloading: false, error: event.error));
  }

  Future<void> _onDisconnect(BleDisconnect event, Emitter<BleState> emit) async {
    if (state.connectedDevice != null) {
      await state.connectedDevice!.disconnect();
      emit(state.copyWith(clearConnectedDevice: true, connectionState: BluetoothConnectionState.disconnected, discoveredServices: []));
    }
  }

  Future<void> _onTurnOn(BleTurnOn event, Emitter<BleState> emit) async {
    await FlutterBluePlus.turnOn();
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    return super.close();
  }
}
