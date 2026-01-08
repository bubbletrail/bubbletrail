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

enum SyncProviderKind { none, s3 }

class S3Config {
  final String endpoint;
  final String bucket;
  final String accessKey;
  final String secretKey;
  final String region;
  final String syncKey;

  const S3Config({this.endpoint = '', this.bucket = '', this.accessKey = '', this.secretKey = '', this.region = 'us-east-1', this.syncKey = ''});

  bool get isConfigured => endpoint.isNotEmpty && bucket.isNotEmpty && accessKey.isNotEmpty && secretKey.isNotEmpty && syncKey.isNotEmpty;

  S3Config copyWith({String? endpoint, String? bucket, String? accessKey, String? secretKey, String? region, String? syncKey}) {
    return S3Config(
      endpoint: endpoint ?? this.endpoint,
      bucket: bucket ?? this.bucket,
      accessKey: accessKey ?? this.accessKey,
      secretKey: secretKey ?? this.secretKey,
      region: region ?? this.region,
      syncKey: syncKey ?? this.syncKey,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is S3Config &&
        other.endpoint == endpoint &&
        other.bucket == bucket &&
        other.accessKey == accessKey &&
        other.secretKey == secretKey &&
        other.region == region &&
        other.syncKey == syncKey;
  }

  @override
  int get hashCode => Object.hash(endpoint, bucket, accessKey, secretKey, region, syncKey);
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
  final SyncProviderKind syncProvider;
  final S3Config s3Config;

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
    this.syncProvider = SyncProviderKind.none,
    this.s3Config = const S3Config(),
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
    SyncProviderKind? syncProvider,
    S3Config? s3Config,
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
      syncProvider: syncProvider ?? this.syncProvider,
      s3Config: s3Config ?? this.s3Config,
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
        other.themeMode == themeMode &&
        other.syncProvider == syncProvider &&
        other.s3Config == s3Config;
  }

  @override
  int get hashCode => Object.hash(depthUnit, pressureUnit, temperatureUnit, volumeUnit, weightUnit, dateFormat, timeFormat, themeMode, syncProvider, s3Config);
}
