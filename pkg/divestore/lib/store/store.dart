import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';

import '../archive/archiveprovider.dart';
import '../gen/dive.pb.dart';
import '../gen/dive_ext.dart';
import '../sync/syncprovider.dart';
import 'computers.dart';
import 'cylinders.dart';
import 'dives.dart';
import 'sites.dart';

final _log = Logger('store/store.dart');

class Store {
  final String path;

  final Computers computers;
  final Cylinders cylinders;
  final Dives dives;
  final Sites sites;

  final _changes = StreamController<void>.broadcast();
  Timer? _changesTimer;
  Stream<void> get changes => _changes.stream;

  Store(this.path, {bool readonly = false})
    : computers = Computers('$path/computers.binpb', readonly: readonly),
      cylinders = Cylinders('$path/cylinders.binpb', readonly: readonly),
      dives = Dives('$path/dives', readonly: readonly),
      sites = Sites('$path/sites.binpb', readonly: readonly) {
    computers.changes.listen((_) => _scheduleChange());
    cylinders.changes.listen((_) => _scheduleChange());
    dives.changes.listen((_) => _scheduleChange());
    sites.changes.listen((_) => _scheduleChange());
  }

  void _scheduleChange() {
    _changesTimer?.cancel();
    _changesTimer = Timer(Duration(seconds: 5), () => _changes.add(null));
  }

  Future<void> init() async {
    await computers.init();
    await cylinders.init();
    await dives.init();
    await sites.init();
  }

  Set<String> get tags => sites.tags.union(dives.tags);

  Future<void> syncWith(SyncProvider provider) async {
    try {
      await computers.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync computers', e);
    }
    try {
      await cylinders.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync cylinders', e);
    }
    try {
      await sites.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync sites', e);
    }
    try {
      await dives.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync dives', e);
    }
  }

  Future<void> exportTo(ArchiveExportProvider provider) async {
    _log.info('exporting store to archive');
    await provider.writeObjects(_exportObjects());
    _log.info('export complete');
  }

  Stream<ArchiveObject> _exportObjects() async* {
    await for (final match in Glob(path, recursive: true).list()) {
      if (match is! File) continue;
      final file = match as File;
      final key = file.path.substring(path.length + 1);
      final data = await file.readAsBytes();
      _log.fine('exported $key');
      yield ArchiveObject(key, data);
    }
  }

  Future<void> importFrom(ArchiveImportProvider provider) async {
    _log.info('importing store from archive');

    // Move existing database out of the way
    final dbDir = Directory(path);
    if (await dbDir.exists()) {
      final backupPath = '$path.backup.${DateTime.now().millisecondsSinceEpoch}';
      _log.info('moving existing database to $backupPath');
      await dbDir.rename(backupPath);
    }

    // Create fresh database directory
    await dbDir.create(recursive: true);

    // Import archive data
    await for (final obj in provider.readObjects()) {
      final file = File('$path/${obj.key}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(obj.data);
      _log.fine('imported ${obj.key}');
    }

    _log.info('reinitializing stores');
    await init();
    _log.info('import complete');
  }

  Future<Dive?> diveById(String diveID) async {
    final dive = await dives.getById(diveID);
    if (dive == null) {
      return null;
    }
    try {
      final mappedCyls = <DiveCylinder>[];
      for (var dc in dive.cylinders) {
        final cyl = await cylinders.getById(dc.cylinderId);
        if (cyl != null) {
          dc = dc.rebuild((dc) {
            dc.cylinder = cyl;
          });
        }
        mappedCyls.add(dc);
      }
      return dive.rebuild((dive) {
        dive.cylinders.clear();
        dive.cylinders.addAll(mappedCyls);
        dive.recalculateMedata();
      });
    } catch (e) {
      _log.warning('failed to load dive $diveID', e);
      return null;
    }
  }
}
