import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../../../../common/timezone.dart';
import '../sync/syncprovider.dart';
import 'entity_store.dart';

final _log = Logger('site_store.dart');

class SiteStore extends EntityStore<Site, InternalSiteList> {
  final _tags = <String>{};

  SiteStore(super.path) : super(syncKey: 'sites', entityName: 'sites', log: _log);

  Set<String> get tags => _tags;

  @override
  String getId(Site entity) => entity.id;

  @override
  bool hasId(Site entity) => entity.id.isNotEmpty;

  @override
  Metadata getMeta(Site entity) => entity.meta;

  @override
  Site rebuildEntity(Site entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.id = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  InternalSiteList createList(Iterable<Site> entities) => InternalSiteList(sites: entities.toList());

  @override
  Iterable<Site> entitiesFromList(InternalSiteList list) => list.sites;

  @override
  InternalSiteList listFromBuffer(List<int> bytes) => InternalSiteList.fromBuffer(bytes);

  @override
  int compare(Site a, Site b) => a.name.compareTo(b.name);

  @override
  @internal
  Future<void> delete(String id) => super.delete(id);

  // Site-specific methods with tag tracking

  Future<void> updateAll(Iterable<Site> sites) async {
    for (final site in sites) {
      await update(site);
    }
  }

  @override
  Future<Site> update(Site entity) async {
    // Derive the timezone from the position when the site doesn't already have
    // one. Doing it here means every path that saves a site (inline editor,
    // import, set-from-dives) gets a zone without having to remember to derive
    // it. Once a zone name is set it's authoritative and never recalculated, so
    // an explicit or manually-corrected zone survives later position edits.
    if (entity.timezone.isEmpty) {
      final zone = timeZoneForPosition(entity.hasPosition() ? entity.position : null);
      if (zone.isNotEmpty) {
        entity = entity.deepCopy()..timezone = zone;
      }
    }
    final ret = await super.update(entity);
    _tags.addAll(entity.tags);
    return ret;
  }

  @override
  Future<Site?> getById(String id) async {
    final site = await super.getById(id);
    if (site == null) return null;
    return site.rebuild((site) {
      site.tags.sort((a, b) => a.compareTo(b));
    });
  }

  @override
  Future<void> init() async {
    _tags.clear();
    await super.init();
    for (final site in await getAll()) {
      // normalize country name to country code, if possible
      final nc = matchCountryCode(site.country) ?? site.country;
      if (nc != site.country) {
        final rs = site.rebuild((site) {
          site.country = nc;
        });
        await update(rs);
      }

      // remember the tags
      _tags.addAll(site.tags);
    }
  }

  Future<void> _rebuildTags() async {
    _tags.clear();
    for (final site in await getAll()) {
      _tags.addAll(site.tags);
    }
  }

  @override
  Future<void> syncWith(SyncProvider provider) async {
    await super.syncWith(provider);
    await _rebuildTags();
  }
}
