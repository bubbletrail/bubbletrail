import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/storage_provider.dart';
import 'preferences.dart';

class PreferencesStore extends ChangeNotifier {
  static final instance = PreferencesStore._();
  PreferencesStore._();

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

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    notifyListeners();
  }

  // Individual getters with defaults
  DepthUnit get depthUnit => DepthUnit.values[_prefs.getInt(_depthUnitKey) ?? 0];
  set depthUnit(DepthUnit value) {
    _prefs.setInt(_depthUnitKey, value.index);
    notifyListeners();
  }

  PressureUnit get pressureUnit => PressureUnit.values[_prefs.getInt(_pressureUnitKey) ?? 0];
  set pressureUnit(PressureUnit value) {
    _prefs.setInt(_pressureUnitKey, value.index);
    notifyListeners();
  }

  TemperatureUnit get temperatureUnit => TemperatureUnit.values[_prefs.getInt(_temperatureUnitKey) ?? 0];
  set temperatureUnit(TemperatureUnit value) {
    _prefs.setInt(_temperatureUnitKey, value.index);
    notifyListeners();
  }

  VolumeUnit get volumeUnit => VolumeUnit.values[_prefs.getInt(_volumeUnitKey) ?? 0];
  set volumeUnit(VolumeUnit value) {
    _prefs.setInt(_volumeUnitKey, value.index);
    notifyListeners();
  }

  WeightUnit get weightUnit => WeightUnit.values[_prefs.getInt(_weightUnitKey) ?? 0];
  set weightUnit(WeightUnit value) {
    _prefs.setInt(_weightUnitKey, value.index);
    notifyListeners();
  }

  DateFormatPref get dateFormat => DateFormatPref.values[_prefs.getInt(_dateFormatKey) ?? 0];
  set dateFormat(DateFormatPref value) {
    _prefs.setInt(_dateFormatKey, value.index);
    notifyListeners();
  }

  TimeFormatPref get timeFormat => TimeFormatPref.values[_prefs.getInt(_timeFormatKey) ?? 0];
  set timeFormat(TimeFormatPref value) {
    _prefs.setInt(_timeFormatKey, value.index);
    notifyListeners();
  }

  ThemeMode get themeMode => ThemeMode.values[_prefs.getInt(_themeModeKey) ?? 0];
  set themeMode(ThemeMode value) {
    _prefs.setInt(_themeModeKey, value.index);
    notifyListeners();
  }

  SyncProviderKind get syncProvider => SyncProviderKind.values[_prefs.getInt(_syncProviderKey) ?? 0];
  set syncProvider(SyncProviderKind value) {
    _prefs.setInt(_syncProviderKey, value.index);
    notifyListeners();
  }

  // S3Config as combined entity
  S3Config get s3Config => S3Config(
    endpoint: _prefs.getString(_s3EndpointKey) ?? '',
    bucket: _prefs.getString(_s3BucketKey) ?? '',
    accessKey: _prefs.getString(_s3AccessKeyKey) ?? '',
    secretKey: _prefs.getString(_s3SecretKeyKey) ?? '',
    region: _prefs.getString(_s3RegionKey) ?? 'us-east-1',
    vaultKey: _prefs.getString(_s3VaultKey) ?? '',
  );
  set s3Config(S3Config value) {
    _prefs.setString(_s3EndpointKey, value.endpoint);
    _prefs.setString(_s3BucketKey, value.bucket);
    _prefs.setString(_s3AccessKeyKey, value.accessKey);
    _prefs.setString(_s3SecretKeyKey, value.secretKey);
    _prefs.setString(_s3RegionKey, value.region);
    _prefs.setString(_s3VaultKey, value.vaultKey);
    notifyListeners();
  }

  double get gfLow => _prefs.getDouble(_gfLowKey) ?? 0.5;
  set gfLow(double value) {
    _prefs.setDouble(_gfLowKey, value);
    // Enforce gfHigh >= gfLow
    if (gfHigh < value) {
      _prefs.setDouble(_gfHighKey, value);
    }
    notifyListeners();
  }

  double get gfHigh => _prefs.getDouble(_gfHighKey) ?? 0.7;
  set gfHigh(double value) {
    _prefs.setDouble(_gfHighKey, value);
    // Enforce gfLow <= gfHigh
    if (gfLow > value) {
      _prefs.setDouble(_gfLowKey, value);
    }
    notifyListeners();
  }

  // Computed getter
  String get dateTimeFormat => '${dateFormat.format} ${timeFormat.format}';

  // Reset database: sets syncProvider to none and resets storage
  Future<void> resetDatabase() async {
    syncProvider = .none;
    final store = await StorageProvider.store;
    await store.reset();
  }
}
