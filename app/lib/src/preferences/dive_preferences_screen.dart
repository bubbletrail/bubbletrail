import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/screen_scaffold.dart';
import 'preferences_store.dart';
import 'preferences_widgets.dart';

class DivePreferencesScreen extends StatelessWidget {
  const DivePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive preferences'),
      body: Consumer<PreferencesStore>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const .all(16),
            children: [
              PreferencesSectionHeader(title: 'Gradient Factors'),
              const SizedBox(height: 8),
              Text('Gradient factors adjust the conservatism of the Buhlmann decompression algorithm.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              _GfSlider(label: 'GF Low', value: prefs.gfLow, onChanged: (value) => PreferencesStore.instance.gfLow = value),
              const SizedBox(height: 8),
              _GfSlider(label: 'GF High', value: prefs.gfHigh, onChanged: (value) => PreferencesStore.instance.gfHigh = value),
            ],
          );
        },
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
            Text('${(value * 100).round()}%', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        Slider(value: value, min: 0.1, max: 1.0, divisions: 18, label: '${(value * 100).round()}%', onChanged: (v) => onChanged(v)),
      ],
    );
  }
}
