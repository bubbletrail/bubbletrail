import 'dart:math';

import 'package:btproto/btproto.dart';
import 'ext.dart';

extension DiveExtensions on Dive {
  // Drop the cached decompression state and recompute everything derived from
  // the samples/gases. Call after editing anything that affects the profile
  // (start time, depth/duration, cylinders or gas switches).
  void invalidateComputed() {
    clearStartTissues();
    clearEndTissues();
    clearEndSurfGf();
    recalculateMetadata();
  }

  // Absorb [later], a dive that turned out to be the continuation of this one:
  // its profile samples and events are appended to ours, shifted to our time
  // base, and its cylinders are matched up with ours so the appended gas
  // switches keep pointing at the right cylinder. The caller recomputes the
  // derived data (invalidateComputed) and disposes of the merged-away dive.
  void appendDive(Dive later) {
    // Sample times are relative to the dive start, so everything from the later
    // dive shifts by the difference between the two starts. Never shift back
    // into our own profile, which would leave the samples out of order.
    final lastSampleTime = logs.firstOrNull?.samples.lastOrNull?.time ?? 0.0;
    final offset = max((later.start.seconds - start.seconds).toDouble(), lastSampleTime);

    // Match the later dive's cylinders against ours, adding the ones we don't
    // already have, and remember where each ended up for the event remapping.
    final cylinderIdx = <int, int>{};
    for (final (idx, cyl) in later.cylinders.indexed) {
      var ourIdx = cylinders.indexWhere(
        (c) => (c.cylinderId.isNotEmpty || cyl.cylinderId.isNotEmpty) ? c.cylinderId == cyl.cylinderId : (c.oxygen == cyl.oxygen && c.helium == cyl.helium),
      );
      if (ourIdx < 0) {
        ourIdx = cylinders.length;
        cylinders.add(cyl.deepCopy());
      } else if (cyl.hasEndPressure()) {
        // The same cylinder was breathed on into the later dive, so it's that
        // dive's end pressure that counts.
        var ours = cylinders[ourIdx];
        if (ours.isFrozen) ours = ours.deepCopy();
        ours.endPressure = cyl.endPressure;
        cylinders[ourIdx] = ours;
      }
      cylinderIdx[idx] = ourIdx;
    }

    for (final event in later.events) {
      final e = event.deepCopy();
      e.time = (event.time + offset).round();
      if (e.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE) e.value = cylinderIdx[event.value] ?? event.value;
      events.add(e);
    }

    for (final (idx, laterLog) in later.logs.indexed) {
      // Only the first log carries the profile; any further ones tag along
      // unchanged.
      if (idx > 0) {
        logs.add(laterLog.deepCopy());
        continue;
      }

      var l = logs.isNotEmpty ? logs.first : Log(model: laterLog.model, serial: laterLog.serial, dateTime: start);
      if (l.isFrozen) l = l.deepCopy();
      for (final sample in laterLog.samples) {
        final s = sample.deepCopy();
        s.time = sample.time + offset;
        for (final event in s.events) {
          event.time = (event.time + offset).round();
        }
        l.samples.add(s);
      }
      // A real computer profile appended to a synthetic one makes the whole
      // thing real, so it's no longer ours to regenerate.
      if (l.isSynthetic && !laterLog.isSynthetic) {
        l.model = laterLog.model;
        if (laterLog.hasSerial()) l.serial = laterLog.serial;
      }
      l.diveTime = (offset + laterLog.diveTime).round();
      l.maxDepth = max(l.maxDepth, laterLog.maxDepth);
      if (laterLog.hasEndPosition()) l.endPosition = laterLog.endPosition;
      if (laterLog.hasMinTemperature() && (!l.hasMinTemperature() || laterLog.minTemperature < l.minTemperature)) l.minTemperature = laterLog.minTemperature;
      if (laterLog.hasMaxTemperature() && (!l.hasMaxTemperature() || laterLog.maxTemperature > l.maxTemperature)) l.maxTemperature = laterLog.maxTemperature;
      if (logs.isEmpty) {
        logs.add(l);
      } else {
        logs[0] = l;
      }
    }
  }

  void recalculateMetadata() {
    // Process samples, calculating depths, durations, etc.

    // We want to update only cylinder that don't already have pressure data
    // (it may have been manually edited).
    final updateTankIndexes = <int>{};
    for (final (idx, cyl) in cylinders.indexed) {
      if (!cyl.hasBeginPressure() || !cyl.hasEndPressure()) {
        cylinders[idx] = cyl.deepCopy(); // make sure it's writable
        updateTankIndexes.add(idx); // mark for update
      }
    }

    // We need to figure out the in-use spans for each cylinder.
    final spans = <({int start, int end, int idx})>[];

    // We start at time zero on the first cylinder.
    var t = 0;
    var idx = 0;

    // For every gas switch we end the previous span and open a new one.
    for (final event in events) {
      if (event.type != SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE) continue;
      var newIdx = event.value;
      if (newIdx >= cylinders.length) newIdx = cylinders.length - 1;
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

    if (logs.isNotEmpty) {
      // Calculate depths etc based on samples.
      final dl = logs.first;
      for (final sample in dl.samples) {
        // Temperature bounds
        if (sample.hasTemperature()) {
          if (!hasMaxTemp() || sample.temperature > maxTemp) maxTemp = sample.temperature;
          if (!hasMinTemp() || sample.temperature < minTemp) minTemp = sample.temperature;
        }

        // Collect and update tank pressures as required
        for (final pressure in sample.pressures) {
          if (updateTankIndexes.contains(pressure.tankIndex)) {
            final t = cylinders[pressure.tankIndex];
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
        } on StateError catch (_) {}
      }

      duration = max(duration, 1.0);
      this.duration = duration.round();
      this.maxDepth = maxDepth;
      meanDepth = totDepth / duration;

      // Update cylinder used gas volumes now that we know pressures
      for (var (idx, cyl) in cylinders.indexed) {
        if (cyl.isFrozen) cyl = cyl.deepCopy();
        cyl.usedVolume = cyl.cylinder.volumeL * (cyl.beginPressure - cyl.endPressure);
        cylinders[idx] = cyl;
      }

      // Calculate total dive SAC based on the sum of all cylinders
      final totVolume = cylinders.fold(0.0, (tot, cyl) => tot + cyl.usedVolume);
      if (totVolume > 0 && !dl.isSynthetic) {
        sac = totVolume / (1.0 + meanDepth / 10.0) / (duration / 60);
      } else {
        clearSac();
      }

      if (!dl.isSynthetic && cylinders.isNotEmpty) {
        // Calculate per cylinder SAC
        for (final e in perCylinderDepth.entries) {
          final avgDepth = e.value.totDepth / e.value.duration;
          final avgATA = 1.0 + avgDepth / 10.0;
          final durationMin = e.value.duration / 60.0;
          var cyl = cylinders[e.key];

          if (cyl.isFrozen) cyl = cyl.deepCopy();
          cyl.usedVolume = cyl.cylinder.volumeL * (cyl.beginPressure - cyl.endPressure);
          cyl.sac = cyl.usedVolume / avgATA / durationMin;
          cylinders[e.key] = cyl;
        }

        // Update CNS percentage
        if (dl.samples.isNotEmpty && dl.samples.last.cns > 0) {
          cns = (100 * dl.samples.last.cns).round();
        } else {
          clearCns();
        }
      }
    } else {
      clearCns();
    }
  }
}
