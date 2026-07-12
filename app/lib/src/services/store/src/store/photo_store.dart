import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:btproto/btproto.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../ext/ext.dart';
import '../sync/syncprovider.dart';
import 'entity_store.dart';
import 'fileio.dart';

final _log = Logger('photo_store.dart');

// Photos are immutable binary blobs identified by UUID. Metadata (Photo proto)
// is stored alongside the blobs in an InternalPhotoList file; blob bytes live
// in sibling files named by the photo ID. The metadata syncs like any other
// entity; blobs only need to be added (when missing locally) or removed (when
// the metadata says deleted), since the bytes themselves never change.
class PhotoStore extends EntityStore<Photo, InternalPhotoList> {
  final String _dir;

  // Bounded in-memory cache of decoded+resized PNG bytes, used by list views
  // so they don't re-read and re-decode the full-resolution blob from disk on
  // every rebuild. Keyed by photo ID; entries are evicted in insertion order
  // (oldest-first) once the limit is hit, and on blob deletion.
  static const _thumbnailMaxEdge = 400;
  static const _thumbnailCacheLimit = 50;
  final _thumbnailCache = <String, Uint8List>{};

  PhotoStore(String dir) : _dir = dir, super('$dir/index.binpb', syncKey: 'photos', entityName: 'photos', log: _log);

  @override
  String getId(Photo entity) => entity.id;

  @override
  bool hasId(Photo entity) => entity.id.isNotEmpty;

  @override
  Metadata getMeta(Photo entity) => entity.meta;

  @override
  Photo rebuildEntity(Photo entity, {String? id, Metadata? meta}) {
    return entity.rebuild((b) {
      if (id != null) b.id = id;
      if (meta != null) b.meta = meta;
    });
  }

  @override
  InternalPhotoList createList(Iterable<Photo> entities) => InternalPhotoList(photos: entities.toList());

  @override
  Iterable<Photo> entitiesFromList(InternalPhotoList list) => list.photos;

  @override
  InternalPhotoList listFromBuffer(List<int> bytes) => InternalPhotoList.fromBuffer(bytes);

  @override
  int compare(Photo a, Photo b) => a.id.compareTo(b.id);

  String _blobPath(String id) => '$_dir/$id';

  String _blobKey(String id) => 'photo-$id';

  // Store a new photo blob and return the created metadata. The blob is
  // written before the metadata is updated so a partial failure leaves an
  // orphan blob (cleaned up on next sync) rather than dangling metadata.
  Future<Photo> create(Uint8List data) async {
    final id = const Uuid().v7();
    await Directory(_dir).create(recursive: true);
    await atomicWrite(_blobPath(id), data);
    return await update(Photo(id: id));
  }

  Future<Uint8List?> readData(String id) async {
    try {
      return await File(_blobPath(id)).readAsBytes();
    } on PathNotFoundException {
      return null;
    } catch (e) {
      _log.warning('failed to read photo blob $id', e);
      return null;
    }
  }

  // Return a small in-memory cached thumbnail for list rendering. Falls back
  // to the full blob bytes if decoding fails, so callers always get something
  // paintable when the blob is readable.
  Future<Uint8List?> readThumbnail(String id) async {
    final cached = _thumbnailCache.remove(id);
    if (cached != null) {
      // Reinsert to mark as most-recently-used.
      _thumbnailCache[id] = cached;
      return cached;
    }
    final bytes = await readData(id);
    if (bytes == null) return null;
    try {
      final thumb = await _generateThumbnail(bytes);
      _thumbnailCache[id] = thumb;
      while (_thumbnailCache.length > _thumbnailCacheLimit) {
        _thumbnailCache.remove(_thumbnailCache.keys.first);
      }
      return thumb;
    } catch (e) {
      _log.warning('failed to generate thumbnail for photo $id', e);
      return bytes;
    }
  }

  Future<Uint8List> _generateThumbnail(Uint8List bytes) async {
    // targetWidth alone preserves aspect ratio; the decoder produces the
    // resized bitmap directly, so the full-resolution image is never held
    // in memory.
    final codec = await ui.instantiateImageCodec(bytes, targetWidth: _thumbnailMaxEdge);
    try {
      final frame = await codec.getNextFrame();
      try {
        final byteData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData == null) throw StateError('toByteData returned null');
        return byteData.buffer.asUint8List();
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  @override
  Future<void> delete(String id) async {
    await super.delete(id);
    await _deleteLocalBlob(id);
  }

  Future<void> _deleteLocalBlob(String id) async {
    _thumbnailCache.remove(id);
    try {
      await File(_blobPath(id)).delete();
    } on PathNotFoundException {
      // already gone
    } catch (e) {
      _log.warning('failed to delete local photo blob $id', e);
    }
  }

  @override
  Future<void> syncWith(SyncProvider provider) async {
    // Sync metadata first so we have the merged set of (id, deleted?) facts
    // before deciding what blobs to fetch, upload, or delete.
    await super.syncWith(provider);

    final providerBlobs = <String>{};
    try {
      await for (final obj in provider.listObjects()) {
        if (!obj.key.startsWith('photo-')) continue;
        providerBlobs.add(obj.key.substring('photo-'.length));
      }
    } catch (e) {
      _log.warning('failed to list provider blobs', e);
      return;
    }

    final knownIds = <String>{};
    for (final photo in await getAll(withDeleted: true)) {
      knownIds.add(photo.id);
      final localFile = File(_blobPath(photo.id));
      final hasLocal = await localFile.exists();
      final hasRemote = providerBlobs.contains(photo.id);

      if (photo.meta.isDeleted) {
        if (hasLocal) await _deleteLocalBlob(photo.id);
        if (hasRemote) {
          try {
            await provider.deleteObject(_blobKey(photo.id));
          } catch (e) {
            _log.warning('failed to delete provider blob ${photo.id}', e);
          }
        }
        continue;
      }

      if (!hasLocal && hasRemote) {
        try {
          final data = await provider.getObject(_blobKey(photo.id));
          await Directory(_dir).create(recursive: true);
          await atomicWrite(_blobPath(photo.id), data);
        } catch (e) {
          _log.warning('failed to download photo blob ${photo.id}', e);
        }
      } else if (hasLocal && !hasRemote) {
        try {
          final data = await localFile.readAsBytes();
          await provider.putObject(_blobKey(photo.id), data);
        } catch (e) {
          _log.warning('failed to upload photo blob ${photo.id}', e);
        }
      } else if (!hasLocal && !hasRemote) {
        _log.warning('photo ${photo.id} referenced in metadata but blob is missing on both sides');
      }
    }

    // Tidy orphan blobs in the provider that no longer have metadata.
    for (final id in providerBlobs) {
      if (knownIds.contains(id)) continue;
      try {
        await provider.deleteObject(_blobKey(id));
      } catch (e) {
        _log.warning('failed to delete orphan provider blob $id', e);
      }
    }
  }
}
