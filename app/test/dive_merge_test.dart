import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/store.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:test/test.dart';

final _start = DateTime.utc(2026, 8, 27, 10);

Dive _dive({
  required DateTime start,
  required List<LogSample> samples,
  List<DiveCylinder> cylinders = const [],
  List<SampleEvent> events = const [],
  Position? endPosition,
}) {
  final dive = Dive(
    start: Timestamp.fromDateTime(start),
    logs: [Log(dateTime: Timestamp.fromDateTime(start), samples: samples, endPosition: endPosition)],
  );
  dive.cylinders.addAll(cylinders);
  dive.events.addAll(events);
  dive.recalculateMetadata();
  return dive;
}

void main() {
  group('merging a dive into the preceding one', () {
    // Two 30 minutes apart, so the later one's samples shift by 1800 seconds.
    final first = _dive(
      start: _start,
      samples: [LogSample(time: 0, depth: 0), LogSample(time: 60, depth: 20), LogSample(time: 600, depth: 20), LogSample(time: 660, depth: 0)],
      cylinders: [DiveCylinder(oxygen: 0.32, beginPressure: 200, endPressure: 150)],
    );
    final second = _dive(
      start: _start.add(const Duration(minutes: 30)),
      samples: [LogSample(time: 0, depth: 0), LogSample(time: 60, depth: 30), LogSample(time: 300, depth: 30), LogSample(time: 360, depth: 0)],
      cylinders: [DiveCylinder(oxygen: 0.21, beginPressure: 200, endPressure: 120), DiveCylinder(oxygen: 0.32, beginPressure: 150, endPressure: 90)],
      events: [SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: 120, value: 1)],
      endPosition: Position(latitude: 57.7, longitude: 11.9),
    );

    final merged = first.deepCopy()
      ..appendDive(second)
      ..invalidateComputed();

    test('appends the profile on the first dive\'s time base', () {
      expect(merged.logs, hasLength(1));
      expect(merged.logs.first.samples.map((s) => s.time), [0, 60, 600, 660, 1800, 1860, 2100, 2160]);
      // The last sample below the surface, as for any other dive.
      expect(merged.duration, 2100);
      expect(merged.maxDepth, 30);
    });

    test('shifts events and points gas switches at the merged cylinders', () {
      // The later dive's air cylinder is new, its 32% is the one we already had.
      expect(merged.cylinders.map((c) => c.oxygen), [0.32, 0.21]);
      expect(merged.events, hasLength(1));
      expect(merged.events.first.time, 1920);
      expect(merged.events.first.value, 0);
    });

    test('carries the shared cylinder through to its final pressure', () {
      expect(merged.cylinders.first.beginPressure, 200);
      expect(merged.cylinders.first.endPressure, 90);
    });

    test('drops the cached decompression state', () {
      expect(merged.hasStartTissues(), isFalse);
      expect(merged.hasEndTissues(), isFalse);
    });

    test('ends where the later dive ended', () {
      expect(merged.logs.first.endPosition.latitude, 57.7);
    });

    // The real caller merges dives loaded from storage, which are frozen.
    test('works on frozen dives', () {
      final frozen = first.deepCopy()..freeze();
      final fromStorage = frozen.rebuild((d) {
        d.appendDive(second.deepCopy()..freeze());
        d.invalidateComputed();
      });
      expect(fromStorage.logs.first.samples.map((s) => s.time), merged.logs.first.samples.map((s) => s.time));
      expect(fromStorage.duration, merged.duration);
      expect(fromStorage.cylinders.map((c) => c.endPressure), merged.cylinders.map((c) => c.endPressure));
    });
  });
}
