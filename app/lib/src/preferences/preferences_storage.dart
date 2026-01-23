import 'dart:async';

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
  static const _s3VaultKey = 's3_vault_key';
  static const _gfLowKey = 'gf_low';
  static const _gfHighKey = 'gf_high';

  static final _changes = StreamController<Preferences>.broadcast();
  static var _current = Preferences();
  static Stream<Preferences> get changes => _changes.stream;

  static Future<Preferences> load() async {
    final sp = await SharedPreferences.getInstance();
    final prefs = Preferences(
      depthUnit: DepthUnit.values[sp.getInt(_depthUnitKey) ?? 0],
      pressureUnit: PressureUnit.values[sp.getInt(_pressureUnitKey) ?? 0],
      temperatureUnit: TemperatureUnit.values[sp.getInt(_temperatureUnitKey) ?? 0],
      volumeUnit: VolumeUnit.values[sp.getInt(_volumeUnitKey) ?? 0],
      weightUnit: WeightUnit.values[sp.getInt(_weightUnitKey) ?? 0],
      dateFormat: DateFormatPref.values[sp.getInt(_dateFormatKey) ?? 0],
      timeFormat: TimeFormatPref.values[sp.getInt(_timeFormatKey) ?? 0],
      themeMode: ThemeMode.values[sp.getInt(_themeModeKey) ?? 0],
      syncProvider: SyncProviderKind.values[sp.getInt(_syncProviderKey) ?? 0],
      s3Config: S3Config(
        endpoint: sp.getString(_s3EndpointKey) ?? '',
        bucket: sp.getString(_s3BucketKey) ?? '',
        accessKey: sp.getString(_s3AccessKeyKey) ?? '',
        secretKey: sp.getString(_s3SecretKeyKey) ?? '',
        region: sp.getString(_s3RegionKey) ?? 'us-east-1',
        vaultKey: sp.getString(_s3VaultKey) ?? '',
      ),
      gfLow: sp.getDouble(_gfLowKey) ?? 0.5,
      gfHigh: sp.getDouble(_gfHighKey) ?? 0.7,
    );

    if (prefs != _current) {
      _changes.add(prefs);
      _current = prefs;
    }
    return prefs;
  }

  static Future<void> save(Preferences prefs) async {
    final sp = await SharedPreferences.getInstance();

    await sp.setInt(_depthUnitKey, prefs.depthUnit.index);
    await sp.setInt(_pressureUnitKey, prefs.pressureUnit.index);
    await sp.setInt(_temperatureUnitKey, prefs.temperatureUnit.index);
    await sp.setInt(_volumeUnitKey, prefs.volumeUnit.index);
    await sp.setInt(_weightUnitKey, prefs.weightUnit.index);
    await sp.setInt(_dateFormatKey, prefs.dateFormat.index);
    await sp.setInt(_timeFormatKey, prefs.timeFormat.index);
    await sp.setInt(_themeModeKey, prefs.themeMode.index);
    await sp.setInt(_syncProviderKey, prefs.syncProvider.index);
    await sp.setString(_s3EndpointKey, prefs.s3Config.endpoint);
    await sp.setString(_s3BucketKey, prefs.s3Config.bucket);
    await sp.setString(_s3AccessKeyKey, prefs.s3Config.accessKey);
    await sp.setString(_s3SecretKeyKey, prefs.s3Config.secretKey);
    await sp.setString(_s3RegionKey, prefs.s3Config.region);
    await sp.setString(_s3VaultKey, prefs.s3Config.vaultKey);
    await sp.setDouble(_gfLowKey, prefs.gfLow);
    await sp.setDouble(_gfHighKey, prefs.gfHigh);

    if (prefs != _current) {
      _changes.add(prefs);
      _current = prefs;
    }
  }
}
