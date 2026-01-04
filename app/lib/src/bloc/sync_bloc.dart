import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:icloud_storage_sync/icloud_storage_sync.dart';
import 'package:logging/logging.dart';
import 'package:minio/minio.dart';
import 'package:path_provider/path_provider.dart';

import '../preferences/preferences.dart';

const containerId = 'iCloud.app.bubbletrail';
const _fileExtension = '.bubbletrail';
final _log = Logger('SyncBloc');

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
  final SyncProvider provider;
  final S3Config s3Config;

  const UpdateSyncConfig({required this.provider, required this.s3Config});
}

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final _icloud = IcloudStorageSync();
  final Completer<Store> _storeCompleter = Completer();

  SyncProvider _syncProvider = SyncProvider.none;
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
    _log.info('init storage');
    final dir = await storePath;
    final store = Store(dir);
    await store.init();
    _storeCompleter.complete(store);
  }

  Future<void> _onStartSyncing(StartSyncing event, Emitter<SyncState> emit) async {
    _log.info('start sync with provider: $_syncProvider');

    switch (_syncProvider) {
      case SyncProvider.none:
        _log.info('sync disabled');
        return;
      case SyncProvider.icloud:
        await _syncWithICloud(emit);
      case SyncProvider.s3:
        await _syncWithS3(emit);
    }
  }

  // ============ iCloud Sync ============

  Future<void> _syncWithICloud(Emitter<SyncState> emit) async {
    emit(state.copyWith(syncing: true, error: null, lastSyncSuccess: null));

    try {
      final myID = await systemID;
      final files = await _icloud.getCloudFiles(containerId: containerId);
      for (final file in files) {
        if (file.relativePath?.contains(myID) == true) {
          _log.fine('skipping ${file.relativePath} exported by ourselves');
        } else {
          _log.info('syncing with export ${file.relativePath}');
          await _mergeWithExport(file.filePath);
        }
      }

      _log.info('exporting to iCloud');
      await _uploadToICloud();

      emit(state.copyWith(lastSynced: DateTime.now(), syncing: false, lastSyncSuccess: true));
    } catch (e) {
      _log.severe('iCloud sync failed: $e');
      emit(state.copyWith(syncing: false, error: e.toString(), lastSyncSuccess: false));
    }
  }

  Future<void> _uploadToICloud() async {
    final zipPath = await _createExportZip();
    _log.info('uploading $zipPath to iCloud...');
    await _icloud.upload(containerId: containerId, filePath: zipPath);
  }

  // ============ S3 Sync ============

  Future<void> _syncWithS3(Emitter<SyncState> emit) async {
    if (!_s3Config.isConfigured) {
      _log.warning('S3 not configured, skipping sync');
      emit(state.copyWith(error: 'S3 not configured', lastSyncSuccess: false));
      return;
    }

    emit(state.copyWith(syncing: true, error: null, lastSyncSuccess: null));

    try {
      final minio = Minio(endPoint: _s3Config.endpoint, accessKey: _s3Config.accessKey, secretKey: _s3Config.secretKey, region: _s3Config.region, useSSL: true);

      final myID = await systemID;

      // List and download other instances' exports
      _log.info('listing objects in bucket ${_s3Config.bucket}');
      await for (final objects in minio.listObjects(_s3Config.bucket)) {
        for (final obj in objects.objects) {
          final key = obj.key;
          if (key == null) continue;

          if (!key.endsWith(_fileExtension)) {
            _log.fine('skipping non-export file: $key');
            continue;
          }

          if (key.contains(myID)) {
            _log.fine('skipping $key exported by ourselves');
            continue;
          }

          _log.info('downloading export: $key');
          await _downloadAndMergeS3Export(minio, key);
        }
      }

      // Upload our export
      _log.info('exporting to S3');
      await _uploadToS3(minio);

      emit(state.copyWith(lastSynced: DateTime.now(), syncing: false, lastSyncSuccess: true));
    } catch (e) {
      _log.severe('S3 sync failed: $e');
      emit(state.copyWith(syncing: false, error: e.toString(), lastSyncSuccess: false));
    }
  }

  Future<void> _downloadAndMergeS3Export(Minio minio, String key) async {
    final dir = await getApplicationCacheDirectory();
    final localPath = '${dir.path}/$key';

    // Download the file
    final stream = await minio.getObject(_s3Config.bucket, key);
    final file = File(localPath);
    await file.create(recursive: true);
    final sink = file.openWrite();
    await stream.pipe(sink);

    // Merge with our store
    await _mergeWithExport(localPath);

    // Clean up
    try {
      await file.delete();
    } catch (_) {}
  }

  Future<void> _uploadToS3(Minio minio) async {
    final zipPath = await _createExportZip();
    final file = File(zipPath);
    final fileName = 'db-${await systemID}$_fileExtension';

    _log.info('uploading $fileName to S3...');

    final bytes = await file.readAsBytes();
    await minio.putObject(_s3Config.bucket, fileName, Stream<Uint8List>.value(bytes), onProgress: (uploaded) => _log.fine('uploaded $uploaded bytes'));
  }

  // ============ Common ============

  Future<String> _createExportZip() async {
    final sourceDir = Directory(await storePath);
    final destDir = await getApplicationCacheDirectory();
    final zipPath = '${destDir.path}/db-${await systemID}$_fileExtension';
    final files = await Glob('${sourceDir.path}/*', recursive: true).list().asyncMap((e) => File(e.path)).toList();
    final zipFile = File(zipPath);
    try {
      await zipFile.delete();
    } catch (_) {}
    await ZipFile.createFromFiles(sourceDir: sourceDir, files: files, zipFile: zipFile);
    return zipPath;
  }

  Future<void> _mergeWithExport(String path) async {
    final dir = await getApplicationCacheDirectory();
    final tmp = '${dir.path}/temp${DateTime.now().microsecondsSinceEpoch}';
    await ZipFile.extractToDirectory(zipFile: File(path), destinationDir: Directory(tmp));
    final tst = Store(tmp);
    await tst.init();
    await (await store).importFrom(tst);
  }
}
