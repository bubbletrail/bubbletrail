import 'package:logging/logging.dart';

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

  Store(this.path, {bool readonly = false})
    : computers = Computers('$path/computers.binpb', readonly: readonly),
      cylinders = Cylinders('$path/cylinders.binpb', readonly: readonly),
      dives = Dives('$path/dives', readonly: readonly),
      sites = Sites('$path/sites.binpb', readonly: readonly);

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
