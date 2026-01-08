import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sparkle/flutter_sparkle.dart';

import '../app_metadata.dart';
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

class UpdateCheckForUpdates extends PreferencesEvent {
  final bool checkForUpdates;

  const UpdateCheckForUpdates(this.checkForUpdates);

  @override
  List<Object?> get props => [checkForUpdates];
}

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesStorage _storage = PreferencesStorage();

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
      } else if (event is UpdateCheckForUpdates) {
        await _onUpdateCheckForUpdates(event, emit);
      }
    }, transformer: sequential());

    add(const LoadPreferences());
  }

  Future<void> _onLoad(LoadPreferences event, Emitter<PreferencesState> emit) async {
    final preferences = await _storage.load();
    emit(PreferencesState(preferences));
    if (preferences.checkForUpdates) FlutterSparkle.checkMacUpdate(updateCheckURL);
  }

  Future<void> _onUpdateCheckForUpdates(UpdateCheckForUpdates event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(checkForUpdates: event.checkForUpdates);
    await _storage.save(updated);
    emit(PreferencesState(updated));
    if (event.checkForUpdates) FlutterSparkle.checkMacUpdate(updateCheckURL);
  }

  Future<void> _onUpdateDepthUnit(UpdateDepthUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(depthUnit: event.depthUnit);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdatePressureUnit(UpdatePressureUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(pressureUnit: event.pressureUnit);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateTemperatureUnit(UpdateTemperatureUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(temperatureUnit: event.temperatureUnit);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateVolumeUnit(UpdateVolumeUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(volumeUnit: event.volumeUnit);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateWeightUnit(UpdateWeightUnit event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(weightUnit: event.weightUnit);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateDateFormat(UpdateDateFormat event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(dateFormat: event.dateFormat);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateTimeFormat(UpdateTimeFormat event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(timeFormat: event.timeFormat);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(themeMode: event.themeMode);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateSyncProvider(UpdateSyncProvider event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(syncProvider: event.syncProvider);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }

  Future<void> _onUpdateS3Config(UpdateS3Config event, Emitter<PreferencesState> emit) async {
    final current = state.preferences;
    final updated = current.copyWith(s3Config: event.s3Config);
    await _storage.save(updated);
    emit(PreferencesState(updated));
  }
}
