import 'dart:convert';

import 'package:divestore/divestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Convert basic dive info', () {
    final dcDive = ComputerDive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 45 * 60 + 30, number: 42, maxDepth: 25.5, avgDepth: 15.2);

    final ssrfDive = convertDcDive(dcDive, diveNumber: 100);

    expect(ssrfDive.number, 100);
    expect(ssrfDive.start, DateTime(2024, 6, 15, 10, 30, 0));
    expect(ssrfDive.duration, 45 * 60 + 30);
    expect(ssrfDive.maxDepth, 25.5);
    expect(ssrfDive.meanDepth, 15.2);
  });

  test('Attach ComputerDive to Dive', () {
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 20.0,
      avgDepth: 12.0,
      samples: [
        ComputerSample(time: 0, depth: 0.0, temperature: 28.0),
        ComputerSample(time: 60, depth: 5.5, temperature: 26.0, pressures: [const TankPressure(tankIndex: 0, pressure: 195.0)]),
        ComputerSample(time: 120, depth: 10.2, temperature: 24.5, pressures: [const TankPressure(tankIndex: 0, pressure: 185.0)]),
        ComputerSample(time: 180, depth: 15.8, temperature: 22.0, pressures: [const TankPressure(tankIndex: 0, pressure: 170.0)]),
        ComputerSample(time: 900, depth: 20.0, temperature: 20.0, pressures: [const TankPressure(tankIndex: 0, pressure: 120.0)]),
        ComputerSample(time: 1800, depth: 5.0, temperature: 24.0, pressures: [const TankPressure(tankIndex: 0, pressure: 60.0)]),
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.computerDives.length, 1);
    final cd = ssrfDive.computerDives[0];

    expect(cd.maxDepth, 20.0);
    expect(cd.avgDepth, 12.0);

    // ComputerDive preserves all samples
    expect(cd.samples.length, 6);
    expect(cd.samples[0].time, 0);
    expect(cd.samples[0].depth, 0.0);
    expect(cd.samples[0].temperature, 28.0);
  });

  test('Convert tanks with gas mixes', () {
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 45 * 60,
      maxDepth: 30.0,
      avgDepth: 18.0,
      gasMixes: const [
        GasMix(oxygen: 0.32, helium: 0.0, nitrogen: 0.68), // EAN32
        GasMix(oxygen: 0.21, helium: 0.35, nitrogen: 0.44), // Trimix 21/35
      ],
      tanks: const [
        Tank(gasMixIndex: 0, volume: 12.0, workPressure: 200.0, beginPressure: 200.0, endPressure: 50.0),
        Tank(gasMixIndex: 1, volume: 12.0, workPressure: 232.0, beginPressure: 230.0, endPressure: 80.0),
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
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 18.0,
      avgDepth: 12.0,
      gasMixes: const [
        GasMix(oxygen: 0.36, helium: 0.0, nitrogen: 0.64), // EAN36
      ],
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.cylinders.length, 1);
    expect(ssrfDive.cylinders[0].o2, closeTo(36.0, 0.1));
    expect(ssrfDive.cylinders[0].he, closeTo(0.0, 0.1));
    expect(ssrfDive.cylinders[0].start, isNull);
    expect(ssrfDive.cylinders[0].end, isNull);
  });

  test('ComputerDive preserves temperature data', () {
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 40 * 60,
      maxDepth: 22.0,
      avgDepth: 14.0,
      surfaceTemperature: 30.0,
      minTemperature: 18.0,
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.computerDives.length, 1);
    final cd = ssrfDive.computerDives[0];

    expect(cd.surfaceTemperature, 30.0);
    expect(cd.minTemperature, 18.0);
  });

  test('ComputerDive preserves dive mode and metadata', () {
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 50 * 60,
      maxDepth: 35.0,
      avgDepth: 20.0,
      diveMode: DiveMode.openCircuit,
      decoModel: const DecoModel(type: DecoModelType.buhlmann, gfLow: 40, gfHigh: 85),
      salinity: const Salinity(type: WaterType.salt, density: 1025.0),
      atmosphericPressure: 1.013,
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.computerDives.length, 1);
    final cd = ssrfDive.computerDives[0];

    expect(cd.diveMode, DiveMode.openCircuit);
    expect(cd.decoModel?.type, DecoModelType.buhlmann);
    expect(cd.salinity?.type, WaterType.salt);
    expect(cd.atmosphericPressure, 1.013);
  });

  test('Extract fingerprint from ComputerDive', () {
    const fingerprintBase64 = 'AQIDBKvN7w=='; // base64 of [1, 2, 3, 4, 171, 205, 239]
    final dcDive = ComputerDive(
      dateTime: DateTime(2024, 6, 15, 10, 30, 0),
      diveTime: 30 * 60,
      maxDepth: 15.0,
      avgDepth: 10.0,
      fingerprint: fingerprintBase64,
    );

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.computerDives.length, 1);
    expect(ssrfDive.computerDives[0].fingerprint, fingerprintBase64);

    // Verify extraction
    final extracted = extractFingerprint(ssrfDive);
    expect(extracted, isNotNull);
    expect(extracted, base64Decode(fingerprintBase64));
  });

  test('Add model and serial to ComputerDive', () {
    final dcDive = ComputerDive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 30 * 60, maxDepth: 15.0, avgDepth: 10.0);

    final ssrfDive = convertDcDive(dcDive, model: 'Suunto EON Core', serial: '12345678');

    expect(ssrfDive.computerDives.length, 1);
    expect(ssrfDive.computerDives[0].model, 'Suunto EON Core');
    expect(ssrfDive.computerDives[0].serial, '12345678');
  });

  test('No computerDive when no samples and no depth', () {
    final dcDive = ComputerDive(dateTime: DateTime(2024, 6, 15, 10, 30, 0), diveTime: 30 * 60, maxDepth: null, avgDepth: null, samples: const []);

    final ssrfDive = convertDcDive(dcDive);

    expect(ssrfDive.computerDives.length, 0);
  });

  test('Handle null datetime', () {
    final dcDive = ComputerDive(dateTime: null, diveTime: 30 * 60, maxDepth: 15.0);

    final ssrfDive = convertDcDive(dcDive);

    // Should use current time as fallback
    expect(ssrfDive.start.year, DateTime.now().year);
    expect(ssrfDive.duration, 30 * 60);
  });
}
