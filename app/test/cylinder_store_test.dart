import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/store.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:test/test.dart';

void main() {
  late Directory tmp;
  late Store store;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('cylinder_store_test');
    store = Store('${tmp.path}/db');
    await store.init();
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  Dive diveWithCylinders(String id, List<DiveCylinder> cylinders, {List<Log> logs = const []}) =>
      Dive(id: id, number: 1, start: Timestamp.fromDateTime(DateTime.utc(2026, 9, 1, 10)), cylinders: cylinders, logs: logs);

  test('deleteCylinder without replacement leaves dives with the cylinder unset', () async {
    final cyl = await store.cylinders.update(Cylinder(volumeL: 12, workingPressureBar: 232, description: 'D12'));
    await store.dives.insertAll([
      diveWithCylinders('dive-1', [DiveCylinder(cylinderId: cyl.id, oxygen: 0.21, helium: 0.0, beginPressure: 200, endPressure: 100)]),
    ]);

    await store.deleteCylinder(cyl.id);

    expect(await store.cylinders.getAll(), isEmpty);

    final dive = (await store.diveById('dive-1'))!;
    expect(dive.cylinders, hasLength(1));
    // The cylinder reference is gone, but gas mix and pressures are kept.
    expect(dive.cylinders.first.cylinderId, isEmpty);
    expect(dive.cylinders.first.hasCylinder(), isFalse);
    expect(dive.cylinders.first.oxygen, 0.21);
    expect(dive.cylinders.first.beginPressure, 200);
    expect(dive.cylinders.first.endPressure, 100);
  });

  test('deleteCylinder with replacement remaps dives to the replacement', () async {
    final d24 = await store.cylinders.update(Cylinder(volumeL: 24, workingPressureBar: 232, description: 'D24'));
    final d12 = await store.cylinders.update(Cylinder(volumeL: 12, workingPressureBar: 232, description: 'D12'));
    await store.dives.insertAll([
      diveWithCylinders('dive-1', [
        DiveCylinder(cylinderId: d24.id, oxygen: 0.21, beginPressure: 200, endPressure: 100),
        DiveCylinder(cylinderId: d12.id, oxygen: 0.5, beginPressure: 150, endPressure: 50),
      ]),
    ]);

    await store.deleteCylinder(d24.id, replacementID: d12.id);

    final remaining = await store.cylinders.getAll();
    expect(remaining, hasLength(1));
    expect(remaining.first.id, d12.id);

    final dive = (await store.diveById('dive-1'))!;
    expect(dive.cylinders, hasLength(2));
    expect(dive.cylinders.every((c) => c.cylinderId == d12.id), isTrue);
    expect(dive.cylinders.first.cylinder.volumeL, 12);
    // Each row keeps its own gas and pressures.
    expect(dive.cylinders.first.oxygen, 0.21);
    expect(dive.cylinders.last.oxygen, 0.5);
  });

  test('deleteCylinder recomputes used volume from the replacement cylinder', () async {
    final d24 = await store.cylinders.update(Cylinder(volumeL: 24, workingPressureBar: 232, description: 'D24'));
    final d12 = await store.cylinders.update(Cylinder(volumeL: 12, workingPressureBar: 232, description: 'D12'));
    final samples = [
      LogSample(time: 0, depth: 10, pressures: [TankPressure(tankIndex: 0, pressure: 200)]),
      LogSample(time: 600, depth: 10, pressures: [TankPressure(tankIndex: 0, pressure: 100)]),
    ];
    await store.dives.insertAll([
      diveWithCylinders(
        'dive-1',
        [DiveCylinder(cylinderId: d24.id, oxygen: 0.21)],
        logs: [Log(dateTime: Timestamp.fromDateTime(DateTime.utc(2026, 9, 1, 10)), samples: samples)],
      ),
    ]);

    // Against the original 24L cylinder, 100 bar used is 2400 liters.
    expect((await store.diveById('dive-1'))!.cylinders.first.usedVolume, 2400);

    await store.deleteCylinder(d24.id, replacementID: d12.id);

    // Against the 12L replacement, the same 100 bar is only 1200 liters.
    expect((await store.diveById('dive-1'))!.cylinders.first.usedVolume, 1200);
  });

  test('deleteCylinder only touches dives that use the cylinder', () async {
    final c1 = await store.cylinders.update(Cylinder(volumeL: 12, workingPressureBar: 232, description: 'D12'));
    final c2 = await store.cylinders.update(Cylinder(volumeL: 15, workingPressureBar: 232, description: 'D15'));
    await store.dives.insertAll([
      diveWithCylinders('dive-1', [DiveCylinder(cylinderId: c1.id, oxygen: 0.21)]),
      diveWithCylinders('dive-2', [DiveCylinder(cylinderId: c2.id, oxygen: 0.21)]),
      diveWithCylinders('dive-3', [DiveCylinder(cylinderId: '', oxygen: 0.21)]),
    ]);

    await store.deleteCylinder(c1.id);

    final untouched1 = (await store.diveById('dive-2'))!;
    expect(untouched1.cylinders.first.cylinderId, c2.id);
    final untouched2 = (await store.diveById('dive-3'))!;
    expect(untouched2.cylinders.first.cylinderId, isEmpty);

    // The other cylinder is still there.
    expect((await store.cylinders.getAll()).map((c) => c.id), [c2.id]);
  });
}
