import 'dart:async';
import 'dart:io';

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
import 'package:path_provider/path_provider.dart';

const containerId = 'iCloud.app.bubbletrail';
final _log = Logger('SyncBloc');

class SyncState extends Equatable {
  final DateTime? lastSynced;
  final bool syncing;

  const SyncState({this.lastSynced, this.syncing = false});

  SyncState copyWith({DateTime? lastSynced, bool? syncing}) {
    return SyncState(lastSynced: lastSynced ?? this.lastSynced, syncing: syncing ?? this.syncing);
  }

  @override
  List<Object?> get props => [lastSynced, syncing];
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

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final _icloud = IcloudStorageSync();
  final Completer<Store> _storeCompleter = Completer();

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
    add(const StartSyncing());
  }

  Future<void> _onStartSyncing(StartSyncing event, Emitter<SyncState> emit) async {
    _log.info('start sync');
    emit(state.copyWith(syncing: true));

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

    _log.info('exporting to cloud');
    await _uploadExport();

    emit(state.copyWith(lastSynced: DateTime.now(), syncing: false));
  }

  Future<void> _uploadExport() async {
    final sourceDir = Directory(await storePath);
    final destDir = await getApplicationCacheDirectory();
    final zipPath = '${destDir.path}/db-${await systemID}.bubbletrail';
    final files = await Glob('${sourceDir.path}/*', recursive: true).list().asyncMap((e) => File(e.path)).toList();
    final zipFile = File(zipPath);
    try {
      await zipFile.delete();
    } catch (_) {}
    await ZipFile.createFromFiles(sourceDir: sourceDir, files: files, zipFile: zipFile);
    _log.info('uploading $zipPath...');
    await _icloud.upload(containerId: containerId, filePath: zipPath);
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
