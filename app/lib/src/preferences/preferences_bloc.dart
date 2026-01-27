import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btstore/btstore.dart' as btstore;
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/storage_provider.dart';
import 'preferences.dart';
import 'preferences_storage.dart';

class PreferencesState extends Equatable {
  final Preferences preferences;

  const PreferencesState(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

sealed class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];

  const factory PreferencesEvent.updateDepthUnit(DepthUnit depthUnit) = _UpdateDepthUnit;
  const factory PreferencesEvent.updatePressureUnit(PressureUnit pressureUnit) = _UpdatePressureUnit;
  const factory PreferencesEvent.updateTemperatureUnit(TemperatureUnit temperatureUnit) = _UpdateTemperatureUnit;
  const factory PreferencesEvent.updateVolumeUnit(VolumeUnit volumeUnit) = _UpdateVolumeUnit;
  const factory PreferencesEvent.updateWeightUnit(WeightUnit weightUnit) = _UpdateWeightUnit;
  const factory PreferencesEvent.updateDateFormat(DateFormatPref dateFormat) = _UpdateDateFormat;
  const factory PreferencesEvent.updateTimeFormat(TimeFormatPref timeFormat) = _UpdateTimeFormat;
  const factory PreferencesEvent.updateThemeMode(ThemeMode themeMode) = _UpdateThemeMode;
  const factory PreferencesEvent.updateSyncProvider(SyncProviderPref syncProvider) = _UpdateSyncProvider;
  const factory PreferencesEvent.updateS3Config(S3Config s3Config) = _UpdateS3Config;
  const factory PreferencesEvent.updateGfLow(double gfLow) = _UpdateGfLow;
  const factory PreferencesEvent.updateGfHigh(double gfHigh) = _UpdateGfHigh;
  const factory PreferencesEvent.resetDatabase() = _ResetDatabase;
}

class _LoadPreferences extends PreferencesEvent {
  const _LoadPreferences();
}

class _UpdateDepthUnit extends PreferencesEvent {
  final DepthUnit depthUnit;

  const _UpdateDepthUnit(this.depthUnit);

  @override
  List<Object?> get props => [depthUnit];
}

class _UpdatePressureUnit extends PreferencesEvent {
  final PressureUnit pressureUnit;

  const _UpdatePressureUnit(this.pressureUnit);

  @override
  List<Object?> get props => [pressureUnit];
}

class _UpdateTemperatureUnit extends PreferencesEvent {
  final TemperatureUnit temperatureUnit;

  const _UpdateTemperatureUnit(this.temperatureUnit);

  @override
  List<Object?> get props => [temperatureUnit];
}

class _UpdateVolumeUnit extends PreferencesEvent {
  final VolumeUnit volumeUnit;

  const _UpdateVolumeUnit(this.volumeUnit);

  @override
  List<Object?> get props => [volumeUnit];
}

class _UpdateWeightUnit extends PreferencesEvent {
  final WeightUnit weightUnit;

  const _UpdateWeightUnit(this.weightUnit);

  @override
  List<Object?> get props => [weightUnit];
}

class _UpdateDateFormat extends PreferencesEvent {
  final DateFormatPref dateFormat;

  const _UpdateDateFormat(this.dateFormat);

  @override
  List<Object?> get props => [dateFormat];
}

class _UpdateTimeFormat extends PreferencesEvent {
  final TimeFormatPref timeFormat;

  const _UpdateTimeFormat(this.timeFormat);

  @override
  List<Object?> get props => [timeFormat];
}

class _UpdateThemeMode extends PreferencesEvent {
  final ThemeMode themeMode;

  const _UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class _UpdateSyncProvider extends PreferencesEvent {
  final SyncProviderPref syncProvider;

  const _UpdateSyncProvider(this.syncProvider);

  @override
  List<Object?> get props => [syncProvider];
}

class _UpdateS3Config extends PreferencesEvent {
  final S3Config s3Config;

  const _UpdateS3Config(this.s3Config);

  @override
  List<Object?> get props => [s3Config];
}

class _UpdateGfLow extends PreferencesEvent {
  final double gfLow;

  const _UpdateGfLow(this.gfLow);

  @override
  List<Object?> get props => [gfLow];
}

class _UpdateGfHigh extends PreferencesEvent {
  final double gfHigh;

  const _UpdateGfHigh(this.gfHigh);

  @override
  List<Object?> get props => [gfHigh];
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
        case _UpdateDepthUnit():
          await _onUpdateDepthUnit(event, emit);
        case _UpdatePressureUnit():
          await _onUpdatePressureUnit(event, emit);
        case _UpdateTemperatureUnit():
          await _onUpdateTemperatureUnit(event, emit);
        case _UpdateVolumeUnit():
          await _onUpdateVolumeUnit(event, emit);
        case _UpdateWeightUnit():
          await _onUpdateWeightUnit(event, emit);
        case _UpdateDateFormat():
          await _onUpdateDateFormat(event, emit);
        case _UpdateTimeFormat():
          await _onUpdateTimeFormat(event, emit);
        case _UpdateThemeMode():
          await _onUpdateThemeMode(event, emit);
        case _UpdateSyncProvider():
          await _onUpdateSyncProvider(event, emit);
        case _UpdateS3Config():
          await _onUpdateS3Config(event, emit);
        case _UpdateGfLow():
          await _onUpdateGfLow(event, emit);
        case _UpdateGfHigh():
          await _onUpdateGfHigh(event, emit);
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

  Future<void> _onUpdateDepthUnit(_UpdateDepthUnit event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.depthUnit = event.depthUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdatePressureUnit(_UpdatePressureUnit event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.pressureUnit = event.pressureUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateTemperatureUnit(_UpdateTemperatureUnit event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.temperatureUnit = event.temperatureUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateVolumeUnit(_UpdateVolumeUnit event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.volumeUnit = event.volumeUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateWeightUnit(_UpdateWeightUnit event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.weightUnit = event.weightUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateDateFormat(_UpdateDateFormat event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.dateFormat = event.dateFormat);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateTimeFormat(_UpdateTimeFormat event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.timeFormat = event.timeFormat);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateThemeMode(_UpdateThemeMode event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.themeMode = themeModeToProto(event.themeMode));
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateSyncProvider(_UpdateSyncProvider event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.syncProvider = event.syncProvider);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateS3Config(_UpdateS3Config event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) => p.s3Config = event.s3Config);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateGfLow(_UpdateGfLow event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) {
      p.gfLow = event.gfLow;
      p.gfHigh = max(state.preferences.gfHigh, event.gfLow);
    });
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateGfHigh(_UpdateGfHigh event, Emitter<PreferencesState> emit) async {
    final updated = state.preferences.rebuild((p) {
      p.gfHigh = event.gfHigh;
      p.gfLow = min(state.preferences.gfLow, event.gfHigh);
    });
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
