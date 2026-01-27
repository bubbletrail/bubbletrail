import 'dart:async';

import 'package:btstore/btstore.dart';

import '../providers/storage_provider.dart';

class PreferencesStorage {
  static final _changes = StreamController<Preferences>.broadcast();
  static var _current = Preferences();
  static Stream<Preferences> get changes => _changes.stream;

  static Future<Preferences> load() async {
    final store = await StorageProvider.store;
    final prefs = await store.preferences.load();
    if (prefs != _current) {
      _changes.add(prefs);
      _current = prefs;
    }
    return prefs;
  }

  static Future<void> save(Preferences prefs) async {
    final store = await StorageProvider.store;
    await store.preferences.save(prefs);
    if (prefs != _current) {
      _changes.add(prefs);
      _current = prefs;
    }
  }
}
