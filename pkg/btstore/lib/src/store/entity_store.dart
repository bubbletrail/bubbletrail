import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';
import 'package:uuid/uuid.dart';

import '../gen/gen.dart';
import '../sync/syncprovider.dart';
import 'fileio.dart';

// Base class for stores that manage proto entities with ID and Metadata fields.
//
// Subclasses must implement the abstract methods to provide entity-specific
// access to ID and metadata fields, as well as list wrapper creation.
abstract class EntityStore<T extends GeneratedMessage, TList extends GeneratedMessage> {
  final String path;
  final String syncKey;
  final String entityName;
  final Logger log;

  Map<String, T> _entities = {};
  Timer? _saveTimer;
  bool _notify = false;
  final _changes = StreamController<void>.broadcast();

  Stream<void> get changes => _changes.stream;

  EntityStore(this.path, {required this.syncKey, required this.entityName, required this.log});

  // Abstract methods for entity field access

  @internal
  String getId(T entity);

  @internal
  bool hasId(T entity);

  @internal
  Metadata getMeta(T entity);

  @internal
  T rebuildEntity(T entity, {String? id, Metadata? meta});

  /// Rebuild an entity as deleted. Override to clear entity-specific fields.
  @internal
  T rebuildDeleted(T entity) {
    final meta = getMeta(entity).rebuildDeleted();
    return rebuildEntity(entity, meta: meta);
  }

  // Abstract methods for list wrapper

  @internal
  TList createList(Iterable<T> entities);

  @internal
  Iterable<T> entitiesFromList(TList list);

  @internal
  TList listFromBuffer(List<int> bytes);

  @internal
  int compare(T a, T b);

  Future<T> update(T entity) async {
    entity = _prepareInsert(entity);
    _entities[getId(entity)] = entity;
    _scheduleSave(notify: true);
    return entity;
  }

  Future<void> delete(String id) async {
    if (_entities.containsKey(id)) {
      _entities[id] = rebuildDeleted(_entities[id]!);
    }
    _scheduleSave(notify: true);
  }

  Future<T?> getById(String id) async {
    return _entities[id];
  }

  Future<List<T>> getAll({bool withDeleted = false}) async {
    final vals = _entities.values.where((e) => withDeleted || !getMeta(e).isDeleted).toList();
    vals.sort(compare);
    return vals;
  }

  @internal
  Future<void> init() async {
    _entities.clear();
    _saveTimer?.cancel();
    try {
      final bs = await File(path).readAsBytes();
      final list = listFromBuffer(bs);
      list.freeze();
      for (var entity in entitiesFromList(list)) {
        if (!hasId(entity)) {
          entity = rebuildEntity(entity, id: Uuid().v4().toString());
          log.warning('setting ID on $entityName that didn\'t have one');
        }
        _entities[getId(entity)] = entity;
      }
    } on PathNotFoundException {
      log.info('no $entityName on disk, nothing loaded');
    } catch (e) {
      log.warning('failed to load $entityName', e);
    }
    _changes.add(null);
  }

  T _prepareInsert(T entity) {
    if (!entity.isFrozen) entity.freeze();
    final id = hasId(entity) ? null : Uuid().v4().toString();
    final meta = getMeta(entity).rebuildUpdated();
    return rebuildEntity(entity, id: id, meta: meta);
  }

  void _scheduleSave({required bool notify}) {
    if (notify) _notify = true;
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), _save);
  }

  Future<void> _save() async {
    try {
      final vals = _entities.values.toList();
      vals.sort(compare);
      final list = createList(vals);
      await atomicWriteProto(path, list);
      if (_notify) {
        _notify = false;
        _changes.add(null);
      }
      log.info('saved ${_entities.length} $entityName');
    } catch (e) {
      log.warning('failed to save $entityName', e);
    }
  }

  @internal
  Future<void> syncWith(SyncProvider provider) async {
    log.fine('syncing $entityName');
    var changed = false;
    try {
      final obj = await provider.getObject(syncKey);
      final list = listFromBuffer(obj);
      list.freeze();
      log.fine('got ${entitiesFromList(list).length} $entityName from provider');
      for (final entity in entitiesFromList(list)) {
        if (!hasId(entity)) {
          log.warning('rejecting $entityName without ID in sync');
          continue;
        }
        final cur = _entities[getId(entity)];
        if (getMeta(entity).isDeleted) {
          if (cur != null && !getMeta(cur).isDeleted) {
            log.fine('deleting $entityName ${getId(entity)}');
            _entities[getId(entity)] = rebuildDeleted(cur);
            changed = true;
          }
        } else if (cur == null || getMeta(entity).isAfter(getMeta(cur))) {
          log.fine('importing $entityName ${getId(entity)}');
          _entities[getId(entity)] = entity;
          changed = true;
        }
      }
    } catch (e) {
      log.warning('failed to load $entityName', e);
    }

    final vals = _entities.values.toList();
    log.fine('updating ${vals.length} $entityName in sync provider');
    final list = createList(vals);
    final bs = list.writeToBuffer();
    await provider.putObject(syncKey, bs);

    if (changed) _scheduleSave(notify: true);
  }
}
