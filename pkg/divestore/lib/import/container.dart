import '../gen/gen.dart';

class Ssrf {
  final List<Dive> dives;
  final List<Site> sites;
  Ssrf({List<Dive>? dives, List<Site>? sites}) : dives = dives ?? [], sites = sites ?? [];
}
