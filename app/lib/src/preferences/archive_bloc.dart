import 'dart:convert';
import 'dart:io';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:cryptography/cryptography.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../app_metadata.dart';
import '../providers/storage_provider.dart';
import '../providers/zip_archive_provider.dart';

final _log = Logger('archive_bloc.dart');

class ArchiveState extends Equatable {
  final bool working;
  final String? error;
  final String? exportReadyPath;
  final String? exportReadyFilename;
  final bool exportComplete;
  final bool importComplete;

  const ArchiveState({
    this.working = false,
    this.error,
    this.exportReadyPath,
    this.exportReadyFilename,
    this.exportComplete = false,
    this.importComplete = false,
  });

  ArchiveState copyWith({bool? working, String? error, String? exportReadyPath, String? exportReadyFilename, bool? exportComplete, bool? importComplete}) {
    return ArchiveState(
      working: working ?? this.working,
      error: error,
      exportReadyPath: exportReadyPath,
      exportReadyFilename: exportReadyFilename,
      exportComplete: exportComplete ?? false,
      importComplete: importComplete ?? false,
    );
  }

  @override
  List<Object?> get props => [working, error, exportReadyPath, exportReadyFilename, exportComplete, importComplete];
}

sealed class ArchiveEvent extends Equatable {
  const ArchiveEvent();

  @override
  List<Object?> get props => [];

  const factory ArchiveEvent.exportArchive() = _ExportArchive;
  const factory ArchiveEvent.exportComplete(String destinationPath) = _ExportComplete;
  const factory ArchiveEvent.exportCancelled() = _ExportCancelled;
  const factory ArchiveEvent.importArchive(String zipPath) = _ImportArchive;
  const factory ArchiveEvent.exportSsrf() = _ExportSsrf;
}

class _ExportArchive extends ArchiveEvent {
  const _ExportArchive();
}

class _ExportComplete extends ArchiveEvent {
  final String destinationPath;

  const _ExportComplete(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class _ExportCancelled extends ArchiveEvent {
  const _ExportCancelled();
}

class _ImportArchive extends ArchiveEvent {
  final String zipPath;

  const _ImportArchive(this.zipPath);

  @override
  List<Object?> get props => [zipPath];
}

class _ExportSsrf extends ArchiveEvent {
  const _ExportSsrf();
}

class ArchiveBloc extends Bloc<ArchiveEvent, ArchiveState> {
  ArchiveBloc() : super(const ArchiveState()) {
    on<ArchiveEvent>((event, emit) async {
      switch (event) {
        case _ExportArchive():
          await _onExport(emit);
        case _ExportComplete():
          await _onExportComplete(event, emit);
        case _ExportCancelled():
          await _onExportCancelled(emit);
        case _ImportArchive():
          await _onImport(event, emit);
        case _ExportSsrf():
          await _onExportSsrf(emit);
      }
    }, transformer: sequential());
  }

  Future<void> _onExport(Emitter<ArchiveState> emit) async {
    emit(state.copyWith(working: true, error: null));
    try {
      final store = await StorageProvider.store;
      final tempDir = await getTemporaryDirectory();
      final filename = 'bubbletrail_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.$backupFileExtension';
      final zipFile = File('${tempDir.path}/$filename');

      final provider = ZipExportProvider(zipFile: zipFile);
      await store.exportTo(provider);

      _log.info('export ready at ${zipFile.path}');
      emit(state.copyWith(working: false, exportReadyPath: zipFile.path, exportReadyFilename: filename));
    } catch (e) {
      _log.severe('export failed', e);
      emit(state.copyWith(working: false, error: e.toString()));
    }
  }

  Future<void> _onExportComplete(_ExportComplete event, Emitter<ArchiveState> emit) async {
    final exportPath = state.exportReadyPath;
    if (exportPath == null) return;

    try {
      await File(exportPath).copy(event.destinationPath);
      await File(exportPath).delete();
      _log.info('exported to ${event.destinationPath}');
      emit(state.copyWith(exportComplete: true));
    } catch (e) {
      _log.severe('failed to save export', e);
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onExportCancelled(Emitter<ArchiveState> emit) async {
    final exportPath = state.exportReadyPath;
    if (exportPath != null) {
      try {
        await File(exportPath).delete();
      } catch (_) {}
    }
    emit(const ArchiveState());
  }

  Future<void> _onImport(_ImportArchive event, Emitter<ArchiveState> emit) async {
    emit(state.copyWith(working: true, error: null));
    try {
      final store = await StorageProvider.store;
      final zipFile = File(event.zipPath);

      final provider = ZipImportProvider(zipFile: zipFile);
      await provider.init();
      await store.importFrom(provider);

      _log.info('import complete');
      emit(state.copyWith(working: false, importComplete: true));
    } catch (e) {
      _log.severe('import failed', e);
      emit(state.copyWith(working: false, error: e.toString()));
    }
  }

  Future<void> _onExportSsrf(Emitter<ArchiveState> emit) async {
    emit(state.copyWith(working: true, error: null));
    try {
      final store = await StorageProvider.store;
      final tempDir = await getTemporaryDirectory();
      final filename = 'bubbletrail_${DateFormat('yyyy-MM-dd_HHmmss').format(DateTime.now())}.ssrf';
      final ssrfFile = File('${tempDir.path}/$filename');

      // Get all sites
      final sites = await store.sites.getAll();

      // Get all dives with full data (including logs/samples)
      final overviewDives = await store.dives.getAll();
      final dives = <Dive>[];
      for (final d in overviewDives) {
        final fullDive = await store.diveById(d.id);
        if (fullDive != null) {
          dives.add(fullDive);
        }
      }

      final tempContainer = Container(dives: dives, sites: sites);
      final xmlDoc = await compute(_subsurfaceXml, tempContainer);

      await ssrfFile.writeAsString(xmlDoc);

      _log.info('SSRF export ready at ${ssrfFile.path}');
      emit(state.copyWith(working: false, exportReadyPath: ssrfFile.path, exportReadyFilename: filename));
    } catch (e) {
      _log.severe('SSRF export failed', e);
      emit(state.copyWith(working: false, error: e.toString()));
    }
  }
}

// Generate a Subsrurface XML document from the given container of dives &
// sites, using required remapping of IDs for Subsurface compatibility.
Future<String> _subsurfaceXml(Container container) async {
  // Subsurface requires site IDs to be exactly 8 hex digits.
  // Create a mapping from our UUIDs to 8-hex-digit IDs using first 4 bytes of SHA256.
  final siteIdMap = <String, String>{};
  for (final site in container.sites) {
    siteIdMap[site.id] = await _toSubsurfaceSiteId(site.id);
  }

  // Rebuild sites with Subsurface-compatible IDs
  final exportSites = container.sites.map((site) {
    return site.rebuild((s) => s.id = siteIdMap[site.id]!);
  }).toList();

  // Rebuild dives with remapped site IDs
  final exportDives = container.dives.map((dive) {
    if (dive.hasSiteId() && siteIdMap.containsKey(dive.siteId)) {
      return dive.rebuild((d) => d.siteId = siteIdMap[dive.siteId]!);
    }
    return dive;
  }).toList();

  // Create SSRF container and generate XML
  final ssrf = Container(dives: exportDives, sites: exportSites);
  return ssrf.toXmlDocument().toXmlString(pretty: true);
}

// Converts our site ID to a Subsurface-compatible 8 hex digit ID. Uses the
// first 4 bytes of SHA256 hash of the original ID. There is a risk of hash
// collision, which we ignore for now.
Future<String> _toSubsurfaceSiteId(String id) async {
  final bytes = (await Sha256().hash(utf8.encode(id))).bytes;
  return bytes.take(4).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
