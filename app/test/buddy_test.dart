import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/store.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:test/test.dart';

final _now = DateTime.utc(2026, 9, 1, 12);

Dive _dive(DateTime start, List<String> buddies, {bool deleted = false}) {
  final dive = Dive(start: Timestamp.fromDateTime(start), buddies: buddies);
  if (deleted) dive.meta = dive.meta.rebuildDeleted();
  return dive;
}

void main() {
  test('no dives means no active buddies', () {
    expect(<Dive>[].activeBuddies(now: _now), isEmpty);
  });

  test('any buddy dived with during the last month', () {
    final dives = [
      _dive(_now.subtract(const Duration(days: 1)), ['Alice', 'Bob']),
      _dive(_now.subtract(const Duration(days: 29)), ['Carol']),
      _dive(_now.subtract(const Duration(days: 31)), ['Dave']),
      _dive(_now.subtract(const Duration(days: 400)), ['Eve']),
    ];
    expect(dives.activeBuddies(now: _now), {'Alice', 'Bob', 'Carol'});
  });

  test('any buddy dived with at least ten times during the last six months', () {
    List<Dive> withBuddy(String buddy, int count, int firstDayAgo) => [
      for (var i = 0; i < count; i++) _dive(_now.subtract(Duration(days: firstDayAgo + i)), [buddy]),
    ];

    final dives = [
      ...withBuddy('Frank', 10, 100), // Ten within the window, but not this month.
      ...withBuddy('Grace', 9, 100), // One short of the threshold.
      ...withBuddy('Heidi', 10, 200), // Plenty of dives, but all too old.
    ];
    expect(dives.activeBuddies(now: _now), {'Frank'});
  });

  test('only dives within the six month window count towards the threshold', () {
    final dives = [
      for (var i = 0; i < 5; i++) _dive(_now.subtract(Duration(days: 100 + i)), ['Ivan']),
      for (var i = 0; i < 5; i++) _dive(_now.subtract(Duration(days: 300 + i)), ['Ivan']),
    ];
    expect(dives.activeBuddies(now: _now), isEmpty);
  });

  test('deleted dives do not count', () {
    final dives = [
      _dive(_now.subtract(const Duration(days: 1)), ['Judy'], deleted: true),
      for (var i = 0; i < 10; i++) _dive(_now.subtract(Duration(days: 100 + i)), ['Karl'], deleted: true),
    ];
    expect(dives.activeBuddies(now: _now), isEmpty);
  });
}
