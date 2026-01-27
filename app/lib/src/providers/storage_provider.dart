import 'dart:async';

import 'package:btstore/btstore.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

final _log = Logger('storage_provider.dart');

class StorageProvider {
  static final instance = StorageProvider._();
  StorageProvider._();

  late final Store store;

  Future<void> init() async {
    _log.fine('init storage');
    final dir = '${(await getApplicationDocumentsDirectory()).path}/db';
    store = Store(dir);
    await store.init();
  }
}
