import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../types.dart';
import 'database.dart';

class DiveStorage {
  Future<List<String>> getAllTags() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('tags', orderBy: 'name');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<List<String>> getAllBuddies() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('buddies', orderBy: 'name');
    return maps.map((m) => m['name'] as String).toList();
  }

  Future<void> insert(Dive dive) async {
    final db = await SsrfDatabase.database;
    await db.transaction((txn) async {
      await txn.insert('dives', _diveToMap(dive));
      await _insertChildren(txn, dive);
    });
  }

  Future<void> insertAll(List<Dive> dives) async {
    final db = await SsrfDatabase.database;
    await db.transaction((txn) async {
      for (final dive in dives) {
        await txn.insert('dives', _diveToMap(dive));
        await _insertChildren(txn, dive);
      }
    });
  }

  Future<void> update(Dive dive) async {
    final db = await SsrfDatabase.database;
    await db.transaction((txn) async {
      await txn.update('dives', _diveToMap(dive), where: 'id = ?', whereArgs: [dive.id]);
      await _deleteChildren(txn, dive.id);
      await _insertChildren(txn, dive);
    });
  }

  Future<void> delete(String id) async {
    final db = await SsrfDatabase.database;
    await db.delete('dives', where: 'id = ?', whereArgs: [id]);
  }

  Future<Dive?> getById(String id) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('dives', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _mapToDive(db, maps.first);
  }

  Future<List<Dive>> getAll() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('dives', orderBy: 'start DESC');
    return Future.wait(maps.map((m) => _mapToDive(db, m)));
  }

  Future<int> get nextDiveNo async {
    final db = await SsrfDatabase.database;
    final maps = await db.rawQuery('SELECT 1+max(number) AS next FROM dives');
    if (maps.isEmpty || maps[0]['next'] == null) return 1;
    return maps[0]['next'] as int;
  }

  /// Returns all dives with only the overview data (from dives table only).
  /// Does not load children like cylinders, weightsystems, divecomputers, etc.
  Future<List<Dive>> getAllOverview() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('dives', orderBy: 'start DESC');
    return maps.map(_mapToDiveOverview).toList();
  }

  Dive _mapToDiveOverview(Map<String, Object?> m) {
    return Dive(
      id: m['id'] as String,
      number: m['number'] as int,
      start: DateTime.fromMillisecondsSinceEpoch((m['start'] as int) * 1000),
      duration: m['duration'] as int,
      rating: m['rating'] as int?,
      maxDepth: m['max_depth'] as double?,
      meanDepth: m['mean_depth'] as double?,
      sac: m['sac'] as double?,
      otu: m['otu'] as int?,
      cns: m['cns'] as int?,
      divesiteid: m['divesiteid'] as String?,
      divemaster: m['divemaster'] as String?,
      notes: m['notes'] as String?,
    );
  }

  Future<void> _insertChildren(Transaction txn, Dive dive) async {
    for (final tag in dive.tags) {
      final tagId = await _getOrCreateTag(txn, tag);
      await txn.insert('dive_tags', {'dive_id': dive.id, 'tag_id': tagId});
    }
    for (final buddy in dive.buddies) {
      final buddyId = await _getOrCreateBuddy(txn, buddy);
      await txn.insert('dive_buddies', {'dive_id': dive.id, 'buddy_id': buddyId});
    }
    for (var i = 0; i < dive.cylinders.length; i++) {
      final dc = dive.cylinders[i];
      var cylinderId = dc.cylinderId;
      // If cylinderId is 0, we need to get or create the cylinder from the embedded data
      if (cylinderId == 0 && dc.cylinder != null) {
        cylinderId = await _getOrCreateCylinder(txn, dc.cylinder!);
      }
      await txn.insert('dive_cylinders', {
        'dive_id': dive.id,
        'cylinder_id': cylinderId,
        'idx': i,
        'start_pressure': dc.start,
        'end_pressure': dc.end,
        'o2': dc.o2,
        'he': dc.he,
      });
    }
    for (var i = 0; i < dive.weightsystems.length; i++) {
      await txn.insert('weightsystems', _weightsystemToMap(dive.id, i, dive.weightsystems[i]));
    }
    for (var i = 0; i < dive.divecomputers.length; i++) {
      final dcLog = dive.divecomputers[i];
      var diveComputerId = dcLog.diveComputerId;
      // If diveComputerId is 0, we need to get or create the dive computer from the embedded data
      if (diveComputerId == 0 && dcLog.diveComputer != null) {
        diveComputerId = await _getOrCreateDiveComputer(txn, dcLog.diveComputer!);
      }
      final logId = await txn.insert('dive_computer_logs', {
        'dive_id': dive.id,
        'divecomputer_id': diveComputerId,
        'idx': i,
        'max_depth': dcLog.maxDepth,
        'mean_depth': dcLog.meanDepth,
        'air_temperature': dcLog.environment?.airTemperature,
        'water_temperature': dcLog.environment?.waterTemperature,
        'extradata': dcLog.extradata.isNotEmpty ? jsonEncode(dcLog.extradata) : null,
      });
      for (final sample in dcLog.samples) {
        await txn.insert('samples', _sampleToMap(logId, sample));
      }
      for (final event in dcLog.events) {
        await txn.insert('events', _eventToMap(logId, event));
      }
    }
  }

  Future<int> _getOrCreateTag(Transaction txn, String name) async {
    final existing = await txn.query('tags', where: 'name = ?', whereArgs: [name]);
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return txn.insert('tags', {'name': name});
  }

  Future<int> _getOrCreateBuddy(Transaction txn, String name) async {
    final existing = await txn.query('buddies', where: 'name = ?', whereArgs: [name]);
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return txn.insert('buddies', {'name': name});
  }

  Future<int> _getOrCreateCylinder(Transaction txn, Cylinder c) async {
    final existing = await txn.query(
      'cylinders',
      where: 'size IS ? AND workpressure IS ? AND description IS ?',
      whereArgs: [c.size, c.workpressure, c.description],
    );
    if (existing.isNotEmpty) {
      return existing.first['id'] as int;
    }
    return txn.insert('cylinders', {'size': c.size, 'workpressure': c.workpressure, 'description': c.description});
  }

  Future<int> _getOrCreateDiveComputer(Transaction txn, DiveComputer dc) async {
    // Try to find by model (and serial if provided)
    if (dc.serial != null) {
      final exact = await txn.query('divecomputers', where: 'model = ? AND serial = ?', whereArgs: [dc.model, dc.serial]);
      if (exact.isNotEmpty) return exact.first['id'] as int;
    }
    // Try by model only
    final byModel = await txn.query('divecomputers', where: 'model = ?', whereArgs: [dc.model]);
    if (byModel.isNotEmpty) {
      final existing = byModel.first;
      // Update serial if we now have one and the existing doesn't
      if (dc.serial != null && existing['serial'] == null) {
        await txn.update('divecomputers', {'serial': dc.serial}, where: 'id = ?', whereArgs: [existing['id']]);
      }
      return existing['id'] as int;
    }
    // Create new
    return txn.insert('divecomputers', {'model': dc.model, 'serial': dc.serial});
  }

  Future<void> _deleteChildren(Transaction txn, String diveId) async {
    await txn.delete('dive_tags', where: 'dive_id = ?', whereArgs: [diveId]);
    await txn.delete('dive_buddies', where: 'dive_id = ?', whereArgs: [diveId]);
    final logIds = await txn.query('dive_computer_logs', columns: ['id'], where: 'dive_id = ?', whereArgs: [diveId]);
    for (final log in logIds) {
      await txn.delete('samples', where: 'dive_computer_log_id = ?', whereArgs: [log['id']]);
      await txn.delete('events', where: 'dive_computer_log_id = ?', whereArgs: [log['id']]);
    }
    await txn.delete('dive_computer_logs', where: 'dive_id = ?', whereArgs: [diveId]);
    await txn.delete('dive_cylinders', where: 'dive_id = ?', whereArgs: [diveId]);
    await txn.delete('weightsystems', where: 'dive_id = ?', whereArgs: [diveId]);
  }

  Map<String, Object?> _diveToMap(Dive dive) => {
    'id': dive.id,
    'number': dive.number,
    'rating': dive.rating,
    'start': dive.start.millisecondsSinceEpoch ~/ 1000,
    'duration': dive.duration,
    'max_depth': dive.maxDepth,
    'mean_depth': dive.meanDepth,
    'sac': dive.sac,
    'otu': dive.otu,
    'cns': dive.cns,
    'divesiteid': dive.divesiteid,
    'divemaster': dive.divemaster,
    'notes': dive.notes,
  };

  Map<String, Object?> _weightsystemToMap(String diveId, int idx, Weightsystem w) => {
    'dive_id': diveId,
    'idx': idx,
    'weight': w.weight,
    'description': w.description,
  };

  Map<String, Object?> _sampleToMap(int diveComputerLogId, Sample s) => {
    'dive_computer_log_id': diveComputerLogId,
    'time': s.time,
    'depth': s.depth,
    'temp': s.temp,
    'pressure': s.pressure,
  };

  Map<String, Object?> _eventToMap(int diveComputerLogId, Event e) => {
    'dive_computer_log_id': diveComputerLogId,
    'time': e.time,
    'type': e.type,
    'value': e.value,
    'name': e.name,
    'cylinder': e.cylinder,
  };

  Future<Dive> _mapToDive(Database db, Map<String, Object?> m) async {
    final diveId = m['id'] as String;

    final dive = Dive(
      id: diveId,
      number: m['number'] as int,
      start: DateTime.fromMillisecondsSinceEpoch((m['start'] as int) * 1000),
      duration: m['duration'] as int,
      rating: m['rating'] as int?,
      maxDepth: m['max_depth'] as double?,
      meanDepth: m['mean_depth'] as double?,
      sac: m['sac'] as double?,
      otu: m['otu'] as int?,
      cns: m['cns'] as int?,
      divesiteid: m['divesiteid'] as String?,
      divemaster: m['divemaster'] as String?,
      notes: m['notes'] as String?,
    );

    dive.tags = await _loadTags(db, diveId);
    dive.buddies = await _loadBuddies(db, diveId);
    dive.cylinders = await _loadCylinders(db, diveId);
    dive.weightsystems = await _loadWeightsystems(db, diveId);
    dive.divecomputers = await _loadDivecomputers(db, diveId);

    return dive;
  }

  Future<Set<String>> _loadTags(Database db, String diveId) async {
    final maps = await db.rawQuery(
      '''
      SELECT t.name FROM tags t
      INNER JOIN dive_tags dt ON dt.tag_id = t.id
      WHERE dt.dive_id = ?
    ''',
      [diveId],
    );
    return maps.map((m) => m['name'] as String).toSet();
  }

  Future<Set<String>> _loadBuddies(Database db, String diveId) async {
    final maps = await db.rawQuery(
      '''
      SELECT b.name FROM buddies b
      INNER JOIN dive_buddies db ON db.buddy_id = b.id
      WHERE db.dive_id = ?
    ''',
      [diveId],
    );
    return maps.map((m) => m['name'] as String).toSet();
  }

  Future<List<DiveCylinder>> _loadCylinders(Database db, String diveId) async {
    final maps = await db.rawQuery(
      '''
      SELECT dc.*, c.size, c.workpressure, c.description
      FROM dive_cylinders dc
      INNER JOIN cylinders c ON c.id = dc.cylinder_id
      WHERE dc.dive_id = ?
      ORDER BY dc.idx
    ''',
      [diveId],
    );
    return maps
        .map(
          (m) => DiveCylinder(
            cylinderId: m['cylinder_id'] as int,
            cylinder: Cylinder(
              id: m['cylinder_id'] as int,
              size: m['size'] as double?,
              workpressure: m['workpressure'] as double?,
              description: m['description'] as String?,
            ),
            start: m['start_pressure'] as double?,
            end: m['end_pressure'] as double?,
            o2: m['o2'] as double?,
            he: m['he'] as double?,
          ),
        )
        .toList();
  }

  Future<List<Weightsystem>> _loadWeightsystems(Database db, String diveId) async {
    final maps = await db.query('weightsystems', where: 'dive_id = ?', whereArgs: [diveId], orderBy: 'idx');
    return maps.map((m) => Weightsystem(weight: m['weight'] as double?, description: m['description'] as String?)).toList();
  }

  Future<List<DiveComputerLog>> _loadDivecomputers(Database db, String diveId) async {
    final maps = await db.rawQuery(
      '''
      SELECT dcl.*, dc.model, dc.serial
      FROM dive_computer_logs dcl
      INNER JOIN divecomputers dc ON dc.id = dcl.divecomputer_id
      WHERE dcl.dive_id = ?
      ORDER BY dcl.idx
    ''',
      [diveId],
    );
    final result = <DiveComputerLog>[];
    for (final m in maps) {
      final logId = m['id'] as int;
      final samples = await _loadSamples(db, logId);
      final events = await _loadEvents(db, logId);

      Environment? environment;
      final airTemp = m['air_temperature'] as double?;
      final waterTemp = m['water_temperature'] as double?;
      if (airTemp != null || waterTemp != null) {
        environment = Environment(airTemperature: airTemp, waterTemperature: waterTemp);
      }

      Map<String, String>? extradata;
      final extradataJson = m['extradata'] as String?;
      if (extradataJson != null) {
        extradata = Map<String, String>.from(jsonDecode(extradataJson));
      }

      result.add(
        DiveComputerLog(
          diveComputerId: m['divecomputer_id'] as int,
          diveComputer: DiveComputer(id: m['divecomputer_id'] as int, model: m['model'] as String, serial: m['serial'] as String?),
          maxDepth: m['max_depth'] as double,
          meanDepth: m['mean_depth'] as double,
          environment: environment,
          samples: samples,
          events: events,
          extradata: extradata,
        ),
      );
    }
    return result;
  }

  Future<List<Sample>> _loadSamples(Database db, int diveComputerLogId) async {
    final maps = await db.query('samples', where: 'dive_computer_log_id = ?', whereArgs: [diveComputerLogId], orderBy: 'time');
    return maps
        .map((m) => Sample(time: m['time'] as int, depth: m['depth'] as double, temp: m['temp'] as double?, pressure: m['pressure'] as double?))
        .toList();
  }

  Future<List<Event>> _loadEvents(Database db, int diveComputerLogId) async {
    final maps = await db.query('events', where: 'dive_computer_log_id = ?', whereArgs: [diveComputerLogId], orderBy: 'time');
    return maps
        .map(
          (m) => Event(time: m['time'] as int, type: m['type'] as int?, value: m['value'] as int?, name: m['name'] as String?, cylinder: m['cylinder'] as int?),
        )
        .toList();
  }
}
