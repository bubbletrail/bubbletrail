import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/src/import/import.dart';
import 'package:bubbletrail/src/services/store/src/store/site_store.dart';
import 'package:test/test.dart';

// Regression test for issue #99: importing a Subsurface file where a dive
// site has GPS coordinates crashed with "Rebuilding only works on frozen
// messages". SiteStore.update derives a timezone from the position and used
// rebuild() on the freshly imported (not yet frozen) site proto.
void main() {
  late Directory tmp;
  late SiteStore sites;

  setUp(() async {
    tmp = Directory.systemTemp.createTempSync('site_store_test');
    sites = SiteStore('${tmp.path}/sites.binpb');
    await sites.init();
  });

  tearDown(() {
    tmp.deleteSync(recursive: true);
  });

  Future<Site> importSingleSite(String gps) async {
    final xml =
        """
<?xml version='1.0' encoding='utf-8'?>
<divelog program='subsurface' version='3'>
 <divesites>
  <site uuid='20073927' name='Oddesund - Grisetå' gps='$gps'/>
 </divesites>
 <dives>
  <dive number='1' date='2025-07-01' time='10:00:00' duration='40 min' divesiteid='20073927'/>
 </dives>
</divelog>
""";
    final container = importXmlString(xml);
    await sites.updateAll(container.sites);
    return (await sites.getById(container.sites.single.id))!;
  }

  test('stores imported site with space separated GPS and derives timezone', () async {
    final site = await importSingleSite('56.579366 8.564110');
    expect(site.hasPosition(), isTrue);
    expect(site.position.latitude, closeTo(56.579366, 1e-9));
    expect(site.position.longitude, closeTo(8.564110, 1e-9));
    expect(site.timezone, 'Europe/Copenhagen');
  });

  test('stores imported site with comma separated GPS', () async {
    final site = await importSingleSite('56.579366, 8.564110');
    expect(site.hasPosition(), isTrue);
    expect(site.position.latitude, closeTo(56.579366, 1e-9));
    expect(site.position.longitude, closeTo(8.564110, 1e-9));
  });

  test('site without parseable GPS imports without position', () async {
    final site = await importSingleSite('nonsense');
    expect(site.hasPosition(), isFalse);
    expect(site.timezone, isEmpty);
  });

  test('update keeps an explicitly set timezone', () async {
    final site = Site(id: 'test-id', name: 'Test', timezone: 'Europe/Stockholm', position: Position(latitude: 56.579366, longitude: 8.564110));
    await sites.update(site);
    final stored = (await sites.getById('test-id'))!;
    expect(stored.timezone, 'Europe/Stockholm');
  });
}
