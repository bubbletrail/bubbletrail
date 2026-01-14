import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

import '../app_metadata.dart';
import 'sync_bloc.dart';
import 'zip_archive_provider.dart';

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

  ArchiveState copyWith({
    bool? working,
    String? error,
    String? exportReadyPath,
    String? exportReadyFilename,
    bool? exportComplete,
    bool? importComplete,
  }) {
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

sealed class ArchiveEvent {}

class ExportArchive extends ArchiveEvent {}

class ExportComplete extends ArchiveEvent {
  final String destinationPath;
  ExportComplete(this.destinationPath);
}

class ExportCancelled extends ArchiveEvent {}

class ImportArchive extends ArchiveEvent {
  final String zipPath;
  ImportArchive(this.zipPath);
}

class ArchiveBloc extends Bloc<ArchiveEvent, ArchiveState> {
  final SyncBloc _syncBloc;

  ArchiveBloc({required SyncBloc syncBloc})
      : _syncBloc = syncBloc,
        super(const ArchiveState()) {
    on<ExportArchive>(_onExport);
    on<ExportComplete>(_onExportComplete);
    on<ExportCancelled>(_onExportCancelled);
    on<ImportArchive>(_onImport);
  }

  Future<void> _onExport(ExportArchive event, Emitter<ArchiveState> emit) async {
    emit(state.copyWith(working: true, error: null));
    try {
      final store = await _syncBloc.store;
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

  Future<void> _onExportComplete(ExportComplete event, Emitter<ArchiveState> emit) async {
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

  Future<void> _onExportCancelled(ExportCancelled event, Emitter<ArchiveState> emit) async {
    final exportPath = state.exportReadyPath;
    if (exportPath != null) {
      try {
        await File(exportPath).delete();
      } catch (_) {}
    }
    emit(const ArchiveState());
  }

  Future<void> _onImport(ImportArchive event, Emitter<ArchiveState> emit) async {
    emit(state.copyWith(working: true, error: null));
    try {
      final store = await _syncBloc.store;
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
}
