import 'package:bubbletrail/src/common/timezone.dart';
import 'package:btproto/btproto.dart';
import 'package:test/test.dart';

void main() {
  setUpAll(initialiseTimeZones);

  test('derives IANA zone from position', () {
    final pos = Position(latitude: 59.33, longitude: 18.06); // Stockholm
    expect(timeZoneForPosition(pos), 'Europe/Stockholm');
    expect(timeZoneForPosition(null), '');
  });

  test('UTC instant shows as site-local wall clock with DST', () {
    // 10:00 UTC on 1 July is 12:00 CEST (summer, +2) in Stockholm.
    final utc = DateTime.utc(2024, 7, 1, 10, 0);
    final zoned = inZone(utc, 'Europe/Stockholm')!;
    expect(zoned.hour, 12);
    expect(zoned.timeZoneName, 'CEST');

    // 10:00 UTC on 1 January is 11:00 CET (winter, +1).
    final winter = inZone(DateTime.utc(2024, 1, 1, 10, 0), 'Europe/Stockholm')!;
    expect(winter.hour, 11);
    expect(winter.timeZoneName, 'CET');
  });

  test('wall clock round-trips back to the original UTC instant', () {
    final utc = DateTime.utc(2024, 7, 1, 10, 0);
    final zoned = inZone(utc, 'Europe/Stockholm')!;
    final wall = DateTime(zoned.year, zoned.month, zoned.day, zoned.hour, zoned.minute);
    expect(wallClockToUtc(wall, 'Europe/Stockholm'), utc);
  });

  test('no zone falls back to UTC', () {
    final wall = DateTime(2024, 7, 1, 10, 0);
    expect(inZone(DateTime.utc(2024, 7, 1, 10, 0), ''), isNull);
    expect(wallClockToUtc(wall, ''), DateTime.utc(2024, 7, 1, 10, 0));
  });
}
