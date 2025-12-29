import 'cylinders.dart';
import 'dives.dart';
import 'sites.dart';

class Store {
  final Cylinders cylinders = Cylinders();
  final Sites sites = Sites();
  final Dives dives = Dives();

  Set<String> get tags => sites.tags.union(dives.tags);
}
