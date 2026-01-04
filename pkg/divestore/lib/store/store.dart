import 'package:divestore/gen/dive.pb.dart';

import 'cylinders.dart';
import 'dives.dart';
import 'sites.dart';

class Store {
  final String path;

  final Cylinders cylinders;
  final Sites sites;
  final Dives dives;

  Store(this.path, {bool readonly = false})
    : cylinders = Cylinders("$path/cylinders.binpb", readonly: readonly),
      sites = Sites("$path/sites.binpb", readonly: readonly),
      dives = Dives("$path/dives", readonly: readonly);

  Future<void> init() async {
    await cylinders.init();
    await sites.init();
    await dives.init();
  }

  Set<String> get tags => sites.tags.union(dives.tags);

  Future<void> importFrom(Store other) async {
    await cylinders.importFrom(other.cylinders);
    await sites.importFrom(other.sites);
    await dives.importFrom(other.dives);
  }

  Future<Dive?> diveById(String diveID) async {
    final dive = await dives.getById(diveID);
    if (dive == null) {
      return null;
    }
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
    });
  }
}
