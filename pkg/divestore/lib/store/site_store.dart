import 'package:logging/logging.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';
import '../sync/syncprovider.dart';
import 'entity_store.dart';

final _log = Logger('site_store.dart');

class SiteStore extends EntityStore<Site, InternalSiteList> {
  Set<String> _tags = {};

  SiteStore(String path) : super(path, syncKey: 'sites', entityName: 'sites', log: _log);

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

  // Site-specific methods with tag tracking

  Future<void> updateAll(Iterable<Site> sites) async {
    for (final site in sites) {
      await update(site);
    }
  }

  @override
  Future<Site> update(Site site) async {
    await super.update(site);
    _tags.addAll(site.tags);
    return site;
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
