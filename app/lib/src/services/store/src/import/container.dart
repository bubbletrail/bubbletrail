import 'package:btproto/btproto.dart';

class Container {
  final List<Dive> dives;
  final List<Site> sites;
  final bool preserveDiveSummary;

  Container({List<Dive>? dives, List<Site>? sites, this.preserveDiveSummary = false}) : dives = dives ?? [], sites = sites ?? [];
}
