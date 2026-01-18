import 'dart:async';
import 'dart:math';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../preferences/preferences.dart';
import '../preferences/preferences_storage.dart';

class PreferencesState extends Equatable {
  final Preferences preferences;

  const PreferencesState(this.preferences);

  @override
  List<Object?> get props => [preferences];
}

abstract class PreferencesEvent extends Equatable {
  const PreferencesEvent();

  @override
  List<Object?> get props => [];
}

class LoadPreferences extends PreferencesEvent {
  const LoadPreferences();
}

class UpdateDepthUnit extends PreferencesEvent {
  final DepthUnit depthUnit;

  const UpdateDepthUnit(this.depthUnit);

  @override
  List<Object?> get props => [depthUnit];
}

class UpdatePressureUnit extends PreferencesEvent {
  final PressureUnit pressureUnit;

  const UpdatePressureUnit(this.pressureUnit);

  @override
  List<Object?> get props => [pressureUnit];
}

class UpdateTemperatureUnit extends PreferencesEvent {
  final TemperatureUnit temperatureUnit;

  const UpdateTemperatureUnit(this.temperatureUnit);

  @override
  List<Object?> get props => [temperatureUnit];
}

class UpdateVolumeUnit extends PreferencesEvent {
  final VolumeUnit volumeUnit;

  const UpdateVolumeUnit(this.volumeUnit);

  @override
  List<Object?> get props => [volumeUnit];
}

class UpdateWeightUnit extends PreferencesEvent {
  final WeightUnit weightUnit;

  const UpdateWeightUnit(this.weightUnit);

  @override
  List<Object?> get props => [weightUnit];
}

class UpdateDateFormat extends PreferencesEvent {
  final DateFormatPref dateFormat;

  const UpdateDateFormat(this.dateFormat);

  @override
  List<Object?> get props => [dateFormat];
}

class UpdateTimeFormat extends PreferencesEvent {
  final TimeFormatPref timeFormat;

  const UpdateTimeFormat(this.timeFormat);

  @override
  List<Object?> get props => [timeFormat];
}

class UpdateThemeMode extends PreferencesEvent {
  final ThemeMode themeMode;

  const UpdateThemeMode(this.themeMode);

  @override
  List<Object?> get props => [themeMode];
}

class UpdateSyncProvider extends PreferencesEvent {
  final SyncProviderKind syncProvider;

  const UpdateSyncProvider(this.syncProvider);

  @override
  List<Object?> get props => [syncProvider];
}

class UpdateS3Config extends PreferencesEvent {
  final S3Config s3Config;

  const UpdateS3Config(this.s3Config);

  @override
  List<Object?> get props => [s3Config];
}

class UpdateGfLow extends PreferencesEvent {
  final double gfLow;

  const UpdateGfLow(this.gfLow);

  @override
  List<Object?> get props => [gfLow];
}

class UpdateGfHigh extends PreferencesEvent {
  final double gfHigh;

  const UpdateGfHigh(this.gfHigh);

  @override
  List<Object?> get props => [gfHigh];
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesStorage _storage = PreferencesStorage();
  Timer? _saveTimer;

  PreferencesBloc() : super(const PreferencesState(Preferences())) {
    on<PreferencesEvent>((event, emit) async {
      if (event is LoadPreferences) {
        await _onLoad(event, emit);
      } else if (event is UpdateDepthUnit) {
        await _onUpdateDepthUnit(event, emit);
      } else if (event is UpdatePressureUnit) {
        await _onUpdatePressureUnit(event, emit);
      } else if (event is UpdateTemperatureUnit) {
        await _onUpdateTemperatureUnit(event, emit);
      } else if (event is UpdateVolumeUnit) {
        await _onUpdateVolumeUnit(event, emit);
      } else if (event is UpdateWeightUnit) {
        await _onUpdateWeightUnit(event, emit);
      } else if (event is UpdateDateFormat) {
        await _onUpdateDateFormat(event, emit);
      } else if (event is UpdateTimeFormat) {
        await _onUpdateTimeFormat(event, emit);
      } else if (event is UpdateThemeMode) {
        await _onUpdateThemeMode(event, emit);
      } else if (event is UpdateSyncProvider) {
        await _onUpdateSyncProvider(event, emit);
      } else if (event is UpdateS3Config) {
        await _onUpdateS3Config(event, emit);
      } else if (event is UpdateGfLow) {
        await _onUpdateGfLow(event, emit);
      } else if (event is UpdateGfHigh) {
        await _onUpdateGfHigh(event, emit);
      }
    }, transformer: sequential());

    add(const LoadPreferences());
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(Duration(seconds: 5), () => _storage.save(state.preferences));
  }

  Future<void> _onLoad(LoadPreferences event, Emitter<PreferencesState> emit) async {
    final preferences = await _storage.load();
    emit(PreferencesState(preferences));
  }

  Future<void> _onUpdateDepthUnit(UpdateDepthUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(depthUnit: event.depthUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdatePressureUnit(UpdatePressureUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(pressureUnit: event.pressureUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateTemperatureUnit(UpdateTemperatureUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(temperatureUnit: event.temperatureUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateVolumeUnit(UpdateVolumeUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(volumeUnit: event.volumeUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateWeightUnit(UpdateWeightUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(weightUnit: event.weightUnit);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateDateFormat(UpdateDateFormat event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(dateFormat: event.dateFormat);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateTimeFormat(UpdateTimeFormat event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(timeFormat: event.timeFormat);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(themeMode: event.themeMode);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateSyncProvider(UpdateSyncProvider event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(syncProvider: event.syncProvider);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateS3Config(UpdateS3Config event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(s3Config: event.s3Config);
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateGfLow(UpdateGfLow event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(gfLow: event.gfLow, gfHigh: max(state.preferences.gfHigh, event.gfLow));
    emit(PreferencesState(updated));
    _scheduleSave();
  }

  Future<void> _onUpdateGfHigh(UpdateGfHigh event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(gfHigh: event.gfHigh, gfLow: min(state.preferences.gfLow, event.gfHigh));
    emit(PreferencesState(updated));
    _scheduleSave();
  }
}
