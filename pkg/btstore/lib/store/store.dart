import 'dart:async';
import 'dart:io';

import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../archive/archiveprovider.dart';
import '../gen/gen.dart';
import '../sync/syncprovider.dart';
import 'computer_store.dart';
import 'cylinder_store.dart';
import 'dive_store.dart';
import 'equipment_store.dart';
import 'site_store.dart';

final _log = Logger('store.dart');

class Store {
  final String path;

  final ComputerStore computers;
  final CylinderStore cylinders;
  final btstore dives;
  final EquipmentStore equipment;
  final SiteStore sites;

  final _changes = StreamController<void>.broadcast();
  Timer? _changesTimer;
  Stream<void> get changes => _changes.stream;

  Store(this.path)
    : computers = ComputerStore('$path/computers.binpb'),
      cylinders = CylinderStore('$path/cylinders.binpb'),
      dives = btstore('$path/dives'),
      equipment = EquipmentStore('$path/equipment.binpb'),
      sites = SiteStore('$path/sites.binpb') {
    computers.changes.listen((_) => _scheduleChange());
    cylinders.changes.listen((_) => _scheduleChange());
    dives.changes.listen((_) => _scheduleChange());
    equipment.changes.listen((_) => _scheduleChange());
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
    await equipment.init();
    await sites.init();
  }

  Future<void> reset() async {
    // Move the database out of the way, clear internal state.
    _log.warning('resetting database');
    try {
      final ts = DateFormat('yyyyMMdd-HHmmss').format(DateTime.now());
      await Directory(path).rename('$path.removed-$ts');
    } on PathNotFoundException {
      // No worries, there just wasn't a database already
    } catch (e) {
      _log.warning('failed to reset database', e);
    }
    await init();
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
      await equipment.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync equipment', e);
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
        dive.recalculateMetadata();
      });
    } catch (e) {
      _log.warning('failed to load dive $diveID', e);
      return null;
    }
  }

  Future<void> deleteSite(String siteID) async {
    // Remove site from any dives currently using it
    for (final dive in await dives.getAll()) {
      if (dive.siteId == siteID) {
        await dives.update(
          dive.rebuild((dive) {
            dive.clearSiteId();
          }),
        );
      }
    }
    // Remove the site itself
    await sites.delete(siteID);
  }
}
