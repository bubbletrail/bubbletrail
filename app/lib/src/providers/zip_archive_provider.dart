import 'dart:io';

import 'package:btstore/btstore.dart';
import 'package:flutter_archive/flutter_archive.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

final _log = Logger('zip_archive_provider.dart');

class ZipExportProvider extends ArchiveExportProvider {
  final File zipFile;

  ZipExportProvider({required this.zipFile});

  @override
  Future<void> writeObjects(Stream<ArchiveObject> objects) async {
    final tempRoot = await getTemporaryDirectory();
    final tempDir = await Directory('${tempRoot.path}/export_${DateTime.now().millisecondsSinceEpoch}').create();
    _log.fine('created temp dir: ${tempDir.path}');

    await for (final object in objects) {
      final file = File('${tempDir.path}/${object.key}');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(object.data);
    }

    _log.info('creating zip at ${zipFile.path}');
    await ZipFile.createFromDirectory(sourceDir: tempDir, zipFile: zipFile, recurseSubDirs: true, includeBaseDirectory: false);
    _log.fine('cleaning up temp dir');
    await tempDir.delete(recursive: true);
  }
}

class ZipImportProvider extends ArchiveImportProvider {
  final File zipFile;
  late final Directory _tempDir;

  ZipImportProvider({required this.zipFile});

  Future<void> init() async {
    final tempRoot = await getTemporaryDirectory();
    _tempDir = await Directory('${tempRoot.path}/import_${DateTime.now().millisecondsSinceEpoch}').create();
    _log.fine('created temp dir: ${_tempDir.path}');

    _log.info('extracting zip from ${zipFile.path}');
    await ZipFile.extractToDirectory(zipFile: zipFile, destinationDir: _tempDir);
    _log.fine('extraction complete');
  }

  @override
  Stream<ArchiveObject> readObjects() async* {
    await for (final match in Glob('${_tempDir.path}/**/*.binpb').list()) {
      if (match is! File) continue;
      final file = match as File;
      final key = file.path.substring(_tempDir.path.length + 1);
      final data = await file.readAsBytes();
      yield ArchiveObject(key, data);
    }
    _log.fine('cleaning up temp dir');
    await _tempDir.delete(recursive: true);
  }
}
