import 'package:btstore/btstore.dart';
import 'package:test/test.dart';

void main() {
  group('dive log conversion', () {
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

      expect(d.events.length, 3);
      expect(d.events[2].time, 30);
      expect(d.events[2].value, 2); // cylinder index for 99%
    });
  });
}
