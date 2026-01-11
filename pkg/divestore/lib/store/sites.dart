import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';
import '../sync/syncprovider.dart';
import 'fileio.dart';

final _log = Logger('store/sites.dart');

class Sites {
  final String path;
  final bool readonly;
  Map<String, Site> _sites = {};
  Set<String> _tags = {};
  Timer? _saveTimer;

  Sites(this.path, {this.readonly = false});

  Set<String> get tags => _tags;

  Future<Site> insert(Site site) async {
    if (readonly) throw Exception('readonly');
    site = _insert(site);
    _scheduleSave();
    return site;
  }

  Future<void> insertAll(Iterable<Site> sites) async {
    if (readonly) throw Exception('readonly');
    for (final site in sites) {
      _insert(site);
    }
    _scheduleSave();
  }

  Site _insert(Site site) {
    if (!site.isFrozen) site.freeze();
    site = site.rebuild((site) {
      if (!site.hasId()) {
        site.id = Uuid().v4().toString();
      }
      site.meta = site.meta.rebuildUpdated();
    });
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    return site;
  }

  Future<void> update(Site site) async {
    if (readonly) throw Exception('readonly');
    if (!site.isFrozen) site.freeze();
    site = site.rebuild((site) {
      site.meta = site.meta.rebuildUpdated();
    });
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    if (_sites.containsKey(id)) {
      _sites[id] = _sites[id]!.rebuild((site) {
        site.meta = site.meta.rebuildDeleted();
      });
    }
    _scheduleSave();
  }

  Future<Site?> getById(String id) async {
    final site = _sites[id];
    if (site == null) return null;
    return site.rebuild((site) {
      site.tags.sort((a, b) => a.compareTo(b));
    });
  }

  Future<List<Site>> getAll({bool withDeleted = false}) async {
    final sites = _sites.values.where((s) => withDeleted || !s.meta.isDeleted).toList();
    sites.sort((a, b) => a.name.compareTo(b.name));
    return sites;
  }

  Future<void> init() async {
    try {
      final bs = await File(path).readAsBytes();
      final dss = InternalSiteList.fromBuffer(bs);
      dss.freeze();
      for (final site in dss.sites) {
        _sites[site.id] = site;
        _tags.addAll(site.tags);
      }
    } catch (_) {}
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final cl = InternalSiteList(sites: _sites.values);
      await atomicWriteProto(path, cl);
      _log.info('saved ${_sites.length} sites');
    } catch (e) {
      _log.warning('failed to save sites', e);
    }
  }

  void _rebuildTags() {
    _tags.clear();
    for (final site in _sites.values) {
      if (site.meta.isDeleted) continue;
      _tags.addAll(site.tags);
    }
  }

  Future<void> syncWith(SyncProvider provider) async {
    // Get all sites, merge with the list.
    _log.fine('syncing sites');
    try {
      final obj = await provider.getObject('sites');
      final sl = InternalSiteList.fromBuffer(obj);
      sl.freeze();
      for (final site in sl.sites) {
        final cur = _sites[site.id];
        if (site.meta.isDeleted) {
          if (cur != null) {
            _log.fine('deleting site ${site.id}');
            await delete(site.id);
          }
        } else if (cur == null || site.meta.isAfter(cur.meta)) {
          _log.fine('importing site ${site.id}');
          _sites[site.id] = site;
        }
      }
    } catch (e) {
      _log.warning('failed to load sites', e);
    }

    // Upload the new merged set.
    final vals = _sites.values.toList();
    _log.fine('updating ${vals.length} sites in sync provider');
    final cl = InternalSiteList(sites: vals);
    final bs = cl.writeToBuffer();
    await provider.putObject('sites', bs);

    _rebuildTags();
    _scheduleSave();
  }
}
