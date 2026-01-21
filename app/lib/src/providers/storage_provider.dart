import 'dart:async';

import 'package:divestore/divestore.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

final _log = Logger('storage_provider.dart');

class StorageProvider {
  static Future<String> get storePath async => '${(await getApplicationDocumentsDirectory()).path}/db';

  static Future<Store> store = () async {
    _log.fine('init storage');
    final dir = await storePath;
    final store = Store(dir);
    await store.init();
    return store;
  }();
}
