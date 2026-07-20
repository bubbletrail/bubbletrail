import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

import 'package:btproto/btproto.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

// Builds a synthetic depth profile for a manually entered dive, described only
// by its start, duration and max depth. The profile is a simple descent /
// bottom / two-stage ascent, marked synthetic via the model name so it can be
// regenerated when those values are edited.
Log syntheticLog(DateTime start, int durationSeconds, double maxDepth) {
  final samples = <LogSample>[];

  // We descend at 18 m/min
  final t0 = (maxDepth / 18 * 60).roundToDouble();
  // We ascend to half depth at 9 m/min
  final t2 = (maxDepth / 2 / 9 * 60).roundToDouble();
  // We ascend from there to the surface at 3 m/min
  final t3 = (maxDepth / 2 / 3 * 60).roundToDouble();
  // The bottom time is what remains, but at least zero. If this was a very
  // odd bounce dive we might overshoot the actual duration in the graph,
  // but whatever.
  final t1 = max(0.0, durationSeconds - t0 - t2 - t3);

  samples.add(LogSample(time: 0, depth: 0));
  samples.add(LogSample(time: 5, depth: 0.1));
  samples.add(LogSample(time: t0, depth: maxDepth));
  samples.add(LogSample(time: t0 + t1, depth: maxDepth));
  samples.add(LogSample(time: t0 + t1 + t2, depth: maxDepth / 2));
  samples.add(LogSample(time: t0 + t1 + t2 + t3, depth: 0.1));
  samples.add(LogSample(time: t0 + t1 + t2 + t3 + 5, depth: 0));

  return Log(
    model: 'Bubbletrail', //marks the log as synthetic
    dateTime: Timestamp.fromDateTime(start),
    diveTime: durationSeconds,
    maxDepth: maxDepth,
    samples: samples,
  );
}

extension LogExtensions on Log {
  bool get isSynthetic => model == 'Bubbletrail';

  void setUniqueID() {
    if (hasUniqueID()) return;
    // Calculate a unique yet repeatable dive ID, if we have all the
    // information required. Any given dive computer identified by model &
    // serial should only have one dive starting at a given point in time.
    if (hasModel() && hasSerial() && hasDateTime()) {
      final unique = 'DC$model/$serial@${dateTime.seconds}';
      final hash = sha256.convert(utf8.encode(unique)).bytes;
      // Compress to a 128 bit hash by xor:ing the two halves
      final trunc = Uint8List(16);
      for (var i = 0; i < 16; i++) {
        trunc[i] = hash[i] ^ hash[i + 16];
      }
      uniqueID = hex.encode(trunc);
    }
  }

  DecoStatus? get worstDecoStatus {
    DecoStatus? worst;
    for (final sample in samples) {
      if (!sample.hasDeco()) continue;
      if (worst == null) {
        if (sample.deco.type != DecoStopType.DECO_STOP_TYPE_NDL || sample.deco.time > 0) worst = sample.deco;
        continue;
      }
      if (worst.type.value < sample.deco.type.value) {
        worst = sample.deco;
        continue;
      }
      if (worst.type == sample.deco.type) {
        switch (worst.type) {
          case DecoStopType.DECO_STOP_TYPE_DECO_STOP:
          case DecoStopType.DECO_STOP_TYPE_DEEP_STOP:
          case DecoStopType.DECO_STOP_TYPE_SAFETY_STOP:
            if (sample.deco.time > worst.time) {
              worst = sample.deco;
              continue;
            }
          case DecoStopType.DECO_STOP_TYPE_NDL:
            if (sample.deco.time < worst.time) {
              worst = sample.deco;
              continue;
            }
          case DecoStopType.DECO_STOP_TYPE_UNSPECIFIED:
            break;
        }
      }
    }
    return worst;
  }
}
