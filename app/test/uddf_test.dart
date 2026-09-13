import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/store.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;
import 'package:test/test.dart';
import 'package:xml/xml.dart';

void main() {
  group('UDDF Import', () {
    late Container ssrf;

    setUpAll(() {
      final file = File('test/testdata/sample-1.uddf');
      final xmlDoc = XmlDocument.parse(file.readAsStringSync());
      ssrf = UddfXml.fromXml(xmlDoc.rootElement);
    });

    test('parses sites', () {
      expect(ssrf.sites, isNotEmpty);

      // Check first site
      final site = ssrf.sites.firstWhere((s) => s.name == 'Hällebäck');
      expect(site.id, '4796AB55-6152-4943-973B-144E6A8E2B3E');
      expect(site.country, 'Sweden');
      expect(site.location, 'Gullmarn');
      expect(site.hasPosition(), isTrue);
      expect(site.position.latitude, closeTo(58.34605, 0.00001));
      expect(site.position.longitude, closeTo(11.58821, 0.00001));
    });

    test('parses dives', () {
      expect(ssrf.dives, isNotEmpty);
    });

    test('parses dive metadata', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.number, 249);
      expect(dive.hasStart(), isTrue);

      final dt = dive.start.toDateTime();
      expect(dt.year, 2024);
      expect(dt.month, 11);
      expect(dt.day, 17);
      // Hour may vary by timezone, just check it's reasonable
      expect(dt.hour, inInclusiveRange(9, 11));
      expect(dt.minute, 35);
    });

    test('parses dive duration and depth', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      // Duration: 3530 seconds = ~58.8 minutes
      expect(dive.duration, 3530);

      // Greatest depth: 35.70 meters
      expect(dive.maxDepth, closeTo(35.70, 0.01));
    });

    test('converts temperature from Kelvin to Celsius', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      // Lowest temperature: 281.15K = 8°C
      expect(dive.logs, isNotEmpty);
      expect(dive.logs[0].hasMinTemperature(), isTrue);
      expect(dive.logs[0].minTemperature, closeTo(8.0, 0.1));
    });

    test('parses rating', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasRating(), isTrue);
      expect(dive.rating, 4);
    });

    test('parses notes', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasNotes(), isTrue);
      expect(dive.notes, contains('Hällebäck'));
    });

    test('parses site reference', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.hasSiteId(), isTrue);
      expect(dive.siteId, '4796AB55-6152-4943-973B-144E6A8E2B3E');
    });

    test('parses buddy reference', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      expect(dive.buddies, contains('Name Namesson'));
    });

    test('parses tank data with gas mix', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.cylinders, isNotEmpty);
      final cyl = dive.cylinders[0];

      // Gas: Air (21% O2)
      expect(cyl.oxygen, closeTo(0.21, 0.01));
      expect(cyl.helium, closeTo(0.0, 0.01));

      // Volume: 0.024 m³ = 24 liters
      expect(cyl.hasCylinder(), isTrue);
      expect(cyl.cylinder.volumeL, closeTo(24.0, 0.1));

      // Begin pressure: 20822167.02 Pa = ~208 bar
      expect(cyl.hasBeginPressure(), isTrue);
      expect(cyl.beginPressure, closeTo(208.0, 1.0));

      // End pressure: 11155717.30 Pa = ~112 bar
      expect(cyl.hasEndPressure(), isTrue);
      expect(cyl.endPressure, closeTo(112.0, 1.0));
    });

    test('parses dive samples', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];
      expect(log.samples, isNotEmpty);

      // Check first few samples
      final firstSample = log.samples[0];
      expect(firstSample.time, closeTo(0.0, 0.01));
      expect(firstSample.depth, closeTo(0.0, 0.01));

      // Check a sample with temperature
      final sampleWithTemp = log.samples.firstWhere((s) => s.hasTemperature());
      // 282.15K = 9°C
      expect(sampleWithTemp.temperature, closeTo(9.0, 0.1));
    });

    test('converts sample tank pressure from Pascal to bar', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      final log = dive.logs[0];

      // Find a sample with pressure
      final sampleWithPressure = log.samples.firstWhere((s) => s.pressures.isNotEmpty);
      // 20822167.02 Pa = ~208 bar
      expect(sampleWithPressure.pressures[0].pressure, closeTo(208.0, 1.0));
    });

    test('parses gas switch events with correct cylinder index', () {
      final dive = ssrf.dives.firstWhere((d) => d.id == '1CB06942-F009-4441-B559-4B3630F893F1');
      final log = dive.logs[0];

      // First sample should have a gas switch event (switchmix at start)
      final firstSample = log.samples[0];
      expect(firstSample.events, isNotEmpty);

      final gasChangeEvent = firstSample.events.firstWhere((e) => e.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
      expect(gasChangeEvent.type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);

      // First dive has Air (21% O2) as first cylinder, value should be 0
      expect(gasChangeEvent.value, 0);

      // Verify the cylinder at that index is Air
      expect(dive.cylinders[gasChangeEvent.value].oxygen, closeTo(0.21, 0.01));
    });
  });

  group('UDDF Import - Subsurface format', () {
    late Container ssrf;

    setUpAll(() {
      final file = File('test/testdata/sample-2.uddf');
      final xmlDoc = XmlDocument.parse(file.readAsStringSync());
      ssrf = UddfXml.fromXml(xmlDoc.rootElement);
    });

    test('parses sites from Subsurface export', () {
      expect(ssrf.sites, isNotEmpty);

      // Check site
      final site = ssrf.sites.firstWhere((s) => s.name.contains('Hällebäck'));
      expect(site.hasPosition(), isTrue);
      expect(site.position.latitude, closeTo(58.34605, 0.00001));
      expect(site.position.longitude, closeTo(11.58821, 0.00001));
    });

    test('parses dives from Subsurface export', () {
      expect(ssrf.dives, isNotEmpty);

      // Find the same dive as in MacDive export
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);
      expect(dive.hasStart(), isTrue);
      expect(dive.buddies, contains('Name Namesson'));
    });

    test('handles tank volume in liters (Subsurface style)', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      expect(dive.cylinders, isNotEmpty);
      final cyl = dive.cylinders[0];

      // Subsurface exports as liters (24.0) not m³ (0.024)
      expect(cyl.hasCylinder(), isTrue);
      expect(cyl.cylinder.volumeL, closeTo(24.0, 0.1));
    });

    test('parses air temperature from informationbeforedive', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      expect(dive.logs, isNotEmpty);
      final log = dive.logs[0];

      // Air temperature: 273.15K = 0°C
      expect(log.hasSurfaceTemperature(), isTrue);
      expect(log.surfaceTemperature, closeTo(0.0, 0.1));
    });

    test('parses lead weight from equipmentused', () {
      final dive = ssrf.dives.firstWhere((d) => d.number == 249);

      // Lead quantity: 4 kg
      expect(dive.weightsystems, isNotEmpty);
      expect(dive.weightsystems[0].weight, closeTo(4.0, 0.01));
      expect(dive.weightsystems[0].description, 'Lead');
    });
  });

  group('UDDF Import - hashtag extraction from notes', () {
    test('extracts tags from dive notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Great dive with lots of fish.

#wreck #deep #coldwater</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      expect(ssrf.dives, hasLength(1));
      final dive = ssrf.dives[0];

      // Tags should be extracted
      expect(dive.tags, containsAll(['wreck', 'deep', 'coldwater']));

      // Notes should not contain the hashtag line
      expect(dive.notes, 'Great dive with lots of fish.');
      expect(dive.notes, isNot(contains('#')));
    });

    test('extracts tags from site notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <divesite>
            <site id="site1">
              <name>Test Site</name>
              <notes>Beautiful reef location.

#reef #tropical #shallows</notes>
            </site>
          </divesite>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      expect(ssrf.sites, hasLength(1));
      final site = ssrf.sites[0];

      // Tags should be extracted
      expect(site.tags, containsAll(['reef', 'tropical', 'shallows']));

      // Notes should not contain the hashtag line
      expect(site.notes, 'Beautiful reef location.');
      expect(site.notes, isNot(contains('#')));
    });

    test('preserves notes when no hashtags present', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Just a regular note without tags.</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      expect(dive.tags, isEmpty);
      expect(dive.notes, 'Just a regular note without tags.');
    });

    test('does not extract hashtags from middle of notes', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>Saw a #shark today.
More text here.</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      // Should not extract since hashtag is not on a dedicated last line
      expect(dive.tags, isEmpty);
      expect(dive.notes, contains('#shark'));
    });

    test('handles notes that are only hashtags', () {
      final xml = '''
        <uddf xmlns="http://www.streit.cc/uddf/3.2/" version="3.2.0">
          <profiledata>
            <repetitiongroup id="rg1">
              <dive id="dive1">
                <informationbeforedive>
                  <divenumber>1</divenumber>
                  <datetime>2024-01-01T10:00:00</datetime>
                </informationbeforedive>
                <informationafterdive>
                  <notes>#training #pool</notes>
                </informationafterdive>
              </dive>
            </repetitiongroup>
          </profiledata>
        </uddf>
      ''';

      final xmlDoc = XmlDocument.parse(xml);
      final ssrf = UddfXml.fromXml(xmlDoc.rootElement);

      final dive = ssrf.dives[0];
      expect(dive.tags, containsAll(['training', 'pool']));
      expect(dive.hasNotes(), isFalse);
    });
  });

  group('UDDF export and roundtrip', () {
    // All data that has a UDDF representation must survive an export
    // followed by a re-import through the full import pipeline.
    late Container original;
    late String exported;
    late Container reimported;

    setUpAll(() {
      final site1 = Site(
        id: '9f0ac9d0-1111-4111-8111-000000000001',
        name: 'Hällebäck',
        position: Position(latitude: 58.34605, longitude: 11.58821),
        country: 'Sweden',
        location: 'Gullmarn',
        notes: 'Slack water required.\nWatch out for the current.',
        tags: ['shore', 'shallow'],
      );
      final site2 = Site(
        id: '9f0ac9d0-3333-4333-8333-000000000003',
        name: 'Simhallen',
        position: Position(latitude: 57.70887, longitude: 11.97456),
        notes: 'Beautiful, heated pool.',
      );

      final dive1 = Dive(
        id: '9f0ac9d0-2222-4222-8222-000000000002',
        number: 249,
        rating: 4,
        start: proto.Timestamp.fromDateTime(DateTime(2024, 11, 17, 10, 35, 35)),
        duration: 3530,
        maxDepth: 35.7,
        meanDepth: 15.2,
        siteId: site1.id,
        notes: 'Great dive.\nSaw a lobster.',
        tags: ['wreck', 'deep'],
        buddies: ['Name Namesson', 'Jakob von Borg'],
        cylinders: [
          DiveCylinder(cylinder: Cylinder(volumeL: 24.0), beginPressure: 208.2, endPressure: 111.5, oxygen: 0.21, helium: 0.0),
          DiveCylinder(oxygen: 0.5, helium: 0.0),
        ],
        weightsystems: [Weightsystem(weight: 6.0, description: 'Lead')],
        events: [SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: 1800, value: 1)],
        logs: [
          Log(
            maxDepth: 35.7,
            surfaceTemperature: 12.0,
            minTemperature: 8.0,
            samples: [
              LogSample(time: 0, depth: 0.0, events: [SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: 0, value: 0)]),
              LogSample(time: 60, depth: 12.5, temperature: 9.0, pressures: [TankPressure(tankIndex: 0, pressure: 200.0)]),
              LogSample(time: 1800, depth: 35.7, temperature: 8.0),
              LogSample(time: 3530, depth: 0.1),
            ],
          ),
        ],
      );
      final dive2 = Dive(
        id: '9f0ac9d0-4444-4444-8444-000000000004',
        number: 248,
        start: proto.Timestamp.fromDateTime(DateTime(2024, 11, 16, 15, 0, 0)),
        duration: 600,
        maxDepth: 5.5,
        siteId: site2.id,
        tags: ['training'],
        buddies: ['Name Namesson'],
        cylinders: [DiveCylinder(cylinder: Cylinder(volumeL: 12.0), oxygen: 0.21, helium: 0.0)],
        logs: [
          Log(samples: [LogSample(time: 0, depth: 0.0), LogSample(time: 600, depth: 5.5)]),
        ],
      );

      original = Container(dives: [dive1, dive2], sites: [site1, site2]);
      exported = original.toUddfString(version: '1.2.3');
      reimported = importXmlString(exported);
    });

    Dive reDive1() => reimported.dives.firstWhere((d) => d.id == '9f0ac9d0-2222-4222-8222-000000000002');
    Dive reDive2() => reimported.dives.firstWhere((d) => d.id == '9f0ac9d0-4444-4444-8444-000000000004');

    test('generates a UDDF 3.2.1 document', () {
      final doc = XmlDocument.parse(exported);
      final root = doc.rootElement;

      expect(root.name.local, 'uddf');
      expect(root.name.namespaceUri, 'http://www.streit.cc/uddf/3.2/');
      expect(root.getAttribute('version'), '3.2.1');
      expect(root.getElement('generator')?.getElement('name')?.innerText, 'Bubbletrail');
      expect(root.getElement('generator')?.getElement('version')?.innerText, '1.2.3');

      // Dives are exported chronologically.
      final dives = root.getElement('profiledata')?.findElements('repetitiongroup').expand((rg) => rg.findElements('dive')).toList();
      expect(dives, hasLength(2));
      expect(dives![0].getAttribute('id'), '9f0ac9d0-4444-4444-8444-000000000004');
      expect(dives[1].getAttribute('id'), '9f0ac9d0-2222-4222-8222-000000000002');

      // Every dive carries the elements the UDDF schema requires.
      for (final dive in dives) {
        expect(dive.getElement('informationbeforedive')?.getElement('datetime'), isNotNull);
        final after = dive.getElement('informationafterdive');
        expect(after?.getElement('greatestdepth'), isNotNull);
        expect(after?.getElement('diveduration'), isNotNull);
      }

      // Shared buddies and gas mixes are deduplicated into single
      // definitions (air, EAN50).
      expect(root.getElement('diver')?.findElements('buddy'), hasLength(2));
      expect(root.getElement('gasdefinitions')?.findElements('mix'), hasLength(2));
      expect(root.getElement('divesite')?.findElements('site'), hasLength(2));
    });

    test('sites fully roundtrip', () {
      expect(reimported.sites, hasLength(2));

      final site = reimported.sites.firstWhere((s) => s.id == '9f0ac9d0-1111-4111-8111-000000000001');
      expect(site.name, 'Hällebäck');
      expect(site.position.latitude, closeTo(58.34605, 1e-5));
      expect(site.position.longitude, closeTo(11.58821, 1e-5));
      expect(site.country, 'Sweden');
      expect(site.location, 'Gullmarn');
      expect(site.notes, 'Slack water required.\nWatch out for the current.');
      expect(site.tags, ['shore', 'shallow']);

      // Site without tags keeps its notes as-is.
      final pool = reimported.sites.firstWhere((s) => s.id == '9f0ac9d0-3333-4333-8333-000000000003');
      expect(pool.name, 'Simhallen');
      expect(pool.position.latitude, closeTo(57.70887, 1e-5));
      expect(pool.position.longitude, closeTo(11.97456, 1e-5));
      expect(pool.notes, 'Beautiful, heated pool.');
      expect(pool.tags, isEmpty);
    });

    test('dive metadata fully roundtrips', () {
      final dive = reDive1();
      final orig = original.dives.firstWhere((d) => d.id == dive.id);

      expect(dive.number, 249);
      expect(dive.hasRating(), isTrue);
      expect(dive.rating, 4);
      expect(dive.start.seconds, orig.start.seconds);
      expect(dive.start.nanos, 0);
      expect(dive.duration, 3530);
      expect(dive.maxDepth, closeTo(35.7, 1e-6));
      expect(dive.meanDepth, closeTo(15.2, 1e-6));
      expect(dive.minTemp, closeTo(8.0, 1e-6));
      expect(dive.siteId, orig.siteId);
      expect(dive.buddies, ['Name Namesson', 'Jakob von Borg']);
      expect(dive.notes, 'Great dive.\nSaw a lobster.');
      expect(dive.tags, ['wreck', 'deep']);
    });

    test('dive metadata without optionals roundtrips', () {
      final dive = reDive2();

      expect(dive.number, 248);
      expect(dive.hasRating(), isFalse);
      expect(dive.hasNotes(), isFalse);
      expect(dive.hasMinTemp(), isFalse);
      expect(dive.tags, ['training']);
      expect(dive.duration, 600);
      expect(dive.maxDepth, closeTo(5.5, 1e-6));
    });

    test('cylinders fully roundtrip', () {
      final dive = reDive1();
      expect(dive.cylinders, hasLength(2));

      final main = dive.cylinders[0];
      expect(main.hasCylinder(), isTrue);
      expect(main.cylinder.volumeL, closeTo(24.0, 1e-6));
      expect(main.beginPressure, closeTo(208.2, 1e-3));
      expect(main.endPressure, closeTo(111.5, 1e-3));
      expect(main.oxygen, closeTo(0.21, 1e-9));
      expect(main.helium, closeTo(0.0, 1e-9));

      final deco = dive.cylinders[1];
      expect(deco.hasCylinder(), isFalse);
      expect(deco.hasBeginPressure(), isFalse);
      expect(deco.hasEndPressure(), isFalse);
      expect(deco.oxygen, closeTo(0.5, 1e-9));
      expect(deco.helium, closeTo(0.0, 1e-9));
    });

    test('weights fully roundtrip', () {
      final dive = reDive1();
      expect(dive.weightsystems, hasLength(1));
      expect(dive.weightsystems[0].weight, closeTo(6.0, 1e-6));
      expect(dive.weightsystems[0].description, 'Lead');
    });

    test('dive profile fully roundtrips', () {
      final dive = reDive1();
      expect(dive.logs, hasLength(1));
      final log = dive.logs[0];

      expect(log.maxDepth, closeTo(35.7, 1e-6));
      expect(log.surfaceTemperature, closeTo(12.0, 1e-6));
      expect(log.minTemperature, closeTo(8.0, 1e-6));

      expect(log.samples, hasLength(4));
      expect(log.samples[0].time, closeTo(0, 1e-9));
      expect(log.samples[0].depth, closeTo(0.0, 1e-6));
      expect(log.samples[1].time, closeTo(60, 1e-9));
      expect(log.samples[1].depth, closeTo(12.5, 1e-6));
      expect(log.samples[1].temperature, closeTo(9.0, 1e-6));
      expect(log.samples[1].pressures, hasLength(1));
      expect(log.samples[1].pressures[0].tankIndex, 0);
      expect(log.samples[1].pressures[0].pressure, closeTo(200.0, 1e-3));
      expect(log.samples[2].time, closeTo(1800, 1e-9));
      expect(log.samples[2].depth, closeTo(35.7, 1e-6));
      expect(log.samples[3].time, closeTo(3530, 1e-9));
      expect(log.samples[3].depth, closeTo(0.1, 1e-6));
    });

    test('gas switch events fully roundtrip', () {
      final log = reDive1().logs[0];

      // Initial gas switch carried by the first sample.
      expect(log.samples[0].events, hasLength(1));
      expect(log.samples[0].events[0].type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
      expect(log.samples[0].events[0].value, 0);
      expect(log.samples[0].events[0].time, 0);

      // Gas switch carried by the dive (as downloaded dives do), landing on
      // the sample at the switch time.
      expect(log.samples[2].events, hasLength(1));
      expect(log.samples[2].events[0].type, SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
      expect(log.samples[2].events[0].value, 1);
      expect(log.samples[2].events[0].time, 1800);

      // The switch target is the EAN50 cylinder.
      expect(reDive1().cylinders[1].oxygen, closeTo(0.5, 1e-9));
    });

    test('exports an empty logbook', () {
      final xml = Container().toUddfString();
      final re = importXmlString(xml);
      expect(re.dives, isEmpty);
      expect(re.sites, isEmpty);
    });

    // The strongest form of the roundtrip guarantee: data that came from a
    // UDDF file (both the MacDive and the Subsurface flavoured samples)
    // survives an export followed by a re-import completely unchanged.
    for (final sample in ['sample-1.uddf', 'sample-2.uddf']) {
      test('$sample survives export + re-import unchanged', () {
        final file = File('test/testdata/$sample');
        final original = UddfXml.fromXml(XmlDocument.parse(file.readAsStringSync()).rootElement);
        final reimported = importXmlString(original.toUddfString());

        expect(reimported.sites.length, original.sites.length);
        for (final site in original.sites) {
          expect(reimported.sites, contains(site));
        }
        expect(reimported.dives.length, original.dives.length);
        for (final dive in original.dives) {
          expect(reimported.dives, contains(dive));
        }
      });
    }
  });
}
