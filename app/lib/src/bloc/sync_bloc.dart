import 'dart:async';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../preferences/preferences.dart';
import 's3_provider.dart';

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
  final Completer<Store> _storeCompleter = Completer();

  SyncProviderKind _syncProvider = SyncProviderKind.none;
  S3Config _s3Config = const S3Config();

  Future<Store> get store => _storeCompleter.future;
  Future<String> get storePath async => '${(await getApplicationDocumentsDirectory()).path}/db';

  Future<String> get systemID async {
    final di = DeviceInfoPlugin();
    late final String hash;
    if (Platform.isIOS) {
      final info = await di.iosInfo;
      final dig = sha256.convert((info.identifierForVendor ?? '').codeUnits);
      hash = dig.toString();
    } else if (Platform.isMacOS) {
      final info = await di.macOsInfo;
      final dig = sha256.convert((info.systemGUID ?? '').codeUnits);
      hash = dig.toString();
    } else {
      throw Exception('unimplemented platform');
    }
    return hash.substring(0, 12);
  }

  SyncBloc() : super(SyncState()) {
    on<SyncEvent>((event, emit) async {
      if (event is _InitStore) {
        await _onInitStore(event, emit);
      } else if (event is StartSyncing) {
        await _onStartSyncing(event, emit);
      } else if (event is UpdateSyncConfig) {
        _syncProvider = event.provider;
        _s3Config = event.s3Config;
      }
    }, transformer: sequential());

    add(const _InitStore());
  }

  Future<void> _onInitStore(_InitStore event, Emitter<SyncState> emit) async {
    _log.fine('init storage');
    final dir = await storePath;
    final store = Store(dir);
    await store.init();
    _storeCompleter.complete(store);
    add(StartSyncing());
  }

  Future<void> _onStartSyncing(StartSyncing event, Emitter<SyncState> emit) async {
    _log.info('start sync with provider: $_syncProvider');

    switch (_syncProvider) {
      case SyncProviderKind.none:
        return;
      case SyncProviderKind.bubbletrail:
      case SyncProviderKind.s3:
        await _syncWithS3(emit);
    }
  }

  Future<void> _syncWithS3(Emitter<SyncState> emit) async {
    if (!_s3Config.isConfigured) {
      _log.warning('syncing not configured, skipping sync');
      emit(state.copyWith(error: 'Syncing not configured', lastSyncSuccess: false));
      return;
    }

    emit(state.copyWith(syncing: true, error: null, lastSyncSuccess: null));

    try {
      _log.fine('initialize syncing provider ${_s3Config.endpoint}');
      final provider = S3SyncProvider(
        endpoint: _s3Config.endpoint,
        bucket: _s3Config.bucket,
        accessKey: _s3Config.accessKey,
        secretKey: _s3Config.secretKey,
        vaultKey: _s3Config.vaultKey,
      );
      await provider.init();

      _log.info('start syncing');
      final s = await store;
      await s.syncWith(provider);

      _log.info('completed syncing');
      emit(state.copyWith(lastSynced: DateTime.now(), syncing: false, lastSyncSuccess: true));
    } catch (e) {
      _log.severe('failed to sync: $e');
      emit(state.copyWith(syncing: false, error: e.toString(), lastSyncSuccess: false));
    }
  }
}
