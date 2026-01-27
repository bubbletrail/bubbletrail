import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';

import '../gen/gen.dart';

final _log = Logger('preferences_store.dart');

class PreferencesStore {
  final String path;
  Preferences _preferences = Preferences();
  final _changes = StreamController<Preferences>.broadcast();

  PreferencesStore(this.path);

  Stream<Preferences> get changes => _changes.stream;
  Preferences get current => _preferences;

  Future<void> init() async {
    await _load();
  }

  Future<void> _load() async {
    final file = File(path);
    if (await file.exists()) {
      try {
        final bytes = await file.readAsBytes();
        _preferences = Preferences.fromBuffer(bytes);
        _log.fine('loaded preferences from $path');
      } catch (e) {
        _log.warning('failed to load preferences, using defaults', e);
        _preferences = Preferences();
      }
    } else {
      _log.fine('no preferences file found, using defaults');
      _preferences = Preferences();
    }
  }

  Future<Preferences> load() async {
    await _load();
    return _preferences;
  }

  Future<void> save(Preferences prefs) async {
    _preferences = prefs;
    final file = File(path);
    await file.parent.create(recursive: true);
    await file.writeAsBytes(prefs.writeToBuffer());
    _changes.add(prefs);
    _log.fine('saved preferences to $path');
  }

  Future<void> update(Preferences Function(Preferences) updater) async {
    final updated = updater(_preferences);
    await save(updated);
  }
}
