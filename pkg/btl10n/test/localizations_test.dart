import 'package:btl10n/btl10n.dart';
import 'package:btl10n/l10n/app_localizations_en.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations l10n;

  setUp(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('counts and durations use singular and plural forms', () {
    expect(l10n.diveCount(0), '0 dives');
    expect(l10n.diveCount(1), '1 dive');
    expect(l10n.diveCount(2), '2 dives');
    expect(l10n.computersFound(1), '1 dive computer found');
    expect(l10n.computersFound(3), '3 dive computers found');
    expect(l10n.hoursMinutesDuration(1, 5), '1 hour, 5 min');
    expect(l10n.daysHoursDuration(1, 1), '1 day, 1 hour');
    expect(l10n.daysHoursMinutesDuration(2, 3, 5), '2 days, 3 hours, 5 min');
    expect(l10n.cylinderReplacementPrompt(1), '1 dive uses this cylinder type. What should that dive use instead?');
    expect(l10n.cylinderReplacementPrompt(2), '2 dives use this cylinder type. What should those dives use instead?');
  });

  test('user text is interpolated without interpreting ICU syntax', () {
    const site = "Diver's {reef}";
    expect(l10n.diveTitle(12, site), "Dive #12: Diver's {reef}");
    expect(l10n.deleteSiteConfirmation(site), contains(site));
    expect(l10n.measurement('12.5', l10n.unitMeters), '12.5 m');
    expect(
      l10n.mergeDiveConfirmation(12, 11),
      'Dive #12 will be merged into dive #11, appending its profile to that dive. Dive #12 is then deleted. Continue?',
    );
  });

  test('errors retain their identity and resolve through the selected catalog', () {
    const error = LocalizedError(AppError.connectFailed, 'device unavailable');
    expect(localizeError(l10n, error), 'Failed to connect: device unavailable');
    expect(localizeError(l10n, 'platform diagnostic'), 'platform diagnostic');
    expect(error, const LocalizedError(AppError.connectFailed, 'device unavailable'));
  });

  test('the chosen catalog controls errors, equipment, and country labels', () {
    final translated = _TranslatedLabels();
    expect(localizeError(translated, const LocalizedError(AppError.connectFailed, 'radio')), 'Connexion impossible: radio');
    expect(equipmentTypeLabel(translated, 'Regulator'), 'Détendeur');
    expect(canonicalEquipmentType(translated, 'Détendeur'), 'Regulator');
    expect(localizedCountryName(translated, 'SE'), 'Suède');
    expect(localizeError(l10n, const LocalizedFormatException(LocalizedError(AppError.unknownJsonDiveLog))), 'Unknown JSON dive log format');
    expect(const LocalizedFormatException(LocalizedError(AppError.unknownJsonDiveLog)), isA<FormatException>());
  });

  test('equipment labels round trip without changing stored types', () {
    for (final type in equipmentTypes) {
      expect(canonicalEquipmentType(l10n, equipmentTypeLabel(l10n, type)), type);
    }
    expect(equipmentTypeLabel(l10n, 'Custom equipment'), 'Custom equipment');
  });

  testWidgets('Flutter delegates resolve inherited messages and fall back to English', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zz'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Builder(builder: (context) => Text(context.l10n.diveCount(2))),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('2 dives'), findsOneWidget);
    final context = tester.element(find.text('2 dives'));
    expect(Localizations.localeOf(context), const Locale('en'));
    expect(context.l10n.localeName, 'en');
  });
}

class _TranslatedLabels extends AppLocalizationsEn {
  @override
  String connectFailed(String details) => 'Connexion impossible: $details';

  @override
  String get equipmentRegulator => 'Détendeur';

  @override
  String get countrySE => 'Suède';
}
