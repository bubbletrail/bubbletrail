import 'dart:math';

import 'gen.dart';

extension DiveExtensions on Dive {
  void recalculateMedata() {
    // Process samples, calculating depths, durations, etc.

    // We want to update only cylinder that don't already have pressure data
    // (it may have been manually edited).
    final updateTankIndexes = Set<int>();
    for (final (idx, cyl) in this.cylinders.indexed) {
      if (!cyl.hasBeginPressure() || !cyl.hasEndPressure()) {
        this.cylinders[idx] = cyl.deepCopy(); // make sure it's writable
        updateTankIndexes.add(idx); // mark for update
      }
    }

    // We need to figure out the in-use spans for each cylinder.
    final spans = <({int start, int end, int idx})>[];

    // We start at time zero on the first cylinder.
    var t = 0;
    var idx = 0;

    // For every gas switch we end the previous span and open a new one.
    for (final event in this.events) {
      if (event.type != SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE) continue;
      var newIdx = event.value;
      if (newIdx > this.cylinders.length) newIdx = this.cylinders.length - 1;
      if (idx != newIdx) {
        spans.add((start: t, end: event.time, idx: idx));
        t = event.time;
        idx = newIdx;
      }
    }

    // At the end, consume the rest of the dive for the current cylinder.
    spans.add((start: t, end: this.duration, idx: idx));

    // We will need to track duration and depth for each span.
    final perCylinderDepth = <int, ({double duration, double totDepth})>{};

    double maxDepth = 0.0;
    double totDepth = 0.0;
    double duration = 0;
    double prevDepth = 0.0;
    double prevTime = 0.0;

    if (this.logs.isNotEmpty) {
      // Calculate depths etc based on samples.
      final dl = this.logs.first;
      for (final sample in dl.samples) {
        // Temperature bounds
        if (sample.hasTemperature()) {
          if (!this.hasMaxTemp() || sample.temperature > this.maxTemp) this.maxTemp = sample.temperature;
          if (!this.hasMinTemp() || sample.temperature < this.minTemp) this.minTemp = sample.temperature;
        }

        // Collect and update tank pressures as required
        for (final pressure in sample.pressures) {
          if (updateTankIndexes.contains(pressure.tankIndex)) {
            final t = this.cylinders[pressure.tankIndex];
            if (!t.hasBeginPressure()) t.beginPressure = pressure.pressure;
            t.endPressure = pressure.pressure;
          }
        }

        // Collect depths
        maxDepth = max(maxDepth, sample.depth);
        final sampleDepth = (sample.depth + prevDepth) / 2;
        final sampleDuration = sample.time - prevTime;
        totDepth += sampleDepth * sampleDuration;
        prevTime = sample.time;
        prevDepth = sample.depth;
        if (sample.depth > 0) {
          duration = sample.time;
        }

        // For the relevant cylinder
        try {
          final cylIdx = spans.firstWhere((s) => s.end >= sample.time).idx;
          final cur = perCylinderDepth[cylIdx] ?? (duration: 0, totDepth: 0);
          perCylinderDepth[cylIdx] = (duration: cur.duration + sampleDuration, totDepth: cur.totDepth + sampleDepth * sampleDuration);
        } catch (StateError) {}
      }

      // Update cylinder used gas volumes now that we know pressures
      for (var (idx, cyl) in this.cylinders.indexed) {
        if (cyl.isFrozen) cyl = cyl.deepCopy();
        cyl.usedVolume = cyl.cylinder.volumeL * (cyl.beginPressure - cyl.endPressure);
        this.cylinders[idx] = cyl;
      }

      // Calculate total dive SAC based on the sum of all cylinders
      final totVolume = this.cylinders.fold(0.0, (tot, cyl) => tot + cyl.usedVolume);
      if (totVolume > 0) {
        this.sac = totVolume / (1.0 + meanDepth / 10.0) / (duration / 60);
      } else {
        this.clearSac();
      }

      // Calculate per cylinder SAC
      for (final e in perCylinderDepth.entries) {
        final avgDepth = e.value.totDepth / e.value.duration;
        final avgATA = 1.0 + avgDepth / 10.0;
        final durationMin = e.value.duration / 60.0;
        var cyl = this.cylinders[e.key];

        if (cyl.isFrozen) cyl = cyl.deepCopy();
        cyl.usedVolume = cyl.cylinder.volumeL * (cyl.beginPressure - cyl.endPressure);
        cyl.sac = cyl.usedVolume / avgATA / durationMin;
        this.cylinders[e.key] = cyl;
      }

      // Update CNS percentage
      if (dl.samples.isNotEmpty && dl.samples.last.cns > 0) {
        this.cns = (100 * dl.samples.last.cns).round();
      } else {
        this.clearCns();
      }
    }

    this.duration = duration.round();
    this.maxDepth = maxDepth;
    this.meanDepth = totDepth / duration;
  }
}
