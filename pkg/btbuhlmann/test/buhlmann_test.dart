import 'package:test/test.dart';
import '../lib/btbuhlmann.dart';
import '../lib/constants.dart';

void main() {
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
  });

  group('No-decompression limits', () {
    test('NDL decreases with depth', () {
      final deco1 = BuhlmannDeco();
      final deco2 = BuhlmannDeco();

      final ndl20m = deco1.ndl(20, GasMix.air);
      final ndl30m = deco2.ndl(30, GasMix.air);

      expect(ndl20m, isNotNull);
      expect(ndl30m, isNotNull);
      expect(ndl30m, lessThan(ndl20m!), reason: 'Deeper = shorter NDL');
    });

    test('nitrox extends NDL compared to air', () {
      final decoAir = BuhlmannDeco();
      final decoEan32 = BuhlmannDeco();

      final ndlAir = decoAir.ndl(30, GasMix.air);
      final ndlEan32 = decoEan32.ndl(30, GasMix.nitrox(32));

      expect(ndlAir, isNotNull);
      expect(ndlEan32, isNotNull);
      expect(ndlEan32, greaterThan(ndlAir!), reason: 'EAN32 should have longer NDL than air at 30m');
    });

    test('NDL is returned in seconds', () {
      final deco = BuhlmannDeco();

      final ndl = deco.ndl(20, GasMix.air);

      expect(ndl, isNotNull);
      // NDL at 20m on air should be around 30-40 minutes = 1800-2400 seconds
      expect(ndl, greaterThan(1500), reason: 'NDL should be in seconds');
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

  group('Gradient factor', () {
    test('GF at surface equilibrium is negative (undersaturated)', () {
      final deco = BuhlmannDeco();

      // At surface equilibrium, tissues are at alveolar N2 pressure (~0.75 bar)
      // which is less than ambient (~1.01 bar) due to water vapor pressure.
      // This means tissues are undersaturated and GF is negative.
      final surfGF = deco.surfaceGradientFactor();
      expect(surfGF, lessThan(0), reason: 'GF at equilibrium should be negative');
      expect(surfGF, greaterThan(-20), reason: 'GF should not be too negative');
    });

    test('GF increases after diving', () {
      final deco = BuhlmannDeco();

      final initialGF = deco.surfaceGradientFactor();

      // Dive to 30m for 20 minutes
      deco.addSegment(30, GasMix.air, 1200);

      final afterDiveGF = deco.surfaceGradientFactor();

      expect(afterDiveGF, greaterThan(initialGF), reason: 'GF should increase after diving');
    });

    test('GF exceeds 100 when in deco violation', () {
      final deco = BuhlmannDeco();

      // Deep dive that puts us well into deco
      deco.addSegment(40, GasMix.air, 1800);

      final surfGF = deco.surfaceGradientFactor();

      // Should be over 100% - can't safely surface
      expect(surfGF, greaterThan(100), reason: 'SurfGF should exceed 100 when in deco');
    });

    test('GF at depth is lower than at surface', () {
      final deco = BuhlmannDeco();

      // Dive to 30m for 25 minutes
      deco.addSegment(30, GasMix.air, 1500);

      final surfGF = deco.gradientFactor(deco.depthToPressure(0));
      final gfAt30m = deco.gradientFactor(deco.depthToPressure(30));

      expect(gfAt30m, lessThan(surfGF), reason: 'GF at depth should be lower than at surface');
    });

    test('surfaceGradientFactor matches gradientFactor at surface', () {
      final deco = BuhlmannDeco();

      deco.addSegment(25, GasMix.air, 1500);

      final surfGF = deco.surfaceGradientFactor();
      final gfAtSurface = deco.gradientFactor(deco.depthToPressure(0));

      expect(surfGF, closeTo(gfAtSurface, 0.001));
    });

    test('GF at ceiling depth equals GF_low', () {
      // With GF 100/100, the ceiling is where GF = 100%
      final deco = BuhlmannDeco(config: const BuhlmannConfig(gfLow: 1.0, gfHigh: 1.0));

      // Deep dive to create deco obligation
      deco.addSegment(40, GasMix.air, 1500);

      final ceiling = deco.ceilingDepth();
      expect(ceiling, greaterThan(0), reason: 'Should have a ceiling');

      // GF at ceiling should be close to 100% (GF_low)
      final gfAtCeiling = deco.gradientFactor(deco.depthToPressure(ceiling));
      expect(gfAtCeiling, closeTo(100, 2), reason: 'GF at ceiling should equal GF_low');
    });

    test('GF at ceiling with conservative settings equals GF_low', () {
      // With GF 30/70, the ceiling is where GF = 30%
      final deco = BuhlmannDeco(config: const BuhlmannConfig(gfLow: 0.3, gfHigh: 0.7));

      // Deep dive to create deco obligation
      deco.addSegment(40, GasMix.air, 1500);

      final ceiling = deco.ceilingDepth();
      expect(ceiling, greaterThan(0), reason: 'Should have a ceiling');

      // GF at ceiling should be close to 30% (GF_low)
      final gfAtCeiling = deco.gradientFactor(deco.depthToPressure(ceiling));
      expect(gfAtCeiling, closeTo(30, 2), reason: 'GF at ceiling should equal GF_low (30)');
    });

    test('NDL corresponds to surface GF reaching 100%', () {
      final deco = BuhlmannDeco(); // GF 100/100

      // Get NDL at 30m
      final ndl = deco.ndl(30, GasMix.air);
      expect(ndl, isNotNull);

      // Dive for exactly the NDL
      final testDeco = BuhlmannDeco();
      testDeco.addSegment(30, GasMix.air, ndl!.toDouble());

      // Surface GF should be just under 100%
      final surfGF = testDeco.surfaceGradientFactor();
      expect(surfGF, lessThanOrEqualTo(100), reason: 'At NDL, surface GF should be <= 100%');
      expect(surfGF, greaterThan(90), reason: 'At NDL, surface GF should be close to 100%');

      // One more minute should push it over
      testDeco.addSegment(30, GasMix.air, 60);
      final surfGFAfter = testDeco.surfaceGradientFactor();
      expect(surfGFAfter, greaterThan(100), reason: 'Past NDL, surface GF should exceed 100%');
    });
  });
}
