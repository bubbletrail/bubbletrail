import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'preferences.dart';

class PreferencesStorage {
  static const _depthUnitKey = 'depth_unit';
  static const _pressureUnitKey = 'pressure_unit';
  static const _temperatureUnitKey = 'temperature_unit';
  static const _volumeUnitKey = 'volume_unit';
  static const _weightUnitKey = 'weight_unit';
  static const _dateFormatKey = 'date_format';
  static const _timeFormatKey = 'time_format';
  static const _themeModeKey = 'theme_mode';
  static const _syncProviderKey = 'sync_provider';
  static const _s3EndpointKey = 's3_endpoint';
  static const _s3BucketKey = 's3_bucket';
  static const _s3AccessKeyKey = 's3_access_key';
  static const _s3SecretKeyKey = 's3_secret_key';
  static const _s3RegionKey = 's3_region';

  Future<Preferences> load() async {
    final prefs = await SharedPreferences.getInstance();

    return Preferences(
      depthUnit: DepthUnit.values[prefs.getInt(_depthUnitKey) ?? 0],
      pressureUnit: PressureUnit.values[prefs.getInt(_pressureUnitKey) ?? 0],
      temperatureUnit: TemperatureUnit.values[prefs.getInt(_temperatureUnitKey) ?? 0],
      volumeUnit: VolumeUnit.values[prefs.getInt(_volumeUnitKey) ?? 0],
      weightUnit: WeightUnit.values[prefs.getInt(_weightUnitKey) ?? 0],
      dateFormat: DateFormatPref.values[prefs.getInt(_dateFormatKey) ?? 0],
      timeFormat: TimeFormatPref.values[prefs.getInt(_timeFormatKey) ?? 0],
      themeMode: ThemeMode.values[prefs.getInt(_themeModeKey) ?? 0],
      syncProvider: SyncProviderKind.values[prefs.getInt(_syncProviderKey) ?? 0],
      s3Config: S3Config(
        endpoint: prefs.getString(_s3EndpointKey) ?? '',
        bucket: prefs.getString(_s3BucketKey) ?? '',
        accessKey: prefs.getString(_s3AccessKeyKey) ?? '',
        secretKey: prefs.getString(_s3SecretKeyKey) ?? '',
        region: prefs.getString(_s3RegionKey) ?? 'us-east-1',
      ),
    );
  }

  Future<void> save(Preferences preferences) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_depthUnitKey, preferences.depthUnit.index);
    await prefs.setInt(_pressureUnitKey, preferences.pressureUnit.index);
    await prefs.setInt(_temperatureUnitKey, preferences.temperatureUnit.index);
    await prefs.setInt(_volumeUnitKey, preferences.volumeUnit.index);
    await prefs.setInt(_weightUnitKey, preferences.weightUnit.index);
    await prefs.setInt(_dateFormatKey, preferences.dateFormat.index);
    await prefs.setInt(_timeFormatKey, preferences.timeFormat.index);
    await prefs.setInt(_themeModeKey, preferences.themeMode.index);
    await prefs.setInt(_syncProviderKey, preferences.syncProvider.index);
    await prefs.setString(_s3EndpointKey, preferences.s3Config.endpoint);
    await prefs.setString(_s3BucketKey, preferences.s3Config.bucket);
    await prefs.setString(_s3AccessKeyKey, preferences.s3Config.accessKey);
    await prefs.setString(_s3SecretKeyKey, preferences.s3Config.secretKey);
    await prefs.setString(_s3RegionKey, preferences.s3Config.region);
  }
}
