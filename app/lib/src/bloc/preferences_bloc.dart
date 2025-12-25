import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../preferences/preferences.dart';
import '../preferences/preferences_storage.dart';

abstract class PreferencesState extends Equatable {
  const PreferencesState();

  @override
  List<Object?> get props => [];
}

class PreferencesInitial extends PreferencesState {
  const PreferencesInitial();
}

class PreferencesLoaded extends PreferencesState {
  final Preferences preferences;

  const PreferencesLoaded(this.preferences);

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

class PreferencesBloc extends Bloc<PreferencesEvent, PreferencesState> {
  final PreferencesStorage _storage = PreferencesStorage();

  PreferencesBloc() : super(const PreferencesInitial()) {
    on<PreferencesEvent>((event, emit) async {
      if (event is LoadPreferences) {
        await _onLoad(event, emit);
      } else if (event is UpdateDepthUnit) {
        await _onUpdateDepthUnit(event, emit);
      } else if (event is UpdatePressureUnit) {
        await _onUpdatePressureUnit(event, emit);
      } else if (event is UpdateTemperatureUnit) {
        await _onUpdateTemperatureUnit(event, emit);
      } else if (event is UpdateDateFormat) {
        await _onUpdateDateFormat(event, emit);
      } else if (event is UpdateTimeFormat) {
        await _onUpdateTimeFormat(event, emit);
      } else if (event is UpdateThemeMode) {
        await _onUpdateThemeMode(event, emit);
      }
    }, transformer: sequential());

    add(const LoadPreferences());
  }

  Future<void> _onLoad(LoadPreferences event, Emitter<PreferencesState> emit) async {
    final preferences = await _storage.load();
    emit(PreferencesLoaded(preferences));
  }

  Future<void> _onUpdateDepthUnit(UpdateDepthUnit event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(depthUnit: event.depthUnit);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }

  Future<void> _onUpdatePressureUnit(UpdatePressureUnit event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(pressureUnit: event.pressureUnit);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }

  Future<void> _onUpdateTemperatureUnit(UpdateTemperatureUnit event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(temperatureUnit: event.temperatureUnit);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }

  Future<void> _onUpdateDateFormat(UpdateDateFormat event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(dateFormat: event.dateFormat);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }

  Future<void> _onUpdateTimeFormat(UpdateTimeFormat event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(timeFormat: event.timeFormat);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<PreferencesState> emit) async {
    if (state is! PreferencesLoaded) return;
    final current = (state as PreferencesLoaded).preferences;
    final updated = current.copyWith(themeMode: event.themeMode);
    await _storage.save(updated);
    emit(PreferencesLoaded(updated));
  }
}
