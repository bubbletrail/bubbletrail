import 'dart:async';
import 'dart:ui';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../providers/s3_provider.dart';
import '../providers/storage_provider.dart';
import 'preferences.dart';
import 'preferences_store.dart';

final _log = Logger('sync_bloc.dart');

class SyncState extends Equatable {
  final DateTime? lastSynced;
  final bool syncing;
  final String? error;
  final bool? lastSyncSuccess;

  const SyncState({this.lastSynced, this.syncing = false, this.error, this.lastSyncSuccess});

  SyncState copyWith({DateTime? lastSynced, bool? syncing, String? error, bool? lastSyncSuccess}) {
    return SyncState(lastSynced: lastSynced ?? this.lastSynced, syncing: syncing ?? this.syncing, error: error, lastSyncSuccess: lastSyncSuccess);
  }

  @override
  List<Object?> get props => [lastSynced, syncing, error, lastSyncSuccess];
}

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];

  const factory SyncEvent.startSyncing() = _StartSyncing;
}

class _InitStore extends SyncEvent {
  const _InitStore();
}

class _StartSyncing extends SyncEvent {
  const _StartSyncing();
}

class _UpdateSyncConfig extends SyncEvent {
  final SyncProviderKind provider;
  final S3Config s3Config;

  const _UpdateSyncConfig({required this.provider, required this.s3Config});

  @override
  List<Object?> get props => [provider, s3Config];
}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final _store = StorageProvider.instance.store;

  SyncProvider? _syncProvider;
  S3Config? _syncConfig;
  Timer? _syncDebounceTimer;
  VoidCallback? _preferencesListener;
  VoidCallback? _storeListener;

  SyncBloc() : super(SyncState()) {
    on<SyncEvent>((event, emit) async {
      switch (event) {
        case _InitStore():
          await _onInitStore(emit);
        case _UpdateSyncConfig():
          await _onUpdateConfig(event);
        case _StartSyncing():
          await _onStartSyncing(emit);
      }
    }, transformer: sequential());

    add(const _InitStore());
  }

  void _onPreferencesChanged() {
    final prefs = PreferencesStore.instance;
    add(_UpdateSyncConfig(provider: prefs.syncProvider, s3Config: prefs.s3Config));
  }

  Future<void> _onInitStore(Emitter<SyncState> emit) async {
    _log.fine('init');

    _storeListener = () {
      _syncDebounceTimer?.cancel();
      _syncDebounceTimer = Timer(Duration(seconds: 60), () => add(SyncEvent.startSyncing()));
    };
    _store.addListener(_storeListener!);

    _preferencesListener = _onPreferencesChanged;
    PreferencesStore.instance.addListener(_preferencesListener!);
    _onPreferencesChanged();

    add(const _StartSyncing());
  }

  Future<void> _onUpdateConfig(_UpdateSyncConfig event) async {
    if (event.provider == .none) {
      _syncProvider = null;
      _syncConfig = null;
      return;
    }

    if (_syncConfig == event.s3Config) return;

    _log.fine('init sync provider');
    final provider = S3SyncProvider(
      endpoint: event.s3Config.endpoint,
      bucket: event.s3Config.bucket,
      accessKey: event.s3Config.accessKey,
      secretKey: event.s3Config.secretKey,
      vaultKey: event.s3Config.vaultKey,
    );
    await provider.init();
    _syncProvider = provider;
    _syncConfig = event.s3Config;
  }

  Future<void> _onStartSyncing(Emitter<SyncState> emit) async {
    if (_syncProvider == null) {
      _log.info('syncing not configured, skipping sync');
      return;
    }

    emit(state.copyWith(syncing: true, error: null, lastSyncSuccess: null));

    try {
      await WakelockPlus.enable();

      _log.info('start syncing');
      await _store.syncWith(_syncProvider!);

      _log.info('completed syncing');
      emit(state.copyWith(lastSynced: .now(), syncing: false, lastSyncSuccess: true));
    } catch (e) {
      _log.severe('failed to sync', e);
      emit(state.copyWith(syncing: false, error: e.toString(), lastSyncSuccess: false));
    } finally {
      await WakelockPlus.disable();
    }
  }

  @override
  Future<void> close() {
    if (_storeListener != null) {
      _store.removeListener(_storeListener!);
    }
    if (_preferencesListener != null) {
      PreferencesStore.instance.removeListener(_preferencesListener!);
    }
    return super.close();
  }
}
