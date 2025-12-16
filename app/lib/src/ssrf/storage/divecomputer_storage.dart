import '../types.dart';
import 'database.dart';

class DiveComputerStorage {
  Future<int> insert(DiveComputer dc) async {
    final db = await SsrfDatabase.database;
    return db.insert('divecomputers', _toMap(dc));
  }

  Future<void> update(DiveComputer dc) async {
    final db = await SsrfDatabase.database;
    await db.update('divecomputers', _toMap(dc), where: 'id = ?', whereArgs: [dc.id]);
  }

  Future<void> delete(int id) async {
    final db = await SsrfDatabase.database;
    await db.delete('divecomputers', where: 'id = ?', whereArgs: [id]);
  }

  Future<DiveComputer?> getById(int id) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('divecomputers', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<DiveComputer>> getAll() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('divecomputers', orderBy: 'model');
    return maps.map(_fromMap).toList();
  }

  Future<DiveComputer?> findByModelAndSerial(String model, String? serial) async {
    final db = await SsrfDatabase.database;
    final List<Map<String, Object?>> maps;
    if (serial != null) {
      maps = await db.query('divecomputers', where: 'model = ? AND serial = ?', whereArgs: [model, serial]);
    } else {
      maps = await db.query('divecomputers', where: 'model = ? AND serial IS NULL', whereArgs: [model]);
    }
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<DiveComputer?> findByModel(String model) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('divecomputers', where: 'model = ?', whereArgs: [model]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<DiveComputer> getOrCreate(String model, String? serial, {String? deviceid, String? diveid, String? fingerprintData}) async {
    // First try exact match (model + serial)
    if (serial != null) {
      final exact = await findByModelAndSerial(model, serial);
      if (exact != null) {
        // Update fingerprint data if provided
        if (deviceid != null || diveid != null || fingerprintData != null) {
          final updated = DiveComputer(
            id: exact.id,
            model: model,
            serial: serial,
            deviceid: deviceid ?? exact.deviceid,
            diveid: diveid ?? exact.diveid,
            fingerprintData: fingerprintData ?? exact.fingerprintData,
          );
          await update(updated);
          return updated;
        }
        return exact;
      }
    }

    // Try to find by model only (for updates when serial becomes known)
    final byModel = await findByModel(model);
    if (byModel != null) {
      // Update if we have new info
      if ((serial != null && byModel.serial == null) ||
          (deviceid != null && byModel.deviceid == null) ||
          (diveid != null && byModel.diveid == null) ||
          (fingerprintData != null && byModel.fingerprintData == null)) {
        final updated = DiveComputer(
          id: byModel.id,
          model: model,
          serial: serial ?? byModel.serial,
          deviceid: deviceid ?? byModel.deviceid,
          diveid: diveid ?? byModel.diveid,
          fingerprintData: fingerprintData ?? byModel.fingerprintData,
        );
        await update(updated);
        return updated;
      }
      return byModel;
    }

    // Create new
    final db = await SsrfDatabase.database;
    final id = await db.insert('divecomputers', {
      'model': model,
      'serial': serial,
      'deviceid': deviceid,
      'diveid': diveid,
      'fingerprint_data': fingerprintData,
    });
    return DiveComputer(id: id, model: model, serial: serial, deviceid: deviceid, diveid: diveid, fingerprintData: fingerprintData);
  }

  Map<String, Object?> _toMap(DiveComputer dc) => {
        'id': dc.id,
        'model': dc.model,
        'serial': dc.serial,
        'deviceid': dc.deviceid,
        'diveid': dc.diveid,
        'fingerprint_data': dc.fingerprintData,
      };

  DiveComputer _fromMap(Map<String, Object?> m) => DiveComputer(
        id: m['id'] as int,
        model: m['model'] as String,
        serial: m['serial'] as String?,
        deviceid: m['deviceid'] as String?,
        diveid: m['diveid'] as String?,
        fingerprintData: m['fingerprint_data'] as String?,
      );
}
