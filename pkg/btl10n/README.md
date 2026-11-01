# Bubbletrail localizations

This Flutter package owns the app's user-facing messages. English is the source
language and the fallback. It uses Flutter's standard ARB and `gen-l10n` workflow.

Edit `lib/l10n/app_en.arb`, including typed placeholders. Add a
translation as `lib/l10n/app_<locale>.arb` with the same message keys. Use ICU
plurals for counts and complete messages rather than concatenated fragments.

Regenerate and check the package:

```sh
cd pkg/btl10n
flutter pub get
flutter gen-l10n
flutter analyze --fatal-infos
flutter test
```

The generated `app_localizations*.dart` files are committed; regenerate them,
rather than editing them. Flutter also generates them during `flutter pub get`
in this package. Run that here after editing ARB files, before building the app.

Widgets import `package:btl10n/btl10n.dart` and read `context.l10n`. The app installs
`AppLocalizations.localizationsDelegates` and `AppLocalizations.supportedLocales`
on `MaterialApp`. Shared formatters receive the current `AppLocalizations`.

BLoCs keep `LocalizedError` codes and diagnostic details, resolving their messages
when displayed. Country names and equipment type labels are translated separately from their
canonical stored values. User-entered names, tags, notes, imported content,
protocol identifiers, and diagnostic logs retain their original text.
