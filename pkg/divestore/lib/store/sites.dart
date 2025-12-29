import 'dart:async';
import 'dart:io';

import 'package:divestore/store/fileio.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

final _log = Logger('store/sites');

class Sites {
  final String path;
  final bool readonly;
  Map<String, Site> _sites = {};
  Set<String> _tags = {};
  Timer? _saveTimer;

  Sites(this.path, {this.readonly = false});

  Set<String> get tags => _tags;

  Future<String> insert(Site site) async {
    if (readonly) throw Exception('readonly');
    if (!site.hasId()) {
      site.id = Uuid().v4().toString();
    }
    site.updatedAt = Timestamp.fromDateTime(DateTime.now());
    if (!site.hasCreatedAt()) {
      site.createdAt = site.updatedAt;
    }
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    _scheduleSave();
    return site.id;
  }

  Future<void> insertAll(Iterable<Site> sites) async {
    if (readonly) throw Exception('readonly');
    for (final site in sites) {
      if (!site.hasId()) {
        site.id = Uuid().v4().toString();
      }
      if (!_sites.containsKey(site.id)) {
        site.updatedAt = Timestamp.fromDateTime(DateTime.now());
        if (!site.hasCreatedAt()) {
          site.createdAt = site.updatedAt;
        }
        _sites[site.id] = site;
      }
      _tags.addAll(site.tags);
    }
    _scheduleSave();
  }

  Future<void> update(Site site) async {
    if (readonly) throw Exception('readonly');
    site.updatedAt = Timestamp.fromDateTime(DateTime.now());
    if (!site.hasCreatedAt()) {
      site.createdAt = site.updatedAt;
    }
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    _scheduleSave();
  }

  Future<void> _import(Site site) async {
    if (readonly) throw Exception('readonly');
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (readonly) throw Exception('readonly');
    _sites[id]?.deletedAt = Timestamp.fromDateTime(DateTime.now());
    _scheduleSave();
  }

  Future<Site?> getById(String id) async {
    return _sites[id];
  }

  Future<List<Site>> getAll() async {
    final sites = _sites.values.where((s) => !s.hasDeletedAt()).toList();
    sites.sort((a, b) => a.name.compareTo(b.name));
    return sites;
  }

  Future<void> init() async {
    try {
      final bs = await File(path).readAsBytes();
      final dss = InternalSiteList.fromBuffer(bs);
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
      atomicWriteProto(path, cl);
      _log.info('saved ${_sites.length} sites');
    } catch (e) {
      _log.warning("failed to save sites: $e");
    }
  }

  Future<void> importFrom(Sites other) async {
    for (final site in await other.getAll()) {
      final cur = _sites[site.id];
      if (site.hasDeletedAt()) {
        if (cur != null) {
          print('delete site ${site.id}');
          await delete(site.id);
        }
      } else if (cur == null || site.updatedAt.toDateTime().isAfter(cur.updatedAt.toDateTime())) {
        print('import site ${site.id}');
        await _import(site);
      }
    }
  }
}
