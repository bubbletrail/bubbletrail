import 'package:flutter/material.dart';

enum DepthUnit { meters, feet }

enum PressureUnit { bar, psi }

enum TemperatureUnit { celsius, fahrenheit }

enum VolumeUnit { liters, cuft }

enum DateFormatPref { iso, us, eu }

enum TimeFormatPref { h24, h12 }

class Preferences {
  final DepthUnit depthUnit;
  final PressureUnit pressureUnit;
  final TemperatureUnit temperatureUnit;
  final VolumeUnit volumeUnit;
  final DateFormatPref dateFormat;
  final TimeFormatPref timeFormat;
  final ThemeMode themeMode;

  const Preferences({
    this.depthUnit = DepthUnit.meters,
    this.pressureUnit = PressureUnit.bar,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.volumeUnit = VolumeUnit.liters,
    this.dateFormat = DateFormatPref.iso,
    this.timeFormat = TimeFormatPref.h24,
    this.themeMode = ThemeMode.system,
  });

  Preferences copyWith({
    DepthUnit? depthUnit,
    PressureUnit? pressureUnit,
    TemperatureUnit? temperatureUnit,
    VolumeUnit? volumeUnit,
    DateFormatPref? dateFormat,
    TimeFormatPref? timeFormat,
    ThemeMode? themeMode,
  }) {
    return Preferences(
      depthUnit: depthUnit ?? this.depthUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      dateFormat: dateFormat ?? this.dateFormat,
      timeFormat: timeFormat ?? this.timeFormat,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Preferences &&
        other.depthUnit == depthUnit &&
        other.pressureUnit == pressureUnit &&
        other.temperatureUnit == temperatureUnit &&
        other.volumeUnit == volumeUnit &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(depthUnit, pressureUnit, temperatureUnit, volumeUnit, dateFormat, timeFormat, themeMode);
}
