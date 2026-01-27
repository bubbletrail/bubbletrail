import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btstore/btstore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/storage_provider.dart';
import 'preferences_storage.dart';

class PreferencesState {
  final Preferences preferences;

  const PreferencesState(this.preferences);
}

sealed class PreferencesEvent {
  const PreferencesEvent();

  factory PreferencesEvent.update(void Function(Preferences) updates) = _Update;
  const factory PreferencesEvent.resetDatabase() = _ResetDatabase;
}

class _LoadPreferences extends PreferencesEvent {
  const _LoadPreferences();
}

class _Update extends PreferencesEvent {
  final void Function(Preferences) updates;

  _Update(this.updates);
}

class _ResetDatabase extends PreferencesEvent {
  const _ResetDatabase();
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  Timer? _saveTimer;

  PreferencesBloc() : super(PreferencesState(Preferences())) {
    on<PreferencesEvent>((event, emit) async {
      switch (event) {
        case _LoadPreferences():
          await _onLoad(emit);
        case _Update():
          _onUpdate(event, emit);
        case _ResetDatabase():
          await _onResetDatabase(emit);
      }
    }, transformer: sequential());

    add(const _LoadPreferences());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 1), () async => await PreferencesStorage.save(state.preferences));
  }

  Future<void> _onLoad(Emitter<PreferencesState> emit) async {
    final preferences = await PreferencesStorage.load();
    emit(PreferencesState(preferences));
  }

  void _onUpdate(_Update event, Emitter<PreferencesState> emit) {
    final updated = state.preferences.rebuild(event.updates);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onResetDatabase(Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.syncProvider = .SYNC_PROVIDER_NONE);
    emit(PreferencesState(updated));
    _scheduleSave();

    final store = await StorageProvider.store;
    await store.reset();
  }
}
