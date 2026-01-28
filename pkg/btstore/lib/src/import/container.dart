import 'package:btmodels/btmodels.dart';

class Container {
  final List<Dive> dives;
  final List<Site> sites;
  Container({List<Dive>? dives, List<Site>? sites}) : dives = dives ?? [], sites = sites ?? [];
}
