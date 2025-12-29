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
}
