import 'package:logging/logging.dart';

import '../gen/dive.pb.dart';
import '../gen/dive_ext.dart';
import '../sync/syncprovider.dart';
import 'cylinders.dart';
import 'dives.dart';
import 'sites.dart';

final _log = Logger('store/store.dart');

class Store {
  final String path;

  final Cylinders cylinders;
  final Sites sites;
  final Dives dives;

  Store(this.path, {bool readonly = false})
    : cylinders = Cylinders('$path/cylinders.binpb', readonly: readonly),
      sites = Sites('$path/sites.binpb', readonly: readonly),
      dives = Dives('$path/dives', readonly: readonly);

  Future<void> init() async {
    await cylinders.init();
    await sites.init();
    await dives.init();
  }

  Set<String> get tags => sites.tags.union(dives.tags);

  Future<void> syncWith(SyncProvider provider) async {
    try {
      await cylinders.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync cylinders: $e');
    }
    try {
      await sites.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync sites: $e');
    }
    try {
      await dives.syncWith(provider);
    } catch (e) {
      _log.warning('failed to sync dives: $e');
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
      _log.warning('failed to load dive $diveID: $e');
      return null;
    }
  }
}
