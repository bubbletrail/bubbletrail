import 'package:btproto/btproto.dart';

import 'package:test/test.dart';
import 'package:bubbletrail/src/connect/dc_convert.dart';

void main() {
  group('dive log conversion', () {
    test('converts sample-relative event times to elapsed dive times', () {
      final bookmark = SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_BOOKMARK, time: 0, value: 3);
      final offsetEvent = SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_ASCENT, time: 5, flags: 1, value: 7);
      final l = Log(
        samples: [
          LogSample(time: 120, events: [bookmark]),
          LogSample(time: 240, events: [offsetEvent]),
        ],
      );

      final d = convertDcDive(l);

      expect(d.events.map((event) => event.time), [120, 245]);
      expect(d.events.first.type, SampleEventType.SAMPLE_EVENT_TYPE_BOOKMARK);
      expect(d.events.first.value, 3);
      expect(d.events.last.flags, 1);
      expect(d.events.last.value, 7);
      // Keep the original sample-relative events in the stored computer log.
      expect(l.samples.first.events.single.time, 0);
      expect(l.samples.last.events.single.time, 5);
      expect(convertDcDive(l).events.map((event) => event.time), [120, 245]);
    });

    test('converts tanks and gas mixes', () {
      final l = Log();
      l.gasMixes.add(GasMix(oxygen: 0.21, helium: 0.35));
      l.gasMixes.add(GasMix(oxygen: 0.50));
      l.gasMixes.add(GasMix(oxygen: 0.99));
      l.tanks.add(Tank(volume: 24, beginPressure: 200, endPressure: 100, gasMixIndex: 0)); // 21/35
      l.tanks.add(Tank(volume: 11.1, beginPressure: 200, endPressure: 100, gasMixIndex: 1)); // 50%
      // no tank for 99%

      l.samples.add(LogSample(time: 10, depth: 40, gasMixIndex: 0));
      l.samples.add(LogSample(time: 20, depth: 21, gasMixIndex: 1));
      l.samples.add(LogSample(time: 30, depth: 6, gasMixIndex: 2));

      final d = convertDcDive(l);

      expect(d.cylinders.length, 3);
      expect(d.cylinders[2].oxygen, 0.99);

      expect(d.events.length, 2);
      expect(d.events[1].time, 30);
      expect(d.events[1].value, 2); // cylinder index for 99%
    });
  });
}
