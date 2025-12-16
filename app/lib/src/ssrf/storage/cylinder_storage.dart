import '../types.dart';
import 'database.dart';

class CylinderStorage {
  Future<int> insert(Cylinder cylinder) async {
    final db = await SsrfDatabase.database;
    return db.insert('cylinders', _toMap(cylinder));
  }

  Future<void> update(Cylinder cylinder) async {
    final db = await SsrfDatabase.database;
    await db.update('cylinders', _toMap(cylinder), where: 'id = ?', whereArgs: [cylinder.id]);
  }

  Future<void> delete(int id) async {
    final db = await SsrfDatabase.database;
    await db.delete('cylinders', where: 'id = ?', whereArgs: [id]);
  }

  Future<Cylinder?> getById(int id) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('cylinders', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<List<Cylinder>> getAll() async {
    final db = await SsrfDatabase.database;
    final maps = await db.query('cylinders', orderBy: 'description');
    return maps.map(_fromMap).toList();
  }

  Future<Cylinder?> findByProperties(double? size, double? workpressure, String? description) async {
    final db = await SsrfDatabase.database;
    final maps = await db.query(
      'cylinders',
      where: 'size IS ? AND workpressure IS ? AND description IS ?',
      whereArgs: [size, workpressure, description],
    );
    if (maps.isEmpty) return null;
    return _fromMap(maps.first);
  }

  Future<Cylinder> getOrCreate(double? size, double? workpressure, String? description) async {
    final existing = await findByProperties(size, workpressure, description);
    if (existing != null) return existing;

    final db = await SsrfDatabase.database;
    final id = await db.insert('cylinders', {
      'size': size,
      'workpressure': workpressure,
      'description': description,
    });
    return Cylinder(id: id, size: size, workpressure: workpressure, description: description);
  }

  Map<String, Object?> _toMap(Cylinder c) => {
        'id': c.id,
        'size': c.size,
        'workpressure': c.workpressure,
        'description': c.description,
      };

  Cylinder _fromMap(Map<String, Object?> m) => Cylinder(
        id: m['id'] as int,
        size: m['size'] as double?,
        workpressure: m['workpressure'] as double?,
        description: m['description'] as String?,
      );
}
