import 'dart:io';

import 'package:divepath/src/ssrf/ssrf.dart';
import 'package:divepath/src/ssrf/storage/storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:xml/xml.dart';

void main() {
  late SsrfStorage storage;

  setUpAll(() {
    // Initialize FFI for desktop testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    // Set up in-memory database for testing
    SsrfDatabase.setTestDatabaseFactory(() async {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(version: 1),
      );
      await SsrfDatabase.createSchema(db);
      return db;
    });
  });

  setUp(() {
    storage = SsrfStorage();
  });

  tearDown(() async {
    await SsrfDatabase.close();
  });

  test('Round-trip: Load XML, store in database, load from database', () async {
    // Load sample XML file
    final xmlData = await File('./test/testdata/subsurface-sample.xml').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final originalSsrf = SsrfXml.fromXml(doc.rootElement);

    // Verify we loaded the expected data
    expect(originalSsrf.dives.length, 54);
    expect(originalSsrf.diveSites.length, 32);
    expect(originalSsrf.diveComputers.length, 3);

    // Store in database
    await storage.saveAll(originalSsrf);

    // Load from database
    final loadedSsrf = await storage.loadAll();

    // Verify counts match
    expect(loadedSsrf.dives.length, originalSsrf.dives.length);
    expect(loadedSsrf.diveSites.length, originalSsrf.diveSites.length);

    // Verify first dive (dive #257)
    final originalFirst = originalSsrf.dives[0];
    final loadedFirst = loadedSsrf.dives.firstWhere((d) => d.number == 257);

    expect(loadedFirst.number, originalFirst.number);
    expect(loadedFirst.rating, originalFirst.rating);
    expect(loadedFirst.duration, originalFirst.duration);
    expect(loadedFirst.maxDepth, closeTo(originalFirst.maxDepth!, 0.01));
    expect(loadedFirst.meanDepth, closeTo(originalFirst.meanDepth!, 0.001));
    expect(loadedFirst.sac, closeTo(originalFirst.sac!, 0.001));
    expect(loadedFirst.tags, originalFirst.tags);
    expect(loadedFirst.divesiteid, originalFirst.divesiteid);
    expect(loadedFirst.divemaster, originalFirst.divemaster);
    expect(loadedFirst.buddies, originalFirst.buddies);
    expect(loadedFirst.notes, originalFirst.notes);

    // Verify cylinder data
    expect(loadedFirst.cylinders.length, originalFirst.cylinders.length);
    expect(loadedFirst.cylinders[0].cylinder?.size, originalFirst.cylinders[0].cylinder?.size);
    expect(loadedFirst.cylinders[0].cylinder?.workpressure, originalFirst.cylinders[0].cylinder?.workpressure);
    expect(loadedFirst.cylinders[0].cylinder?.description, originalFirst.cylinders[0].cylinder?.description);

    // Verify weightsystem data
    expect(loadedFirst.weightsystems.length, originalFirst.weightsystems.length);
    expect(loadedFirst.weightsystems[0].weight, originalFirst.weightsystems[0].weight);

    // Verify dive computer log data
    expect(loadedFirst.divecomputers.length, originalFirst.divecomputers.length);
    final originalDcLog = originalFirst.divecomputers[0];
    final loadedDcLog = loadedFirst.divecomputers[0];
    expect(loadedDcLog.maxDepth, closeTo(originalDcLog.maxDepth, 0.01));
    expect(loadedDcLog.meanDepth, closeTo(originalDcLog.meanDepth, 0.001));
    expect(loadedDcLog.environment?.waterTemperature, originalDcLog.environment?.waterTemperature);

    // Verify samples
    expect(loadedDcLog.samples.length, originalDcLog.samples.length);
    expect(loadedDcLog.samples[0].depth, closeTo(originalDcLog.samples[0].depth, 0.01));
    expect(loadedDcLog.samples[0].time, originalDcLog.samples[0].time);

    // Verify events
    expect(loadedDcLog.events.length, originalDcLog.events.length);
    expect(loadedDcLog.events[0].name, originalDcLog.events[0].name);

    // Verify last dive (dive #310)
    final originalLast = originalSsrf.dives[53];
    final loadedLast = loadedSsrf.dives.firstWhere((d) => d.number == 310);

    expect(loadedLast.number, originalLast.number);
    expect(loadedLast.duration, originalLast.duration);
    expect(loadedLast.maxDepth, closeTo(originalLast.maxDepth!, 0.01));
    expect(loadedLast.meanDepth, closeTo(originalLast.meanDepth!, 0.001));
    expect(loadedLast.divecomputers.length, greaterThan(0));
    expect(loadedLast.divecomputers[0].maxDepth, closeTo(originalLast.divecomputers[0].maxDepth, 0.01));

    // Verify a dive site
    final originalSite = originalSsrf.diveSites[0];
    final loadedSite = loadedSsrf.diveSites.firstWhere((s) => s.uuid == originalSite.uuid);
    expect(loadedSite.name, originalSite.name);
    expect(loadedSite.position?.lat, closeTo(originalSite.position!.lat, 0.000001));
    expect(loadedSite.position?.lon, closeTo(originalSite.position!.lon, 0.000001));
  });

  test('Dive computer normalization', () async {
    // Load sample XML file
    final xmlData = await File('./test/testdata/subsurface-sample.xml').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final originalSsrf = SsrfXml.fromXml(doc.rootElement);

    // Store in database
    await storage.saveAll(originalSsrf);

    // Get all dive computers from storage
    final diveComputers = await storage.divecomputers.getAll();

    // All 54 dives should reference a limited set of dive computers
    // (normalized by model name)
    expect(diveComputers.length, lessThan(originalSsrf.dives.length));

    // Verify each dive computer has a model
    for (final dc in diveComputers) {
      expect(dc.model, isNotEmpty);
    }
  });

  test('Tags and buddies normalization', () async {
    // Load sample XML file
    final xmlData = await File('./test/testdata/subsurface-sample.xml').readAsString();
    final doc = XmlDocument.parse(xmlData);
    final originalSsrf = SsrfXml.fromXml(doc.rootElement);

    // Store in database
    await storage.saveAll(originalSsrf);

    // Get all tags
    final tags = await storage.dives.getAllTags();

    // Collect unique tags from original data
    final originalTags = <String>{};
    for (final dive in originalSsrf.dives) {
      originalTags.addAll(dive.tags);
    }

    // Database should have the same unique tags
    expect(tags.toSet(), originalTags);

    // Get all buddies
    final buddies = await storage.dives.getAllBuddies();

    // Collect unique buddies from original data
    final originalBuddies = <String>{};
    for (final dive in originalSsrf.dives) {
      originalBuddies.addAll(dive.buddies);
    }

    // Database should have the same unique buddies
    expect(buddies.toSet(), originalBuddies);
  });

  test('Individual dive CRUD operations', () async {
    // Create a test dive
    final dive = Dive(
      number: 999,
      start: DateTime(2024, 1, 15, 10, 30, 0),
      duration: 3600,
      rating: 5,
      maxDepth: 25.5,
      meanDepth: 15.2,
      sac: 15.0,
      otu: 20,
      cns: 10,
      divemaster: 'Test Divemaster',
      notes: 'Test notes for this dive.',
    );
    dive.tags.addAll(['Test', 'Shore']);
    dive.buddies.add('Test Buddy');
    dive.cylinders.add(const DiveCylinder(
      cylinderId: 0,
      cylinder: Cylinder(id: 0, size: 12.0, workpressure: 200.0, description: 'AL80'),
      start: 200.0,
      end: 50.0,
      o2: 32.0,
    ));
    dive.weightsystems.add(const Weightsystem(weight: 4.0, description: 'Belt'));
    dive.divecomputers.add(DiveComputerLog(
      diveComputerId: 0,
      diveComputer: const DiveComputer(id: 0, model: 'Test Computer', serial: 'TEST123'),
      maxDepth: 25.5,
      meanDepth: 15.2,
      environment: Environment(airTemperature: 25.0, waterTemperature: 20.0),
      samples: [
        const Sample(time: 0, depth: 0.0),
        const Sample(time: 60, depth: 10.0, temp: 20.0),
        const Sample(time: 120, depth: 25.5, temp: 19.5, pressure: 180.0),
      ],
      events: [const Event(time: 0, name: 'gaschange', type: 11, value: 32, cylinder: 0)],
    ));

    // Insert
    await storage.dives.insert(dive);

    // Read back
    final loaded = await storage.dives.getById(dive.id);
    expect(loaded, isNotNull);
    expect(loaded!.number, 999);
    expect(loaded.rating, 5);
    expect(loaded.maxDepth, 25.5);
    expect(loaded.meanDepth, 15.2);
    expect(loaded.sac, 15.0);
    expect(loaded.tags, {'Test', 'Shore'});
    expect(loaded.buddies, {'Test Buddy'});
    expect(loaded.cylinders.length, 1);
    expect(loaded.cylinders[0].o2, 32.0);
    expect(loaded.weightsystems.length, 1);
    expect(loaded.divecomputers.length, 1);
    expect(loaded.divecomputers[0].samples.length, 3);
    expect(loaded.divecomputers[0].events.length, 1);

    // Update
    dive.rating = 4;
    dive.notes = 'Updated notes';
    dive.tags.add('Night');
    await storage.dives.update(dive);

    // Read back updated
    final updated = await storage.dives.getById(dive.id);
    expect(updated!.rating, 4);
    expect(updated.notes, 'Updated notes');
    expect(updated.tags, {'Test', 'Shore', 'Night'});

    // Delete
    await storage.dives.delete(dive.id);
    final deleted = await storage.dives.getById(dive.id);
    expect(deleted, isNull);
  });
}
