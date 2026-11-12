import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../common/screen_scaffold.dart';
import 'preferences_store.dart';
import 'preferences_widgets.dart';

class DivePreferencesScreen extends StatelessWidget {
  const DivePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesStore>();
    return ScreenScaffold(
      title: Text(context.l10n.divePreferences),
      body: ListView(
        padding: const .all(16),
        children: [
          PreferencesSectionHeader(title: context.l10n.gradientFactors),
          const SizedBox(height: 8),
          Text(context.l10n.gradientFactorsAdjustTheConservatismOfTheBuhlmannDecompressionAlgorithm, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          _GfSlider(label: context.l10n.gfLow, value: prefs.gfLow, onChanged: (value) => PreferencesStore.instance.gfLow = value),
          const SizedBox(height: 8),
          _GfSlider(label: context.l10n.gfHigh, value: prefs.gfHigh, onChanged: (value) => PreferencesStore.instance.gfHigh = value),
        ],
      ),
    );
  }
}

class _GfSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _GfSlider({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyLarge),
            Text(context.l10n.percentage((value * 100).round()), style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: 0.1, max: 1.0, divisions: 18, label: context.l10n.percentage((value * 100).round()), onChanged: (v) => onChanged(v)),
      ],
    );
  }
}
