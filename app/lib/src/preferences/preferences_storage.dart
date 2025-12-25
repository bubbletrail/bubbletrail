import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences.dart';

class PreferencesStorage {
  static const _depthUnitKey = 'depth_unit';
  static const _pressureUnitKey = 'pressure_unit';
  static const _temperatureUnitKey = 'temperature_unit';
  static const _volumeUnitKey = 'volume_unit';
  static const _dateFormatKey = 'date_format';
  static const _timeFormatKey = 'time_format';
  static const _themeModeKey = 'theme_mode';

  Future<Preferences> load() async {
    final prefs = await SharedPreferences.getInstance();

    return Preferences(
      depthUnit: DepthUnit.values[prefs.getInt(_depthUnitKey) ?? 0],
      pressureUnit: PressureUnit.values[prefs.getInt(_pressureUnitKey) ?? 0],
      temperatureUnit: TemperatureUnit.values[prefs.getInt(_temperatureUnitKey) ?? 0],
      volumeUnit: VolumeUnit.values[prefs.getInt(_volumeUnitKey) ?? 0],
      dateFormat: DateFormatPref.values[prefs.getInt(_dateFormatKey) ?? 0],
      timeFormat: TimeFormatPref.values[prefs.getInt(_timeFormatKey) ?? 0],
      themeMode: ThemeMode.values[prefs.getInt(_themeModeKey) ?? 0],
    );
  }

  Future<void> save(Preferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_depthUnitKey, preferences.depthUnit.index);
    await prefs.setInt(_pressureUnitKey, preferences.pressureUnit.index);
    await prefs.setInt(_temperatureUnitKey, preferences.temperatureUnit.index);
    await prefs.setInt(_volumeUnitKey, preferences.volumeUnit.index);
    await prefs.setInt(_dateFormatKey, preferences.dateFormat.index);
    await prefs.setInt(_timeFormatKey, preferences.timeFormat.index);
    await prefs.setInt(_themeModeKey, preferences.themeMode.index);
  }
}
