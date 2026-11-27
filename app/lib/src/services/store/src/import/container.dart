import 'package:btproto/btproto.dart';

class Container {
  final List<Dive> dives;
  final List<Site> sites;
  final List<Equipment> equipment;
  final bool preserveDiveSummary;

  Container({List<Dive>? dives, List<Site>? sites, List<Equipment>? equipment, this.preserveDiveSummary = false})
    : dives = dives ?? [],
      sites = sites ?? [],
      equipment = equipment ?? [];
}
