import 'package:flutter/material.dart';

enum DepthUnit {
  meters('m'),
  feet('ft');

  const DepthUnit(this.label);

  final String label;
}

enum PressureUnit {
  bar('bar'),
  psi('psi');

  const PressureUnit(this.label);

  final String label;
}

enum TemperatureUnit {
  celsius('°C'),
  fahrenheit('°F');

  const TemperatureUnit(this.label);

  final String label;
}

enum VolumeUnit {
  liters('L'),
  cuft('cuft');

  const VolumeUnit(this.label);

  final String label;
}

enum WeightUnit {
  kg('kg'),
  lb('lb');

  const WeightUnit(this.label);

  final String label;
}

enum DateFormatPref {
  iso('yyyy-MM-dd'),
  us('MM/dd/yyyy'),
  eu('dd/MM/yyyy');

  const DateFormatPref(this.format);

  final String format;
}

enum TimeFormatPref {
  h24('HH:mm'),
  h12('h:mm a');

  const TimeFormatPref(this.format);

  final String format;
}

class Preferences {
  final DepthUnit depthUnit;
  final PressureUnit pressureUnit;
  final TemperatureUnit temperatureUnit;
  final VolumeUnit volumeUnit;
  final WeightUnit weightUnit;
  final DateFormatPref dateFormat;
  final TimeFormatPref timeFormat;
  final ThemeMode themeMode;

  String get dateTimeFormat => '${dateFormat.format} ${timeFormat.format}';

  const Preferences({
    this.depthUnit = DepthUnit.meters,
    this.pressureUnit = PressureUnit.bar,
    this.temperatureUnit = TemperatureUnit.celsius,
    this.volumeUnit = VolumeUnit.liters,
    this.weightUnit = WeightUnit.kg,
    this.dateFormat = DateFormatPref.iso,
    this.timeFormat = TimeFormatPref.h24,
    this.themeMode = ThemeMode.system,
  });

  Preferences copyWith({
    DepthUnit? depthUnit,
    PressureUnit? pressureUnit,
    TemperatureUnit? temperatureUnit,
    VolumeUnit? volumeUnit,
    WeightUnit? weightUnit,
    DateFormatPref? dateFormat,
    TimeFormatPref? timeFormat,
    ThemeMode? themeMode,
  }) {
    return Preferences(
      depthUnit: depthUnit ?? this.depthUnit,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      volumeUnit: volumeUnit ?? this.volumeUnit,
      weightUnit: weightUnit ?? this.weightUnit,
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
        other.weightUnit == weightUnit &&
        other.dateFormat == dateFormat &&
        other.timeFormat == timeFormat &&
        other.themeMode == themeMode;
  }

  @override
  int get hashCode => Object.hash(depthUnit, pressureUnit, temperatureUnit, volumeUnit, weightUnit, dateFormat, timeFormat, themeMode);
}
