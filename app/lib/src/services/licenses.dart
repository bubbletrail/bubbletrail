import 'package:flutter/foundation.dart';

/// Registers additional licenses not automatically collected by Flutter.
void registerAdditionalLicenses() {
  LicenseRegistry.addLicense(() async* {
    yield const LicenseEntryWithLineBreaks(['Scuba icons'], _scubaIconsLicense);
  });
}

const _scubaIconsLicense = '''
Icons made by Anditii Creative from www.flaticon.com
''';
