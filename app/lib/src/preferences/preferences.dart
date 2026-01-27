import 'package:btstore/btstore.dart' as btstore;
import 'package:flutter/material.dart' show ThemeMode;

extension DepthUnitExt on btstore.DepthUnit {
  String get label => switch (this) {
    .DEPTH_UNIT_METERS => 'm',
    .DEPTH_UNIT_FEET => 'ft',
    _ => 'm',
  };
}

extension PressureUnitExt on btstore.PressureUnit {
  String get label => switch (this) {
    .PRESSURE_UNIT_BAR => 'bar',
    .PRESSURE_UNIT_PSI => 'psi',
    _ => 'bar',
  };
}

extension TemperatureUnitExt on btstore.TemperatureUnit {
  String get label => switch (this) {
    .TEMPERATURE_UNIT_CELSIUS => '°C',
    .TEMPERATURE_UNIT_FAHRENHEIT => '°F',
    _ => '°C',
  };
}

extension VolumeUnitExt on btstore.VolumeUnit {
  String get label => switch (this) {
    .VOLUME_UNIT_LITERS => 'L',
    .VOLUME_UNIT_CUFT => 'cuft',
    _ => 'L',
  };
}

extension WeightUnitExt on btstore.WeightUnit {
  String get label => switch (this) {
    .WEIGHT_UNIT_KG => 'kg',
    .WEIGHT_UNIT_LB => 'lb',
    _ => 'kg',
  };
}

extension DateFormatPrefExt on btstore.DateFormatPref {
  String get format => switch (this) {
    .DATE_FORMAT_ISO => 'yyyy-MM-dd',
    .DATE_FORMAT_US => 'MM/dd/yyyy',
    .DATE_FORMAT_EU => 'dd/MM/yyyy',
    _ => 'yyyy-MM-dd',
  };
}

extension TimeFormatPrefExt on btstore.TimeFormatPref {
  String get format => switch (this) {
    .TIME_FORMAT_H24 => 'HH:mm',
    .TIME_FORMAT_H12 => 'h:mm a',
    _ => 'HH:mm',
  };
}

extension S3ConfigExt on btstore.S3Config {
  bool get isConfigured => endpoint.isNotEmpty && bucket.isNotEmpty && accessKey.isNotEmpty && secretKey.isNotEmpty && vaultKey.isNotEmpty;
}

extension PreferencesExt on btstore.Preferences {
  String get dateTimeFormat => '${dateFormat.format} ${timeFormat.format}';

  ThemeMode get flutterThemeMode => switch (themeMode) {
    .THEME_MODE_SYSTEM => ThemeMode.system,
    .THEME_MODE_LIGHT => ThemeMode.light,
    .THEME_MODE_DARK => ThemeMode.dark,
    _ => ThemeMode.system,
  };
}

btstore.ThemeModePref themeModeToProto(ThemeMode mode) => switch (mode) {
  ThemeMode.system => btstore.ThemeModePref.THEME_MODE_SYSTEM,
  ThemeMode.light => btstore.ThemeModePref.THEME_MODE_LIGHT,
  ThemeMode.dark => btstore.ThemeModePref.THEME_MODE_DARK,
};
