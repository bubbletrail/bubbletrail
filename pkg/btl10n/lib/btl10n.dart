import 'package:flutter/widgets.dart';

import 'l10n/app_localizations.dart';

export 'l10n/app_localizations.dart';
export 'l10n/country_names.dart';
export 'l10n/equipment_types.dart';
export 'l10n/localized_error.dart';

/// Accesses messages for the locale inherited from the widget tree.
extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
