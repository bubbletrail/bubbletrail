import 'app_localizations.dart';

/// Locale-independent error codes, safe to retain in BLoC state.
enum AppError {
  unknownXmlDiveLog,
  unsupportedJsonDiveLog,
  unknownJsonDiveLog,
  invalidSuuntoDiveLog,

  deviceDownloadFailed,
  equipmentNotFound,
  loadEquipmentFailed,
  updateEquipmentFailed,
  deleteEquipmentFailed,
  certificationNotFound,
  loadCertificationFailed,
  updateCertificationFailed,
  deleteCertificationFailed,
  cylinderNotFound,
  loadCylinderFailed,
  updateCylinderFailed,
  connectFailed,
  noServicesDiscovered,
  noBleCharacteristics,
  notificationsFailed,
  downloadFailed,
}

class LocalizedError implements Exception {
  final AppError code;
  final Object? details;

  const LocalizedError(this.code, [this.details]);

  String localize(AppLocalizations l10n) => switch (code) {
    AppError.unknownXmlDiveLog => l10n.unknownXmlDiveLog(_localizedDetails(l10n)),
    AppError.unsupportedJsonDiveLog => l10n.unsupportedJsonDiveLog,
    AppError.unknownJsonDiveLog => l10n.unknownJsonDiveLog,
    AppError.invalidSuuntoDiveLog => l10n.invalidSuuntoDiveLog,

    AppError.deviceDownloadFailed => l10n.deviceDownloadFailed(_localizedDetails(l10n)),
    AppError.equipmentNotFound => l10n.equipmentNotFound,
    AppError.loadEquipmentFailed => l10n.loadEquipmentFailed(_localizedDetails(l10n)),
    AppError.updateEquipmentFailed => l10n.updateEquipmentFailed(_localizedDetails(l10n)),
    AppError.deleteEquipmentFailed => l10n.deleteEquipmentFailed(_localizedDetails(l10n)),
    AppError.certificationNotFound => l10n.certificationNotFound,
    AppError.loadCertificationFailed => l10n.loadCertificationFailed(_localizedDetails(l10n)),
    AppError.updateCertificationFailed => l10n.updateCertificationFailed(_localizedDetails(l10n)),
    AppError.deleteCertificationFailed => l10n.deleteCertificationFailed(_localizedDetails(l10n)),
    AppError.cylinderNotFound => l10n.cylinderNotFound,
    AppError.loadCylinderFailed => l10n.loadCylinderFailed(_localizedDetails(l10n)),
    AppError.updateCylinderFailed => l10n.updateCylinderFailed(_localizedDetails(l10n)),
    AppError.connectFailed => l10n.connectFailed(_localizedDetails(l10n)),
    AppError.noServicesDiscovered => l10n.noServicesDiscovered,
    AppError.noBleCharacteristics => l10n.noBleCharacteristics,
    AppError.notificationsFailed => l10n.notificationsFailed(_localizedDetails(l10n)),
    AppError.downloadFailed => l10n.downloadFailed(_localizedDetails(l10n)),
  };

  String _localizedDetails(AppLocalizations l10n) => details is LocalizedError ? (details as LocalizedError).localize(l10n) : details.toString();

  @override
  String toString() => 'LocalizedError(${code.name}, $details)';

  @override
  bool operator ==(Object other) => other is LocalizedError && code == other.code && details == other.details;

  @override
  int get hashCode => Object.hash(code, details);
}

/// Localizes app errors while preserving diagnostic text from platform APIs.
String localizeError(AppLocalizations l10n, Object error) => switch (error) {
  LocalizedError() => error.localize(l10n),
  LocalizedFormatException() => error.error.localize(l10n),
  _ => error.toString(),
};

/// Preserves the import API's FormatException contract while deferring translation.
class LocalizedFormatException extends FormatException {
  final LocalizedError error;

  const LocalizedFormatException(this.error) : super('');

  @override
  String toString() => 'FormatException: $error';
}
