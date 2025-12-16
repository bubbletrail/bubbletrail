import '../types.dart';
import 'database.dart';

class DivesiteStorage {
  Future<void> insert(Divesite site) async {
    final db = await SsrfDatabase.database;
    await db.insert('divesites', _toMap(site));
  }

  Future<void> insertAll(List<Divesite> sites) async {
    final db = await SsrfDatabase.database;
    await db.transaction((txn) async {
      for (final site in sites) {
        await txn.insert('divesites', _toMap(site));
      }
    });
  }

  Future<void> update(Divesite site) async {
    final db = await SsrfDatabase.database;
    await db.update('divesites', _toMap(site), where: 'uuid = ?', whereArgs: [site.uuid]);
  }

  Future<void> delete(String uuid) async {
    final db = await SsrfDatabase.database;
    await db.delete('divesites', where: 'uuid = ?', whereArgs: [uuid]);
  }

  Future<Divesite?> getById(String uuid) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('divesites', where: 'uuid = ?', whereArgs: [uuid]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<Divesite>> getAll() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('divesites', orderBy: 'name');
    return maps.map(_fromMap).toList();
  }

  Map<String, Object?> _toMap(Divesite site) => {
        'uuid': site.uuid,
        'name': site.name,
        'lat': site.position?.lat,
        'lon': site.position?.lon,
      };

  Divesite _fromMap(Map<String, Object?> m) {
    GPSPosition? position;
    final lat = m['lat'] as double?;
    final lon = m['lon'] as double?;
    if (lat != null && lon != null) {
      position = GPSPosition(lat, lon);
    }
    return Divesite(
      uuid: m['uuid'] as String,
      name: m['name'] as String,
      position: position,
    );
  }
}
