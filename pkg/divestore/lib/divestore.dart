import 'gen/gen.dart';

export 'dc_convert.dart';
export 'dive_ext.dart';
export 'gen/gen.dart';
export 'log_ext.dart';
export 'ssrf.dart';
export 'store/store.dart';
export 'uddf.dart';

class Ssrf {
  final List<Dive> dives;
  final List<Site> sites;
  Ssrf({List<Dive>? dives, List<Site>? sites}) : dives = dives ?? [], sites = sites ?? [];
}
