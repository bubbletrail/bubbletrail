import 'dart:typed_data';

import 'package:bubbletrail/src/ssrf/ssrf.dart';
import 'package:divestore/divestore.dart' as ds;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Convert basic dive info', () {
    final dcDive = ds.Dive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 45 * 60 + 30, number: 42, maxDepth: 25.5, avgDepth: 15.2);

    final ssrfDive = convertDcDive(dcDive, diveNumber: 100);

    expect(ssrfDive.number, 100);
    expect(ssrfDive.start, DateTime(2024, 6, 15, 10, 30, 0));
    expect(ssrfDive.duration, 45 * 60 + 30);
    expect(ssrfDive.maxDepth, 25.5);
    expect(ssrfDive.meanDepth, 15.2);
  });

  test('Convert samples', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 20.0,
      avgDepth: 12.0,
      samples: [
        ds.Sample(time: 0, depth: 0.0, temperature: 28.0),
        ds.Sample(time: 60, depth: 5.5, temperature: 26.0, pressures: [const ds.TankPressure(tankIndex: 0, pressure: 195.0)]),
        ds.Sample(time: 120, depth: 10.2, temperature: 24.5, pressures: [const ds.TankPressure(tankIndex: 0, pressure: 185.0)]),
        ds.Sample(time: 180, depth: 15.8, temperature: 22.0, pressures: [const ds.TankPressure(tankIndex: 0, pressure: 170.0)]),
        ds.Sample(time: 900, depth: 20.0, temperature: 20.0, pressures: [const ds.TankPressure(tankIndex: 0, pressure: 120.0)]),
        ds.Sample(time: 1800, depth: 5.0, temperature: 24.0, pressures: [const ds.TankPressure(tankIndex: 0, pressure: 60.0)]),
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    expect(dcLog.maxDepth, 20.0);
    expect(dcLog.meanDepth, 12.0);

    // Check samples
    expect(dcLog.samples.length, 6);

    // First sample
    expect(dcLog.samples[0].time, 0);
    expect(dcLog.samples[0].depth, 0.0);
    expect(dcLog.samples[0].temp, 28.0);
    expect(dcLog.samples[0].pressure, isNull);

    // Second sample
    expect(dcLog.samples[1].time, 60);
    expect(dcLog.samples[1].depth, 5.5);
    expect(dcLog.samples[1].temp, 26.0);
    expect(dcLog.samples[1].pressure, 195.0);

    // Middle sample
    expect(dcLog.samples[3].time, 180);
    expect(dcLog.samples[3].depth, 15.8);
    expect(dcLog.samples[3].temp, 22.0);
    expect(dcLog.samples[3].pressure, 170.0);

    // Last sample
    expect(dcLog.samples[5].time, 1800);
    expect(dcLog.samples[5].depth, 5.0);
    expect(dcLog.samples[5].pressure, 60.0);
  });

  test('Convert tanks with gas mixes', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 45 * 60,
      maxDepth: 30.0,
      avgDepth: 18.0,
      gasMixes: const [
        ds.GasMix(oxygen: 0.32, helium: 0.0, nitrogen: 0.68), // EAN32
        ds.GasMix(oxygen: 0.21, helium: 0.35, nitrogen: 0.44), // Trimix 21/35
      ],
      tanks: const [
        ds.Tank(gasMixIndex: 0, volume: 12.0, workPressure: 200.0, beginPressure: 200.0, endPressure: 50.0),
        ds.Tank(gasMixIndex: 1, volume: 12.0, workPressure: 232.0, beginPressure: 230.0, endPressure: 80.0),
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.cylinders.length, 2);

    // First cylinder - EAN32
    expect(ssrfDive.cylinders[0].cylinderId, 1);
    expect(ssrfDive.cylinders[0].o2, closeTo(32.0, 0.1));
    expect(ssrfDive.cylinders[0].he, closeTo(0.0, 0.1));
    expect(ssrfDive.cylinders[0].start, 200.0);
    expect(ssrfDive.cylinders[0].end, 50.0);

    // Second cylinder - Trimix 21/35
    expect(ssrfDive.cylinders[1].cylinderId, 2);
    expect(ssrfDive.cylinders[1].o2, closeTo(21.0, 0.1));
    expect(ssrfDive.cylinders[1].he, closeTo(35.0, 0.1));
    expect(ssrfDive.cylinders[1].start, 230.0);
    expect(ssrfDive.cylinders[1].end, 80.0);
  });

  test('Convert gas mixes only (no tanks)', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 18.0,
      avgDepth: 12.0,
      gasMixes: const [
        ds.GasMix(oxygen: 0.36, helium: 0.0, nitrogen: 0.64), // EAN36
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.cylinders.length, 1);
    expect(ssrfDive.cylinders[0].o2, closeTo(36.0, 0.1));
    expect(ssrfDive.cylinders[0].he, closeTo(0.0, 0.1));
    expect(ssrfDive.cylinders[0].start, isNull);
    expect(ssrfDive.cylinders[0].end, isNull);
  });

  test('Convert environment data', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 40 * 60,
      maxDepth: 22.0,
      avgDepth: 14.0,
      surfaceTemperature: 30.0,
      minTemperature: 18.0,
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    expect(dcLog.environment, isNotNull);
    expect(dcLog.environment!.airTemperature, 30.0);
    expect(dcLog.environment!.waterTemperature, 18.0);
  });

  test('Convert dive mode and deco model to extradata', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 50 * 60,
      maxDepth: 35.0,
      avgDepth: 20.0,
      diveMode: ds.DiveMode.openCircuit,
      decoModel: const ds.DecoModel(type: ds.DecoModelType.buhlmann, gfLow: 40, gfHigh: 85),
      salinity: const ds.Salinity(type: ds.WaterType.salt, density: 1025.0),
      atmosphericPressure: 1.013,
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    expect(dcLog.extradata['divemode'], 'openCircuit');
    expect(dcLog.extradata['decomodel'], 'Bühlmann GF 40/85');
    expect(dcLog.extradata['salinity'], 'salt');
    expect(dcLog.extradata['density'], '1025.0');
    expect(dcLog.extradata['atmospheric'], '1.013');
  });

  test('Convert fingerprint to base64 extradata', () {
    final fingerprint = Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0xAB, 0xCD, 0xEF]);
    final dcDive = ds.Dive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 30 * 60, maxDepth: 15.0, avgDepth: 10.0, fingerprint: fingerprint.toString());

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    expect(dcLog.extradata['fingerprint'], isNotNull);
    expect(dcLog.extradata['fingerprint'], 'AQIDBKvN7w==');

    // Verify extraction
    final extracted = extractFingerprint(ssrfDive);
    expect(extracted, isNotNull);
    expect(extracted, fingerprint);
  });

  test('Convert events from samples', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 20.0,
      avgDepth: 12.0,
      samples: [
        ds.Sample(
          time: 0,
          depth: 0.0,
          events: const [ds.SampleEvent(type: ds.SampleEventType.gasChange, time: 0, flags: ds.SampleEventFlags(0), value: 0)],
        ),
        ds.Sample(
          time: 600,
          depth: 15.0,
          events: const [ds.SampleEvent(type: ds.SampleEventType.bookmark, time: 600, flags: ds.SampleEventFlags(0), value: 1)],
        ),
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    expect(dcLog.events.length, 2);
    expect(dcLog.events[0].time, 0);
    expect(dcLog.events[0].name, 'gasChange');
    expect(dcLog.events[1].time, 600);
    expect(dcLog.events[1].name, 'bookmark');
  });

  test('Skip samples without depth', () {
    final dcDive = ds.Dive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 20.0,
      avgDepth: 12.0,
      samples: [
        ds.Sample(time: 0, depth: 0.0),
        const ds.Sample(
          time: 30,
          depth: null, // No depth - should be skipped
          temperature: 25.0,
        ),
        ds.Sample(time: 60, depth: 5.0),
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 1);
    final dcLog = ssrfDive.divecomputers[0];

    // Only 2 samples (the one without depth is skipped)
    expect(dcLog.samples.length, 2);
    expect(dcLog.samples[0].time, 0);
    expect(dcLog.samples[1].time, 60);
  });

  test('Use diveComputerId parameter', () {
    final dcDive = ds.Dive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 30 * 60, maxDepth: 15.0, avgDepth: 10.0);

    final ssrfDive = convertDcDive(dcDive, diveComputerId: 42);

    expect(ssrfDive.divecomputers.length, 1);
    expect(ssrfDive.divecomputers[0].diveComputerId, 42);
  });

  test('No divecomputer log when no samples and no depth', () {
    final dcDive = ds.Dive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 30 * 60, maxDepth: null, avgDepth: null, samples: const []);

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.divecomputers.length, 0);
  });

  test('Handle null datetime', () {
    final dcDive = ds.Dive(dateTime: null, diveTime: 30 * 60, maxDepth: 15.0);

    final ssrfDive = convertDcDive(dcDive);

    // Should use current time as fallback
    expect(ssrfDive.start.year, DateTime.now().year);
    expect(ssrfDive.duration, 30 * 60);
  });
}
