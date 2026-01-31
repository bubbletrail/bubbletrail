import 'dart:async';

import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../services/store/store.dart';

final _log = Logger('storage_provider.dart');

class StorageProvider {
  static final instance = StorageProvider._();
  StorageProvider._();

  late final Store store;

  Future<void> init() async {
    // Use forward slashes for cross-platform compatibility (glob package uses them)
    final dir = '${(await getApplicationDocumentsDirectory()).path}/db'.replaceAll('\\', '/');
    _log.fine('init storage at $dir');
    store = Store(dir);
    await store.init();
  }
}
