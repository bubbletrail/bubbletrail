import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:divestore/store/fileio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../gen/internal.pb.dart';

class Sites {
  static Sites _instance = Sites._();

  factory Sites() {
    return _instance;
  }

  Sites._() {}

  late final String path;
  Map<String, Site> _sites = {};
  Set<String> _tags = {};
  bool _loaded = false;
  Timer? _saveTimer;

  Set<String> get tags => _tags;

  Future<String> insert(Site site) async {
    if (!_loaded) await _load();
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
    if (!_loaded) await _load();
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
    if (!_loaded) await _load();
    site.updatedAt = Timestamp.fromDateTime(DateTime.now());
    if (!site.hasCreatedAt()) {
      site.createdAt = site.updatedAt;
    }
    _sites[site.id] = site;
    _tags.addAll(site.tags);
    _scheduleSave();
  }

  Future<void> delete(String id) async {
    if (!_loaded) await _load();
    _sites[id]?.deletedAt = Timestamp.fromDateTime(DateTime.now());
    _scheduleSave();
  }

  Future<Site?> getById(String id) async {
    if (!_loaded) await _load();
    return _sites[id];
  }

  Future<List<Site>> getAll() async {
    if (!_loaded) await _load();
    final sites = _sites.values.where((s) => !s.hasDeletedAt()).toList();
    sites.sort((a, b) => a.name.compareTo(b.name));
    return sites;
  }

  Future<void> _load() async {
    final dir = await getApplicationDocumentsDirectory();
    path = "${dir.path}/sites.json";
    try {
      final bs = await File(path).readAsString();
      final dss = InternalSiteList.create()..mergeFromProto3Json(jsonDecode(bs));
      for (final site in dss.sites) {
        _sites[site.id] = site;
        _tags.addAll(site.tags);
      }
    } catch (_) {
    } finally {
      _loaded = true;
    }
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final cl = InternalSiteList(sites: _sites.values);
      atomicWriteJSON(path, cl.toProto3Json());
    } catch (e) {
      print("failed to save sites: $e");
    }
  }
}
