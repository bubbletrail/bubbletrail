import 'package:btproto/btproto.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../ext/ext.dart';
import 'container.dart';

// The Suunto JSON ("DeviceLog") format is a general fitness/workout export
// shared across watches, so the vast majority of its fields are irrelevant to
// scuba (steps, training load, GPS routes, swim strokes, ...). We pick out only
// the diving-relevant bits. Each file contains exactly one dive.

const double _kelvinOffset = 273.15;
const double _pascalToBar = 1e-5;

double? _kelvinToCelsius(num? k) => k != null ? k.toDouble() - _kelvinOffset : null;
double? _pascalToBarConvert(num? pa) => pa != null ? pa.toDouble() * _pascalToBar : null;

Map<String, dynamic>? _asMap(dynamic v) => v is Map<String, dynamic> ? v : null;
List<dynamic>? _asList(dynamic v) => v is List ? v : null;
num? _asNum(dynamic v) => v is num ? v : null;

// Suunto uses the literal string "null" for some empty text fields (e.g. Notes,
// Activity), so treat those as absent too.
String? _asString(dynamic v) => (v is String && v.isNotEmpty && v != 'null') ? v : null;

// Walk a chain of map keys, returning null if any level is missing.
dynamic _dig(Map<String, dynamic>? m, List<String> path) {
  dynamic cur = m;
  for (final key in path) {
    if (cur is! Map<String, dynamic>) return null;
    cur = cur[key];
  }
  return cur;
}

// A depth profile sample kept with its absolute timestamp so we can compute
// dive-relative times and match events to the nearest sample.
class _ProfileSample {
  final DateTime time;
  final Map<String, dynamic> data;
  final double? temperature;
  _ProfileSample(this.time, this.data, this.temperature);
}

// Accumulates begin/end pressure for a cylinder across the profile.
class _CylinderUsage {
  double? beginPressure;
  double? endPressure;
}

extension SuuntoJson on Container {
  // Parse a single-dive Suunto JSON document into a Container.
  static Container fromJson(Map<String, dynamic> json) {
    final deviceLog = _asMap(json['DeviceLog']);
    if (deviceLog == null) {
      throw const FormatException('Not a Suunto JSON dive log: missing DeviceLog');
    }
    return Container(dives: [_SuuntoDive.fromJson(deviceLog)]);
  }
}

extension _SuuntoDive on Dive {
  static Dive fromJson(Map<String, dynamic> deviceLog) {
    final header = _asMap(deviceLog['Header']) ?? const {};
    final device = _asMap(deviceLog['Device']);
    final samples = _asList(deviceLog['Samples']) ?? const [];

    // Start time (ISO8601 with timezone offset).
    final startStr = _asString(header['DateTime']);
    final start = startStr != null ? DateTime.tryParse(startStr) : null;

    // Summary numbers. DiveTime is the time submerged (Duration also counts
    // surface time before/after), so it's the right value for dive duration.
    final maxDepth = _asNum(_dig(header, ['Depth', 'Max']))?.toDouble();
    final avgDepth = _asNum(header['DepthAverage'])?.toDouble();
    final diveTime = _asNum(header['DiveTime'])?.toDouble();

    // Temperature is reported in Kelvin as a Min/Max pair, but the labels are
    // unreliable (Max is sometimes lower than Min), so derive the real extremes.
    final tempA = _asNum(_dig(header, ['Temperature', 'Max']));
    final tempB = _asNum(_dig(header, ['Temperature', 'Min']));
    double? minTemp;
    double? maxTemp;
    final temps = [tempA, tempB].whereType<num>().toList();
    if (temps.isNotEmpty) {
      minTemp = _kelvinToCelsius(temps.reduce((a, b) => a < b ? a : b));
      maxTemp = _kelvinToCelsius(temps.reduce((a, b) => a > b ? a : b));
    }

    final notes = _asString(header['Notes']);
    final model = _asString(device?['Name']);
    final serial = _asString(device?['SerialNumber']);

    // First pass over samples: collect the depth profile, cylinder usage, gas
    // switch events, atmospheric pressure and the GPS fix.
    final profile = <_ProfileSample>[];
    final gasSwitches = <({DateTime time, int gas})>[];
    final cylinderUsage = <int, _CylinderUsage>{};
    double? atmosphericBar;
    Position? position;

    double? temperature;
    for (final raw in samples) {
      final s = _asMap(raw);
      if (s == null) continue;

      final timeStr = _asString(s['TimeISO8601']);
      final time = timeStr != null ? DateTime.tryParse(timeStr) : null;

      // Temperature lives in its own (surface-pressure) samples, separate from
      // the depth samples. Track the most recent reading so each depth sample
      // picks up the closest temperature seen prior to it.
      final sampleTemp = _kelvinToCelsius(_asNum(s['Temperature']));
      if (sampleTemp != null) temperature = sampleTemp;

      // Depth profile sample.
      final depth = _asNum(s['Depth']);
      if (depth != null && time != null) {
        profile.add(_ProfileSample(time, s, temperature));

        // Track which cylinders are actually used and their pressure range.
        for (final c in _asList(s['Cylinders']) ?? const []) {
          final cm = _asMap(c);
          if (cm == null) continue;
          final gas = _asNum(cm['GasNumber'])?.toInt();
          if (gas == null) continue;
          final pressure = _asNum(cm['Pressure'])?.toDouble();
          final gasTime = _asNum(cm['GasTime'])?.toDouble() ?? 0;
          // A cylinder counts as used only if it ever shows pressure or breathing
          // time; Suunto always lists all five gas slots even when empty.
          if (pressure != null || gasTime > 0) {
            final usage = cylinderUsage.putIfAbsent(gas, () => _CylinderUsage());
            if (pressure != null) {
              usage.beginPressure ??= pressure;
              usage.endPressure = pressure;
            }
          }
        }
      }

      // Atmospheric pressure from the first surface-pressure reading (Pa).
      atmosphericBar ??= _pascalToBarConvert(_asNum(s['SurfacePressure']));

      // GPS fix from the dive route origin (already in degrees, unlike the raw
      // Latitude/Longitude samples which are in radians).
      if (position == null) {
        final origin = _asMap(s['DiveRouteOrigin']);
        final lat = _asNum(origin?['Latitude'])?.toDouble();
        final lon = _asNum(origin?['Longitude'])?.toDouble();
        if (lat != null && lon != null) {
          position = Position(latitude: lat, longitude: lon, altitude: _asNum(origin?['Altitude'])?.toDouble());
        }
      }

      // Gas switch events.
      final gasSwitch = _asMap(_dig(s, ['DiveEvents', 'GasSwitch']));
      final gas = _asNum(gasSwitch?['GasNumber'])?.toInt();
      if (gas != null && time != null) {
        gasSwitches.add((time: time, gas: gas));
      }
    }

    // Build cylinders for the used gas slots, mapping gas number to index.
    final cylinders = <DiveCylinder>[];
    final gasToCylinderIdx = <int, int>{};
    for (final gas in cylinderUsage.keys.toList()..sort()) {
      final usage = cylinderUsage[gas]!;
      gasToCylinderIdx[gas] = cylinders.length;
      cylinders.add(
        DiveCylinder(
          // Suunto JSON does not record gas composition, so assume air.
          oxygen: 0.21,
          helium: 0.0,
          beginPressure: _pascalToBarConvert(usage.beginPressure),
          endPressure: _pascalToBarConvert(usage.endPressure),
        ),
      );
    }

    // Build the log samples.
    final logSamples = <LogSample>[];
    for (final ps in profile) {
      final s = ps.data;
      final time = start != null ? ps.time.difference(start).inMilliseconds / 1000.0 : 0.0;
      final sample = LogSample(time: time, depth: _asNum(s['Depth'])!.toDouble(), temperature: ps.temperature);

      for (final c in _asList(s['Cylinders']) ?? const []) {
        final cm = _asMap(c);
        final gas = _asNum(cm?['GasNumber'])?.toInt();
        final pressure = _asNum(cm?['Pressure'])?.toDouble();
        final idx = gas != null ? gasToCylinderIdx[gas] : null;
        if (idx != null && pressure != null) {
          sample.pressures.add(TankPressure(tankIndex: idx, pressure: pressure * _pascalToBar));
        }
      }

      // Decompression status. A non-zero ceiling means an active deco stop;
      // otherwise we're within no-deco limits.
      final ceiling = _asNum(s['Ceiling'])?.toDouble();
      final tts = _asNum(s['TimeToSurface'])?.toInt();
      final noDec = _asNum(s['NoDecTime'])?.toInt();
      if (ceiling != null && ceiling > 0) {
        sample.deco = DecoStatus(type: DecoStopType.DECO_STOP_TYPE_DECO_STOP, depth: ceiling, tts: tts);
      } else if (noDec != null) {
        sample.deco = DecoStatus(type: DecoStopType.DECO_STOP_TYPE_NDL, time: noDec, tts: tts);
      }

      logSamples.add(sample);
    }

    // Attach gas switches to the nearest profile sample.
    for (final sw in gasSwitches) {
      final idx = gasToCylinderIdx[sw.gas];
      if (idx == null) continue; // Switch to an unused/empty cylinder, ignore.
      final sampleIdx = _nearestSampleIndex(profile, sw.time);
      if (sampleIdx == null) continue;
      logSamples[sampleIdx].events.add(SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: logSamples[sampleIdx].time.toInt(), value: idx));
    }

    // Assemble the log.
    final log = Log(
      model: model,
      serial: serial,
      maxDepth: maxDepth,
      avgDepth: avgDepth,
      minTemperature: minTemp,
      maxTemperature: maxTemp,
      diveTime: diveTime?.toInt(),
      atmosphericPressure: atmosphericBar,
      position: position,
    );
    if (cylinders.isNotEmpty) {
      log.diveMode = DiveMode.DIVE_MODE_OPENCIRCUIT;
    }
    log.samples.addAll(logSamples);
    if (start != null) {
      log.dateTime = Timestamp.fromDateTime(start);
    }
    log.setUniqueID();

    // Assemble the dive. Suunto JSON has no human dive number, so leave it 0.
    final dive = Dive(
      id: const Uuid().v4(),
      start: start != null ? Timestamp.fromDateTime(start) : null,
      duration: diveTime?.toInt(),
      maxDepth: maxDepth,
      meanDepth: avgDepth,
      minTemp: minTemp,
      maxTemp: maxTemp,
      notes: notes,
    );
    dive.cylinders.addAll(cylinders);
    dive.logs.add(log);
    return dive;
  }
}

// Index of the profile sample closest in time to [target], or null if empty.
int? _nearestSampleIndex(List<_ProfileSample> profile, DateTime target) {
  int? best;
  int bestDiff = 0;
  for (var i = 0; i < profile.length; i++) {
    final diff = (profile[i].time.difference(target).inMilliseconds).abs();
    if (best == null || diff < bestDiff) {
      best = i;
      bestDiff = diff;
    }
  }
  return best;
}
