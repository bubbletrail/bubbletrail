import 'package:test/test.dart';
import '../lib/buhlmann.dart';

void main() {
  group('GasMix', () {
    test('air has correct fractions', () {
      const air = GasMix.air;
      expect(air.oxygen, closeTo(0.21, 0.001));
      expect(air.nitrogen, closeTo(0.79, 0.001));
      expect(air.helium, 0.0);
    });

    test('nitrox 32 has correct fractions', () {
      final ean32 = GasMix.nitrox(32);
      expect(ean32.oxygen, closeTo(0.32, 0.001));
      expect(ean32.nitrogen, closeTo(0.68, 0.001));
      expect(ean32.helium, 0.0);
    });

    test('trimix has correct fractions', () {
      final tmx2135 = GasMix.trimix(21, 35);
      expect(tmx2135.oxygen, closeTo(0.21, 0.001));
      expect(tmx2135.helium, closeTo(0.35, 0.001));
      expect(tmx2135.nitrogen, closeTo(0.44, 0.001));
    });

    test('toString formats correctly', () {
      expect(GasMix.air.toString(), 'Air');
      expect(GasMix.nitrox(32).toString(), 'EAN32');
      expect(GasMix.trimix(18, 45).toString(), 'Tx18/45');
    });
  });

  group('BuhlmannDeco initialization', () {
    test('tissues initialize to surface equilibrium', () {
      final deco = BuhlmannDeco();

      // At surface, tissues should be saturated with N2 from air
      // Inspired N2 = (1.01325 - 0.0627) * 0.79 ≈ 0.751 bar
      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.n2Pressures[i], closeTo(0.751, 0.01));
        expect(deco.tissues.hePressures[i], 0.0);
      }
    });

    test('depth to pressure conversion', () {
      final deco = BuhlmannDeco();
      // At 10m, pressure = 1.01325 + 1.0 = 2.01325 bar
      expect(deco.depthToPressure(10), closeTo(2.01325, 0.001));
      expect(deco.depthToPressure(30), closeTo(4.01325, 0.001));
    });

    test('pressure to depth conversion', () {
      final deco = BuhlmannDeco();
      expect(deco.pressureToDepth(2.01325), closeTo(10, 0.01));
      expect(deco.pressureToDepth(4.01325), closeTo(30, 0.01));
    });
  });

  group('Nitrox 32 dive to 30m for 30 minutes', () {
    test('tissue loading increases during dive', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Record initial tissue pressures
      final initialN2 = List<double>.from(deco.tissues.n2Pressures);

      // Dive to 30m for 30 minutes (1800 seconds)
      deco.addSegment(30, ean32, 1800);

      // All tissues should have increased N2 loading
      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.n2Pressures[i], greaterThan(initialN2[i]), reason: 'Tissue $i should have increased N2 loading');
      }
    });

    test('fast tissues saturate more than slow tissues', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Dive to 30m for 30 minutes (1800 seconds)
      deco.addSegment(30, ean32, 1800);

      // Inspired N2 at 30m = (4.01325 - 0.0627) * 0.68 ≈ 2.686 bar
      final inspiredN2 = (4.01325 - waterVaporPressure) * 0.68;

      // Fast tissues (compartment 0-3) should be closer to inspired pressure
      // than slow tissues (compartment 12-15)
      final fastTissueAvg = (deco.tissues.n2Pressures[0] + deco.tissues.n2Pressures[1] + deco.tissues.n2Pressures[2] + deco.tissues.n2Pressures[3]) / 4;

      final slowTissueAvg = (deco.tissues.n2Pressures[12] + deco.tissues.n2Pressures[13] + deco.tissues.n2Pressures[14] + deco.tissues.n2Pressures[15]) / 4;

      expect(fastTissueAvg, greaterThan(slowTissueAvg), reason: 'Fast tissues should be more saturated after 30 min');

      // Fast tissues should be close to inspired pressure
      expect(fastTissueAvg, closeTo(inspiredN2, 0.3));
    });

    test('ceiling depth is reasonable after dive', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Dive to 30m for 30 minutes (1800 seconds) on EAN32
      deco.addSegment(30, ean32, 1800);

      final ceiling = deco.ceilingDepth();

      // With no gradient factors, this dive should be precisely out of NDL.
      expect(ceiling, greaterThan(0), reason: 'Out of NDL');
      expect(ceiling, lessThan(1), reason: 'Almost at NDL');
    });

    test('NDL is null when in deco obligation', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Dive to 30m for 30 minutes (1800 seconds)
      deco.addSegment(30, ean32, 1800);

      // Should be in deco, so NDL should be null
      final ndl = deco.ndl(30, ean32);
      expect(ndl, isNull, reason: 'Should be in deco obligation');
    });

    test('SurfGF', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Dive to 30m for 30 minutes (1800 seconds)
      deco.addSegment(30, ean32, 1800);

      final surfGf = deco.tissuesSaturation(deco.depthToPressure(0));
      expect(surfGf, greaterThan(100), reason: 'Slightly out of NDL');
      expect(surfGf, lessThan(105), reason: 'Slightly out of NDL');
    });

    test('deco schedule produces stops', () {
      final deco = BuhlmannDeco();
      final ean32 = GasMix.nitrox(32);

      // Dive to 30m for 30 minutes (1800 seconds)
      deco.addSegment(30, ean32, 1800);

      final stops = deco.calculateDecoSchedule(30, ean32);

      expect(stops, isNotEmpty, reason: 'Should have deco stops');

      // All stops should be at valid depths (multiples of 3m)
      for (final stop in stops) {
        expect(stop.depth % 3, 0, reason: 'Stop should be at 3m increment');
        expect(stop.time, greaterThan(0), reason: 'Stop time should be positive');
      }

      // Last stop should be at 3m or 6m
      expect(stops.last.depth, lessThanOrEqualTo(6));
    });

    test('with conservative GF produces longer stops', () {
      final ean32 = GasMix.nitrox(32);

      // Default GF (100/100)
      final decoDefault = BuhlmannDeco();
      decoDefault.addSegment(30, ean32, 1800);
      final stopsDefault = decoDefault.calculateDecoSchedule(30, ean32);

      // Conservative GF (30/70)
      final decoConservative = BuhlmannDeco(config: BuhlmannConfig.conservative);
      decoConservative.addSegment(30, ean32, 1800);
      final stopsConservative = decoConservative.calculateDecoSchedule(30, ean32);

      // Calculate total deco time (in seconds)
      final totalDefault = stopsDefault.fold<int>(0, (sum, stop) => sum + stop.time);
      final totalConservative = stopsConservative.fold<int>(0, (sum, stop) => sum + stop.time);

      expect(totalConservative, greaterThan(totalDefault), reason: 'Conservative GF should require more deco time');
    });
  });

  group('No-decompression limits', () {
    test('NDL decreases with depth', () {
      final deco1 = BuhlmannDeco();
      final deco2 = BuhlmannDeco();

      final ndl20m = deco1.ndl(20, GasMix.air);
      final ndl30m = deco2.ndl(30, GasMix.air);

      expect(ndl20m, isNotNull);
      expect(ndl30m, isNotNull);
      expect(ndl30m!, lessThan(ndl20m!), reason: 'Deeper = shorter NDL');
    });

    test('nitrox extends NDL compared to air', () {
      final decoAir = BuhlmannDeco();
      final decoEan32 = BuhlmannDeco();

      final ndlAir = decoAir.ndl(30, GasMix.air);
      final ndlEan32 = decoEan32.ndl(30, GasMix.nitrox(32));

      expect(ndlAir, isNotNull);
      expect(ndlEan32, isNotNull);
      expect(ndlEan32!, greaterThan(ndlAir!), reason: 'EAN32 should have longer NDL than air at 30m');
    });

    test('NDL is returned in seconds', () {
      final deco = BuhlmannDeco();

      final ndl = deco.ndl(20, GasMix.air);

      expect(ndl, isNotNull);
      // NDL at 20m on air should be around 30-40 minutes = 1800-2400 seconds
      expect(ndl!, greaterThan(1500), reason: 'NDL should be in seconds');
      expect(ndl, lessThan(3000), reason: 'NDL should be reasonable');
    });

    test('shallow recreational dive stays within NDL', () {
      final deco = BuhlmannDeco();

      // 18m for 40 minutes (2400 seconds) on air should be within NDL
      deco.addSegment(18, GasMix.air, 2400);

      final ceiling = deco.ceilingDepth();
      expect(ceiling, lessThanOrEqualTo(0), reason: 'Should not require deco');
    });
  });

  group('Trimix diving', () {
    test('helium loads into tissues', () {
      final deco = BuhlmannDeco();
      final tmx2135 = GasMix.trimix(21, 35);

      // All He pressures should start at 0
      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.hePressures[i], 0.0);
      }

      // Dive to 50m for 20 minutes (1200 seconds)
      deco.addSegment(50, tmx2135, 1200);

      // He should now be loaded
      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.hePressures[i], greaterThan(0), reason: 'Tissue $i should have He loading');
      }
    });

    test('helium off-gasses faster than nitrogen', () {
      final deco = BuhlmannDeco();
      final tmx2135 = GasMix.trimix(21, 35);

      // Load tissues at 50m for 30 minutes (1800 seconds)
      deco.addSegment(50, tmx2135, 1800);

      final heAfterDive = List<double>.from(deco.tissues.hePressures);
      final n2AfterDive = List<double>.from(deco.tissues.n2Pressures);

      // Switch to air and off-gas at 6m for 30 minutes (1800 seconds)
      deco.addSegment(6, GasMix.air, 1800);

      // Calculate percentage of gas eliminated for fast tissue (compartment 1)
      final heEliminated = (heAfterDive[1] - deco.tissues.hePressures[1]) / heAfterDive[1];
      final n2Change = (n2AfterDive[1] - deco.tissues.n2Pressures[1]).abs() / n2AfterDive[1];

      // He should off-gas faster (higher percentage eliminated)
      expect(heEliminated, greaterThan(n2Change), reason: 'He should off-gas faster than N2');
    });
  });

  group('Tissue saturation', () {
    test('saturation relative to surface M-value increases during dive', () {
      final deco = BuhlmannDeco();

      // Measure saturation relative to surface M-value (what matters for ascent)
      final surfacePressure = deco.depthToPressure(0);
      final surfaceSat = deco.tissuesSaturation(surfacePressure);

      // 20 minutes (1200 seconds) at 30m
      deco.addSegment(30, GasMix.air, 1200);

      // After diving, saturation relative to SURFACE M-value should increase
      // (this is what determines if we can safely ascend)
      final afterDiveSat = deco.tissuesSaturation(surfacePressure);

      expect(afterDiveSat, greaterThan(surfaceSat), reason: 'Saturation relative to surface should increase after diving');
    });
  });

  group('Edge cases', () {
    test('zero time segment has no effect', () {
      final deco = BuhlmannDeco();
      final initial = List<double>.from(deco.tissues.n2Pressures);

      deco.addSegment(30, GasMix.air, 0);

      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.n2Pressures[i], initial[i]);
      }
    });

    test('surface segment maintains equilibrium', () {
      final deco = BuhlmannDeco();

      // Staying at surface breathing air for 60 minutes (3600 seconds)
      // should maintain equilibrium
      deco.addSegment(0, GasMix.air, 3600);

      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.n2Pressures[i], closeTo(0.751, 0.02));
      }
    });

    test('reset returns to initial state', () {
      final deco = BuhlmannDeco();

      // Do a deep dive for 30 minutes (1800 seconds)
      deco.addSegment(50, GasMix.air, 1800);

      // Reset
      deco.reset();

      // Should be back to surface equilibrium
      for (var i = 0; i < numTissueCompartments; i++) {
        expect(deco.tissues.n2Pressures[i], closeTo(0.751, 0.02));
        expect(deco.tissues.hePressures[i], 0.0);
      }
    });
  });

  group('Time units verification', () {
    test('addSegment accepts time in seconds', () {
      final deco = BuhlmannDeco();

      // Add 5 minutes = 300 seconds
      deco.addSegment(20, GasMix.air, 300);

      // Tissues should have loaded some gas
      expect(deco.tissues.n2Pressures[0], greaterThan(0.751), reason: 'Fast tissue should load gas in 5 minutes');
    });

    test('DecoStop time is in seconds', () {
      final deco = BuhlmannDeco();

      // Deep dive requiring deco: 40m for 25 minutes (1500 seconds)
      deco.addSegment(40, GasMix.air, 1500);

      final stops = deco.calculateDecoSchedule(40, GasMix.air);

      expect(stops, isNotEmpty);

      // Stop times should be reasonable in seconds (multiples of 60)
      for (final stop in stops) {
        expect(stop.time % 60, 0, reason: 'Stop time should be in whole minutes');
        expect(stop.time, greaterThanOrEqualTo(60), reason: 'Minimum 1 minute stop');
      }
    });
  });
}
