import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../preferences/preferences.dart';
import '../providers/s3_provider.dart';
import '../providers/storage_provider.dart';

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

class SyncEvent {
  const SyncEvent();
}

class _InitStore extends SyncEvent {
  const _InitStore();
}

class StartSyncing extends SyncEvent {
  const StartSyncing();
}

class UpdateSyncConfig extends SyncEvent {
  final SyncProviderKind provider;
  final S3Config s3Config;

  const UpdateSyncConfig({required this.provider, required this.s3Config});
}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncProvider? _syncProvider;
  S3Config? _syncConfig;
  Timer? _syncDebounceTimer;

  SyncBloc() : super(SyncState()) {
    on<SyncEvent>((event, emit) async {
      if (event is _InitStore) {
        await _onInitStore(event, emit);
      } else if (event is UpdateSyncConfig) {
        if (event.provider == .none) return;
        if (!event.s3Config.isConfigured) return;
        await _onUpdateConfig(event);
      } else if (event is StartSyncing) {
        await _onStartSyncing(event, emit);
      }
    }, transformer: sequential());

    add(const _InitStore());
  }

  Future<void> _onInitStore(_InitStore event, Emitter<SyncState> emit) async {
    _log.fine('init');
    final store = await StorageProvider.store;
    store.changes.listen((_) {
      _syncDebounceTimer?.cancel();
      _syncDebounceTimer = Timer(Duration(seconds: 60), () => add(StartSyncing()));
    });

    add(StartSyncing());
  }

  Future<void> _onUpdateConfig(UpdateSyncConfig event) async {
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

  Future<void> _onStartSyncing(StartSyncing event, Emitter<SyncState> emit) async {
    if (_syncProvider == null) {
      _log.warning('syncing not configured, skipping sync');
      emit(state.copyWith(error: 'Syncing not configured', lastSyncSuccess: false));
      return;
    }

    emit(state.copyWith(syncing: true, error: null, lastSyncSuccess: null));

    try {
      await WakelockPlus.enable();

      _log.info('start syncing');
      final s = await StorageProvider.store;
      await s.syncWith(_syncProvider!);

      _log.info('completed syncing');
      emit(state.copyWith(lastSynced: .now(), syncing: false, lastSyncSuccess: true));
    } catch (e) {
      _log.severe('failed to sync', e);
      emit(state.copyWith(syncing: false, error: e.toString(), lastSyncSuccess: false));
    } finally {
      await WakelockPlus.disable();
    }
  }
}
