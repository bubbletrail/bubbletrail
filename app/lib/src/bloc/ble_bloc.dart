import 'dart:async';

import 'package:dive_computer/dive_computer.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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

// State
class BleState extends Equatable {
  final BluetoothAdapterState adapterState;
  final List<ScanResult> scanResults;
  final bool isScanning;
  final BluetoothDevice? connectedDevice;
  final BluetoothConnectionState connectionState;
  final List<BluetoothService> discoveredServices;
  final bool isDiscoveringServices;
  final List<Computer> supportedBleComputers;
  final String? error;

  const BleState({
    this.adapterState = BluetoothAdapterState.unknown,
    this.scanResults = const [],
    this.isScanning = false,
    this.connectedDevice,
    this.connectionState = BluetoothConnectionState.disconnected,
    this.discoveredServices = const [],
    this.isDiscoveringServices = false,
    this.supportedBleComputers = const [],
    this.error,
  });

  BleState copyWith({
    BluetoothAdapterState? adapterState,
    List<ScanResult>? scanResults,
    bool? isScanning,
    BluetoothDevice? connectedDevice,
    bool clearConnectedDevice = false,
    BluetoothConnectionState? connectionState,
    List<BluetoothService>? discoveredServices,
    bool? isDiscoveringServices,
    List<Computer>? supportedBleComputers,
    String? error,
    bool clearError = false,
  }) {
    return BleState(
      adapterState: adapterState ?? this.adapterState,
      scanResults: scanResults ?? this.scanResults,
      isScanning: isScanning ?? this.isScanning,
      connectedDevice: clearConnectedDevice ? null : (connectedDevice ?? this.connectedDevice),
      connectionState: connectionState ?? this.connectionState,
      discoveredServices: discoveredServices ?? this.discoveredServices,
      isDiscoveringServices: isDiscoveringServices ?? this.isDiscoveringServices,
      supportedBleComputers: supportedBleComputers ?? this.supportedBleComputers,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    adapterState,
    scanResults,
    isScanning,
    connectedDevice,
    connectionState,
    discoveredServices,
    isDiscoveringServices,
    supportedBleComputers,
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
      await event.device.connect(timeout: const Duration(seconds: 15));
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
