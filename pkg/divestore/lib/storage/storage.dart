import '../types.dart';
import 'cylinder_storage.dart';
import 'database.dart';
import 'dive_storage.dart';
import 'divecomputer_storage.dart';
import 'divesite_storage.dart';

export 'cylinder_storage.dart';
export 'database.dart';
export 'dive_storage.dart';
export 'divecomputer_storage.dart';
export 'divesite_storage.dart';

class SsrfStorage {
  final CylinderStorage cylinders = CylinderStorage();
  final DiveComputerStorage divecomputers = DiveComputerStorage();
  final DiveStorage dives = DiveStorage();
  final DivesiteStorage divesites = DivesiteStorage();

  Future<Ssrf> loadAll() async {
    final diveList = await dives.getAll();
    final siteList = await divesites.getAll();
    final dcList = await divecomputers.getAll();
    return Ssrf(dives: diveList, diveSites: siteList, diveComputers: dcList);
  }

  Future<void> saveAll(Ssrf ssrf) async {
    final db = await SsrfDatabase.database;
    await db.transaction((txn) async {
      await txn.delete('computer_dives');
      await txn.delete('weightsystems');
      await txn.delete('dive_cylinders');
      await txn.delete('dive_tags');
      await txn.delete('dive_buddies');
      await txn.delete('dives');
      await txn.delete('divecomputers');
      await txn.delete('cylinders');
      await txn.delete('tags');
      await txn.delete('buddies');
      await txn.delete('divesites');
    });

    await divesites.insertAll(ssrf.diveSites);
    await dives.insertAll(ssrf.dives);
    // DiveComputers are created/updated during dives.insertAll when processing DiveComputerLogs
    // Additional dive computers from XML (with fingerprint data) are saved separately
    for (final dc in ssrf.diveComputers) {
      await divecomputers.getOrCreate(
        dc.model,
        dc.serial,
        deviceid: dc.deviceid,
        diveid: dc.diveid,
        fingerprintData: dc.fingerprintData,
      );
    }
  }

  Future<void> close() => SsrfDatabase.close();
}
