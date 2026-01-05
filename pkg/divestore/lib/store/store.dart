import '../gen/dive.pb.dart';
import '../dive_ext.dart';
import '../gen/types.pb.dart';
import 'cylinders.dart';
import 'dives.dart';
import 'sites.dart';

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

  Future<void> importFrom(Store other) async {
    await cylinders.importFrom(other.cylinders);
    await sites.importFrom(other.sites);
    await dives.importFrom(other.dives);

    // Deduplicate dives, in case of separate previous imports etc
    final byUnique = <String, Dive>{};
    for (final dive in await dives.getAll()) {
      if (dive.logs.isEmpty) continue;
      if (!dive.logs.first.hasUniqueID()) continue;
      final key = dive.logs.first.uniqueID;
      final exist = byUnique[key];
      if (exist != null) {
        // Duplicate. Keep the last modified.
        if (exist.updatedAt.toDateTime().isAfter(dive.updatedAt.toDateTime())) {
          await (dives.delete(dive.id));
          continue;
        } else {
          await (dives.delete(exist.id));
        }
      }
      byUnique[key] = dive;
    }

    // Deduplicate cylinders
    final uniqueCyls = <String, Cylinder>{};
    for (final cyl in await cylinders.getAll()) {
      final key = '${cyl.size}/${cyl.workpressure}';
      final exist = uniqueCyls[key];
      if (exist != null) {
        await (cylinders.delete(cyl.id));
        await _replaceCylinder(cyl.id, exist.id);
      } else {
        uniqueCyls[key] = cyl;
      }
    }
  }

  // Replace cylinder IDs in all dives
  Future<void> _replaceCylinder(String fromID, String toID) async {
    for (final d in await dives.getAll()) {
      if (d.cylinders.any((c) => c.cylinderId == fromID)) {
        await dives.update(
          d.rebuild((d) {
            for (final c in d.cylinders) {
              if (c.cylinderId == fromID) {
                d.cylinders[0] = c.rebuild((c) {
                  c.cylinderId = toID;
                });
              }
            }
          }),
        );
      }
    }
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
      dive.recalculateMedata();
    });
  }
}
