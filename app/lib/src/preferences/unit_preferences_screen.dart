import 'package:btl10n/btl10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/screen_scaffold.dart';
import 'preferences.dart';
import 'preferences_store.dart';
import 'preferences_widgets.dart';

class UnitPreferencessScreen extends StatelessWidget {
  const UnitPreferencessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.units),
      body: Consumer<PreferencesStore>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const .all(16),
            children: [
              PreferencesTile(
                title: context.l10n.depth,
                trailing: SegmentedButton<DepthUnit>(
                  segments: [
                    ButtonSegment(value: .meters, label: Text(context.l10n.unitMeters), icon: Icon(Icons.public)),
                    ButtonSegment(value: .feet, label: Text(context.l10n.unitFeet), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.depthUnit},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.depthUnit = value.first;
                  },
                ),
              ),
              PreferencesTile(
                title: context.l10n.pressure,
                trailing: SegmentedButton<PressureUnit>(
                  segments: [
                    ButtonSegment(value: .bar, label: Text(context.l10n.unitBar), icon: Icon(Icons.public)),
                    ButtonSegment(value: .psi, label: Text(context.l10n.unitPsi), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.pressureUnit},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.pressureUnit = value.first;
                  },
                ),
              ),
              PreferencesTile(
                title: context.l10n.temperature,
                trailing: SegmentedButton<TemperatureUnit>(
                  segments: [
                    ButtonSegment(value: .celsius, label: Text(context.l10n.unitCelsius), icon: Icon(Icons.public)),
                    ButtonSegment(value: .fahrenheit, label: Text(context.l10n.unitFahrenheit), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.temperatureUnit},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.temperatureUnit = value.first;
                  },
                ),
              ),
              PreferencesTile(
                title: context.l10n.volume,
                trailing: SegmentedButton<VolumeUnit>(
                  segments: [
                    ButtonSegment(value: .liters, label: Text(context.l10n.unitLiters), icon: Icon(Icons.public)),
                    ButtonSegment(value: .cuft, label: Text(context.l10n.unitCubicFeet), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.volumeUnit},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.volumeUnit = value.first;
                  },
                ),
              ),
              PreferencesTile(
                title: context.l10n.weight,
                trailing: SegmentedButton<WeightUnit>(
                  segments: [
                    ButtonSegment(value: .kg, label: Text(context.l10n.unitKilograms), icon: Icon(Icons.public)),
                    ButtonSegment(value: .lb, label: Text(context.l10n.unitPoundsPlural), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.weightUnit},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.weightUnit = value.first;
                  },
                ),
              ),
              const Divider(height: 16),
              PreferencesTile(
                title: context.l10n.dateFormat,
                trailing: SegmentedButton<DateFormatPref>(
                  segments: [
                    ButtonSegment(value: DateFormatPref.eu, label: Text(context.l10n.dateExampleEuropean), icon: Icon(Icons.public)),
                    ButtonSegment(value: DateFormatPref.iso, label: Text(context.l10n.dateExampleIso), icon: Icon(Icons.description)),
                    ButtonSegment(value: DateFormatPref.us, label: Text(context.l10n.dateExampleUs), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.dateFormat},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.dateFormat = value.first;
                  },
                ),
              ),
              PreferencesTile(
                title: context.l10n.timeFormat,
                trailing: SegmentedButton<TimeFormatPref>(
                  segments: [
                    ButtonSegment(value: TimeFormatPref.h24, label: Text(context.l10n.timeFormat24Hour), icon: Icon(Icons.public)),
                    ButtonSegment(value: TimeFormatPref.h12, label: Text(context.l10n.timeFormat12Hour), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.timeFormat},
                  onSelectionChanged: (value) {
                    PreferencesStore.instance.timeFormat = value.first;
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
