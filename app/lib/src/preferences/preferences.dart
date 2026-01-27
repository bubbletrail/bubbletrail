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

enum SyncProviderKind { none, bubbletrail, s3 }

class S3Config {
  final String endpoint;
  final String bucket;
  final String accessKey;
  final String secretKey;
  final String region;
  final String vaultKey;

  const S3Config({this.endpoint = '', this.bucket = '', this.accessKey = '', this.secretKey = '', this.region = 'us-east-1', this.vaultKey = ''});

  bool get isConfigured => endpoint.isNotEmpty && bucket.isNotEmpty && accessKey.isNotEmpty && secretKey.isNotEmpty && vaultKey.isNotEmpty;

  S3Config copyWith({String? endpoint, String? bucket, String? accessKey, String? secretKey, String? region, String? vaultKey}) {
    return S3Config(
      endpoint: endpoint ?? this.endpoint,
      bucket: bucket ?? this.bucket,
      accessKey: accessKey ?? this.accessKey,
      secretKey: secretKey ?? this.secretKey,
      region: region ?? this.region,
      vaultKey: vaultKey ?? this.vaultKey,
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
        other.vaultKey == vaultKey;
  }

  @override
  int get hashCode => Object.hash(endpoint, bucket, accessKey, secretKey, region, vaultKey);
}
