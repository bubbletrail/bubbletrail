import 'dart:io';
import 'dart:typed_data';

import 'package:btproto/btproto.dart';
import 'package:bubbletrail/src/services/store/src/store/dive_store.dart';
import 'package:bubbletrail/src/services/store/store.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:test/test.dart';

// An in-memory stand-in for the S3 provider. Uploads are encrypted with a fresh
// nonce every time, so the eTag of an object changes on every put even when the
// bytes going in are identical -- that's modelled here by handing out a new
// eTag per put, and it's the property the sync logic has to cope with.
class _FakeProvider extends SyncProvider {
  final _objects = <String, Uint8List>{};
  final _etags = <String, String>{};
  var _nextEtag = 0;
  var puts = 0;
  var gets = 0;

  @override
  Stream<SyncObject> listObjects() async* {
    for (final key in _objects.keys.toList()) {
      yield SyncObject(key, DateTime.utc(2026, 8, 27), _etags[key]!);
    }
  }

  @override
  Future<Uint8List> getObject(String key) async {
    gets++;
    return _objects[key]!;
  }

  @override
  Future<String> putObject(String key, Uint8List data) async {
    puts++;
    _objects[key] = data;
    return _etags[key] = 'etag-${_nextEtag++}';
  }

  @override
  Future<void> deleteObject(String key) async {
    _objects.remove(key);
    _etags.remove(key);
  }

  // A peer uploading the identical dive again: same bytes, new eTag.
  void reUpload(String key) => _etags[key] = 'etag-${_nextEtag++}';

  // A provider that reports no eTag at all for an object.
  void blankEtag(String key) => _etags[key] = '';
}

Future<DiveStore> _store(Directory root, String name) async {
  final dir = Directory('${root.path}/$name')..createSync(recursive: true);
  final store = DiveStore(dir.path);
  await store.init();
  return store;
}

Dive _dive(String id) => Dive(
  id: id,
  number: 1,
  start: Timestamp.fromDateTime(DateTime.utc(2026, 8, 27, 10)),
  logs: [
    Log(
      dateTime: Timestamp.fromDateTime(DateTime.utc(2026, 8, 27, 10)),
      samples: [LogSample(time: 0, depth: 0), LogSample(time: 60, depth: 20), LogSample(time: 600, depth: 0)],
    ),
  ],
);

void main() {
  late Directory root;
  late _FakeProvider provider;

  setUp(() {
    root = Directory.systemTemp.createTempSync('bubbletrail-sync');
    provider = _FakeProvider();
  });

  tearDown(() => root.deleteSync(recursive: true));

  test('an unchanged dive is uploaded once', () async {
    final store = await _store(root, 'desktop');
    await store.insertAll([_dive('dive-one')]);

    await store.syncWith(provider);
    expect(provider.puts, 1);

    await store.syncWith(provider);
    expect(provider.puts, 1, reason: 'nothing changed, so nothing to upload');
  });

  test('a re-uploaded but unchanged dive is not written back', () async {
    final store = await _store(root, 'desktop');
    await store.insertAll([_dive('dive-one')]);
    await store.syncWith(provider);

    // The other device pushed the same dive again, so the eTag we recorded is
    // stale even though the dive itself is untouched.
    provider.reUpload('dive-dive-one');
    await store.syncWith(provider);

    expect(provider.puts, 1, reason: 'a fresh eTag on identical content is not a change');
  });

  test('two devices stop talking about a dive neither has changed', () async {
    final desktop = await _store(root, 'desktop');
    final mobile = await _store(root, 'mobile');
    await desktop.insertAll([_dive('dive-one')]);

    await desktop.syncWith(provider);
    await mobile.syncWith(provider);
    expect(provider.puts, 1, reason: 'the mobile just received the dive');

    // Whatever eTag either side happens to hold, an unchanged dive must not
    // bounce between them. Losing the recorded eTag (an app killed before the
    // save, a crossing upload) is what used to start that.
    provider.reUpload('dive-dive-one');

    final putsBefore = provider.puts;
    for (var round = 0; round < 3; round++) {
      await desktop.syncWith(provider);
      await mobile.syncWith(provider);
    }
    expect(provider.puts, putsBefore, reason: 'unchanged dive bounced between the two devices');
  });

  test('a local edit is uploaded even when the remote eTag is blank', () async {
    final store = await _store(root, 'desktop');
    await store.insertAll([_dive('dive-one')]);
    await store.syncWith(provider);

    // A blank eTag must not collide with the blank one a locally edited dive
    // carries, which would leave the edit sitting here unsynced.
    provider.blankEtag('dive-dive-one');
    await store.update((await store.getById('dive-one'))!.rebuild((d) => d.notes = 'much bubbles'));

    await store.syncWith(provider);
    expect(provider.puts, 2);
  });

  test('a genuinely edited dive still propagates', () async {
    final desktop = await _store(root, 'desktop');
    final mobile = await _store(root, 'mobile');
    await desktop.insertAll([_dive('dive-one')]);
    await desktop.syncWith(provider);
    await mobile.syncWith(provider);

    final edited = (await mobile.getById('dive-one'))!.rebuild((d) => d.notes = 'much bubbles');
    await mobile.update(edited);
    await mobile.syncWith(provider);
    await desktop.syncWith(provider);

    expect((await desktop.getById('dive-one'))!.notes, 'much bubbles');

    // ...and having taken the edit, the desktop has nothing to say about it.
    final putsBefore = provider.puts;
    await desktop.syncWith(provider);
    await mobile.syncWith(provider);
    expect(provider.puts, putsBefore);
  });
}
