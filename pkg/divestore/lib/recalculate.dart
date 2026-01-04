import 'dart:math';

import 'package:divestore/gen/dive.pb.dart';
import 'package:divestore/gen/gen.dart';

extension RecalculateMetadata on Dive {
  void recalculateMedata() {
    // Process samples, calculating depths, durations, etc.

    double maxDepth = 0.0;
    double totDepth = 0.0;
    double prevDepth = 0.0;
    double prevTime = 0.0;
    double duration = 0;

    for (final dl in this.logs) {
      for (final sample in dl.samples) {
        // Collect tank pressures
        for (final pressure in sample.pressures) {
          if (pressure.tankIndex < this.cylinders.length) {
            final t = this.cylinders[pressure.tankIndex];
            if (!t.hasBeginPressure()) t.beginPressure = pressure.pressure;
            t.endPressure = pressure.pressure;
          }
        }

        // Collect depths
        maxDepth = max(maxDepth, sample.depth);
        totDepth += (sample.depth + prevDepth) / 2 * (sample.time - prevTime);
        prevTime = sample.time;
        prevDepth = sample.depth;
        if (sample.depth > 0) {
          duration = sample.time;
        }

        // Collect events
        for (final event in sample.events) {
          this.events.add(event);
        }
      }
    }

    this.duration = duration.round();
    this.maxDepth = maxDepth;
    this.meanDepth = totDepth / duration;
  }
}
