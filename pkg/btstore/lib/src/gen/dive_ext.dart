import 'dart:math';

import 'gen.dart';

extension DiveExtensions on Dive {
  void recalculateMetadata() {
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

    // At the end, consume the rest of the dive for the current cylinder, if there is a cylinder.
    spans.add((start: t, end: this.duration, idx: idx));

    // We will need to track duration and depth for each span.
    final perCylinderDepth = <int, ({double duration, double totDepth})>{};

    double maxDepth = 0.0;
    double totDepth = 0.0;
    double duration = 0;
    double prevDepth = 0.0;
    double prevTime = 0.0;

    // CNS and OTU accumulators
    double totalCns = 0.0;
    double totalOtu = 0.0;

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
        var thisSegFO2 = 0.21;
        try {
          final cylIdx = spans.firstWhere((s) => s.end >= sample.time).idx;
          final cur = perCylinderDepth[cylIdx] ?? (duration: 0, totDepth: 0);
          perCylinderDepth[cylIdx] = (duration: cur.duration + sampleDuration, totDepth: cur.totDepth + sampleDepth * sampleDuration);

          if (this.cylinders.isNotEmpty && cylIdx < this.cylinders.length && sampleDuration > 0) {
            final cyl = this.cylinders[cylIdx];
            thisSegFO2 = cyl.oxygen > 0 ? cyl.oxygen : 0.21;
          }
        } catch (StateError) {}

        // Calculate CNS and OTU for this sample segment
        final ppo2 = (1.0 + sampleDepth / 10.0) * thisSegFO2;
        final durationMinutes = sampleDuration / 60.0;

        // CNS accumulation
        final limit = _cnsLimitMinutes(ppo2);
        if (limit != null && limit.isFinite) {
          totalCns += (durationMinutes / limit) * 100.0;
        }

        // OTU accumulation
        totalOtu += _calculateOtu(ppo2, durationMinutes);
      }

      // Update cylinder used gas volumes now that we know pressures
      for (var (idx, cyl) in this.cylinders.indexed) {
        if (cyl.isFrozen) cyl = cyl.deepCopy();
        cyl.usedVolume = cyl.cylinder.volumeL * (cyl.beginPressure - cyl.endPressure);
        this.cylinders[idx] = cyl;
      }

      // Calculate total dive SAC based on the sum of all cylinders
      final totVolume = this.cylinders.fold(0.0, (tot, cyl) => tot + cyl.usedVolume);
      if (totVolume > 0 && !dl.isSynthetic) {
        this.sac = totVolume / (1.0 + meanDepth / 10.0) / (duration / 60);
      } else {
        this.clearSac();
      }

      if (!dl.isSynthetic) {
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

        // Update CNS
        if (totalCns > 0) {
          this.cns = totalCns.round();
        } else {
          this.clearCns();
        }

        // Update OTU
        if (totalOtu > 0) {
          this.otu = totalOtu.round();
        } else {
          this.clearOtu();
        }
      }
    } else {
      this.clearCns();
      this.clearOtu();
    }

    this.duration = duration.round();
    this.maxDepth = maxDepth;
    this.meanDepth = totDepth / duration;
  }
}

// NOAA CNS oxygen toxicity exposure limits.
// Returns the maximum exposure time in minutes for a given ppO2.
// Returns null if ppO2 is below 0.5 (no CNS toxicity concern).
double? _cnsLimitMinutes(double ppo2) {
  // NOAA CNS limits table
  const limits = [
    (ppo2: 0.50, minutes: double.infinity),
    (ppo2: 0.60, minutes: 720.0),
    (ppo2: 0.70, minutes: 570.0),
    (ppo2: 0.80, minutes: 450.0),
    (ppo2: 0.90, minutes: 360.0),
    (ppo2: 1.00, minutes: 300.0),
    (ppo2: 1.10, minutes: 240.0),
    (ppo2: 1.20, minutes: 210.0),
    (ppo2: 1.30, minutes: 180.0),
    (ppo2: 1.40, minutes: 150.0),
    (ppo2: 1.50, minutes: 120.0),
    (ppo2: 1.60, minutes: 45.0),
  ];

  if (ppo2 < 0.5) return null;
  if (ppo2 >= 1.6) return 45.0;

  // Find the bracketing values and interpolate
  for (var i = 0; i < limits.length - 1; i++) {
    if (ppo2 >= limits[i].ppo2 && ppo2 < limits[i + 1].ppo2) {
      final t = (ppo2 - limits[i].ppo2) / (limits[i + 1].ppo2 - limits[i].ppo2);
      return limits[i].minutes + t * (limits[i + 1].minutes - limits[i].minutes);
    }
  }
  return limits.last.minutes;
}

// Calculate OTU for a given ppO2 and time in minutes.
// Uses the REPEX formula: OTU = t × ((ppO2 - 0.5) / 0.5)^0.833
double _calculateOtu(double ppo2, double minutes) {
  if (ppo2 <= 0.5 || minutes <= 0) return 0.0;
  return minutes * pow((ppo2 - 0.5) / 0.5, 0.833);
}
