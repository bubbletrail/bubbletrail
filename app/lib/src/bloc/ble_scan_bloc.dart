import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:libdivecomputer/libdivecomputer.dart' as dc;

import 'sync_bloc.dart';

// Events
sealed class BleScanEvent extends Equatable {
  const BleScanEvent();

  const factory BleScanEvent.start() = _Start;
  const factory BleScanEvent.stop() = _Stop;
  const factory BleScanEvent.toggleShowAll() = _ToggleShowAll;
  const factory BleScanEvent.turnOnBluetooth() = _TurnOnBluetooth;
  const factory BleScanEvent.forgetComputer(Computer computer) = _ForgetComputer;
  const factory BleScanEvent.refreshRemembered() = _RefreshRemembered;

  @override
  List<Object?> get props => [];
}

class _Started extends BleScanEvent {
  const _Started();
}

class _Start extends BleScanEvent {
  const _Start();
}

class _Stop extends BleScanEvent {
  const _Stop();
}

class _ToggleShowAll extends BleScanEvent {
  const _ToggleShowAll();
}

class _TurnOnBluetooth extends BleScanEvent {
  const _TurnOnBluetooth();
}

class _ForgetComputer extends BleScanEvent {
  final Computer computer;

  const _ForgetComputer(this.computer);

  @override
  List<Object?> get props => [computer];
}

class _RefreshRemembered extends BleScanEvent {
  const _RefreshRemembered();
}

class _AdapterStateChanged extends BleScanEvent {
  final BluetoothAdapterState adapterState;

  const _AdapterStateChanged(this.adapterState);

  @override
  List<Object?> get props => [adapterState];
}

class _ScanResultsUpdated extends BleScanEvent {
  final List<ScanResult> results;

  const _ScanResultsUpdated(this.results);

  @override
  List<Object?> get props => [results];
}

class _ScanStatusChanged extends BleScanEvent {
  final bool scanning;

  const _ScanStatusChanged(this.scanning);

  @override
  List<Object?> get props => [scanning];
}

class _LoadedSupportedComputers extends BleScanEvent {
  final List<dc.ComputerDescriptor> computers;

  const _LoadedSupportedComputers(this.computers);

  @override
  List<Object?> get props => [computers];
}

class _LoadedRememberedComputers extends BleScanEvent {
  final List<Computer> computers;

  const _LoadedRememberedComputers(this.computers);

  @override
  List<Object?> get props => [computers];
}

// State
class BleScanState extends Equatable {
  final BluetoothAdapterState adapterState;
  final List<dc.ComputerDescriptor> supportedComputers;
  final List<Computer> rememberedComputers;
  final List<(ScanResult, List<dc.ComputerDescriptor>)> scanResults;
  final bool isScanning;
  final bool showAllDevices;
  final String? error;

  const BleScanState({
    this.adapterState = BluetoothAdapterState.unknown,
    this.supportedComputers = const [],
    this.rememberedComputers = const [],
    this.scanResults = const [],
    this.isScanning = false,
    this.showAllDevices = false,
    this.error,
  });

  List<ScanResult> get filteredScanResults {
    if (showAllDevices) return scanResults.map((e) => e.$1).toList();
    return scanResults.where((e) => e.$2.isNotEmpty).map((e) => e.$1).toList();
  }

  List<dc.ComputerDescriptor> descriptorsForDevice(BluetoothDevice device) {
    final match = scanResults.where((r) => r.$1.device.remoteId == device.remoteId).firstOrNull;
    return match?.$2 ?? [];
  }

  BleScanState copyWith({
    BluetoothAdapterState? adapterState,
    List<dc.ComputerDescriptor>? supportedComputers,
    List<Computer>? rememberedComputers,
    List<(ScanResult, List<dc.ComputerDescriptor>)>? scanResults,
    bool? isScanning,
    bool? showAllDevices,
    String? error,
    bool clearError = false,
  }) {
    return BleScanState(
      adapterState: adapterState ?? this.adapterState,
      supportedComputers: supportedComputers ?? this.supportedComputers,
      rememberedComputers: rememberedComputers ?? this.rememberedComputers,
      scanResults: scanResults ?? this.scanResults,
      isScanning: isScanning ?? this.isScanning,
      showAllDevices: showAllDevices ?? this.showAllDevices,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
    adapterState,
    supportedComputers,
    rememberedComputers,
    scanResults,
    isScanning,
    showAllDevices,
    error,
  ];
}

// Bloc
class BleScanBloc extends Bloc<BleScanEvent, BleScanState> {
  final SyncBloc _syncBloc;
  late final Store _store;
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  StreamSubscription<bool>? _scanStatusSubscription;
  final _matchedDevices = <String, List<dc.ComputerDescriptor>>{};

  BleScanBloc(this._syncBloc) : super(const BleScanState()) {
    on<BleScanEvent>(_onEvent, transformer: sequential());

    dc.dcDescriptorIterate().then((comps) => add(_LoadedSupportedComputers(comps)));

    _syncBloc.store.then((store) async {
      _store = store;
      final computers = await _store.computers.getAll();
      add(_LoadedRememberedComputers(computers));
    });

    add(const _Started());
  }

  Future<void> _onEvent(BleScanEvent event, Emitter<BleScanState> emit) async {
    switch (event) {
      case _Started():
        await _onStarted(emit);
      case _AdapterStateChanged(:final adapterState):
        emit(state.copyWith(adapterState: adapterState));
      case _LoadedSupportedComputers(:final computers):
        emit(state.copyWith(supportedComputers: computers));
      case _LoadedRememberedComputers(:final computers):
        emit(state.copyWith(rememberedComputers: computers));
      case _Start():
        await _onStartScan(emit);
      case _Stop():
        await _onStopScan(emit);
      case _ScanResultsUpdated(:final results):
        await _onScanResultsUpdated(results, emit);
      case _ScanStatusChanged(:final scanning):
        emit(state.copyWith(isScanning: scanning));
      case _ToggleShowAll():
        emit(state.copyWith(showAllDevices: !state.showAllDevices));
      case _TurnOnBluetooth():
        await FlutterBluePlus.turnOn();
      case _ForgetComputer(:final computer):
        await _onForgetComputer(computer, emit);
      case _RefreshRemembered():
        await _onRefreshRemembered(emit);
    }
  }

  Future<void> _onStarted(Emitter<BleScanState> emit) async {
    await _adapterStateSubscription?.cancel();
    _adapterStateSubscription = FlutterBluePlus.adapterState.listen((state) {
      add(_AdapterStateChanged(state));
    });
    await FlutterBluePlus.setLogLevel(LogLevel.none);
  }

  Future<void> _onStartScan(Emitter<BleScanState> emit) async {
    if (state.isScanning) return;
    emit(state.copyWith(scanResults: [], clearError: true));

    await _scanSubscription?.cancel();
    _scanSubscription = FlutterBluePlus.scanResults.listen((results) {
      final filtered = results.where((r) => r.device.platformName.isNotEmpty).toList();
      filtered.sort((a, b) => a.device.platformName.toLowerCase().compareTo(b.device.platformName.toLowerCase()));
      add(_ScanResultsUpdated(filtered));
    });

    await _scanStatusSubscription?.cancel();
    _scanStatusSubscription = FlutterBluePlus.isScanning.listen((scanning) {
      add(_ScanStatusChanged(scanning));
    });

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
  }

  Future<void> _onStopScan(Emitter<BleScanState> emit) async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
    emit(state.copyWith(isScanning: false));
  }

  Future<void> _onScanResultsUpdated(List<ScanResult> results, Emitter<BleScanState> emit) async {
    for (final res in results) {
      if (!_matchedDevices.containsKey(res.device.platformName)) {
        _matchedDevices[res.device.platformName] = await dc.dcDescriptorIterate(filterForName: res.device.platformName);
      }
    }
    final scanResults = results.map((e) => (e, _matchedDevices[e.device.platformName] ?? [])).toList();
    emit(state.copyWith(scanResults: scanResults));
  }

  Future<void> _onForgetComputer(Computer computer, Emitter<BleScanState> emit) async {
    await _store.computers.delete(computer.remoteId);
    final computers = await _store.computers.getAll();
    emit(state.copyWith(rememberedComputers: computers));
  }

  Future<void> _onRefreshRemembered(Emitter<BleScanState> emit) async {
    final computers = await _store.computers.getAll();
    emit(state.copyWith(rememberedComputers: computers));
  }

  /// Stop scanning when navigating away to download
  Future<void> stopScanningForDownload() async {
    await FlutterBluePlus.stopScan();
    await _scanSubscription?.cancel();
    _scanSubscription = null;
  }

  @override
  Future<void> close() {
    _adapterStateSubscription?.cancel();
    _scanSubscription?.cancel();
    _scanStatusSubscription?.cancel();
    return super.close();
  }
}
