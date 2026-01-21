import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'preferences_bloc.dart';
import '../common/screen_scaffold.dart';
import 'preferences_widgets.dart';

class DivePreferencesScreen extends StatelessWidget {
  const DivePreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive preferences'),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final prefs = state.preferences;
          return ListView(
            padding: const .all(16),
            children: [
              PreferencesSectionHeader(title: 'Gradient Factors'),
              const SizedBox(height: 8),
              Text('Gradient factors adjust the conservatism of the Buhlmann decompression algorithm.', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 16),
              _GfSlider(label: 'GF Low', value: prefs.gfLow, onChanged: (value) => context.read<PreferencesBloc>().add(UpdateGfLow(value))),
              const SizedBox(height: 8),
              _GfSlider(label: 'GF High', value: prefs.gfHigh, onChanged: (value) => context.read<PreferencesBloc>().add(UpdateGfHigh(value))),
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
