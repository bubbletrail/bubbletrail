import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../common/screen_scaffold.dart';
import 'preferences.dart';

class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Settings'),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final prefs = state.preferences;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SectionHeader(title: 'Units'),
              _PreferencesTile(
                title: 'Depth',
                trailing: SegmentedButton<DepthUnit>(
                  segments: const [
                    ButtonSegment(value: DepthUnit.meters, label: Text('m')),
                    ButtonSegment(value: DepthUnit.feet, label: Text('ft')),
                  ],
                  selected: {prefs.depthUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateDepthUnit(value.first));
                  },
                ),
              ),
              _PreferencesTile(
                title: 'Pressure',
                trailing: SegmentedButton<PressureUnit>(
                  segments: const [
                    ButtonSegment(value: PressureUnit.bar, label: Text('bar'), icon: Icon(null)),
                    ButtonSegment(value: PressureUnit.psi, label: Text('psi'), icon: Icon(null)),
                  ],
                  selected: {prefs.pressureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdatePressureUnit(value.first));
                  },
                ),
              ),
              _PreferencesTile(
                title: 'Temperature',
                trailing: SegmentedButton<TemperatureUnit>(
                  segments: const [
                    ButtonSegment(value: TemperatureUnit.celsius, label: Text('°C'), icon: Icon(null)),
                    ButtonSegment(value: TemperatureUnit.fahrenheit, label: Text('°F'), icon: Icon(null)),
                  ],
                  selected: {prefs.temperatureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateTemperatureUnit(value.first));
                  },
                ),
              ),
              _PreferencesTile(
                title: 'Volume',
                trailing: SegmentedButton<VolumeUnit>(
                  segments: const [
                    ButtonSegment(value: VolumeUnit.liters, label: Text('L'), icon: Icon(null)),
                    ButtonSegment(value: VolumeUnit.cuft, label: Text('cuft'), icon: Icon(null)),
                  ],
                  selected: {prefs.volumeUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateVolumeUnit(value.first));
                  },
                ),
              ),
              _PreferencesTile(
                title: 'Weight',
                trailing: SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg'), icon: Icon(null)),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lbs'), icon: Icon(null)),
                  ],
                  selected: {prefs.weightUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateWeightUnit(value.first));
                  },
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Date & Time'),
              _PreferencesTile(
                title: 'Date format',
                trailing: SegmentedButton<DateFormatPref>(
                  segments: const [
                    ButtonSegment(value: DateFormatPref.iso, label: Text('2024-12-25'), icon: Icon(null)),
                    ButtonSegment(value: DateFormatPref.us, label: Text('12/25/2024'), icon: Icon(null)),
                    ButtonSegment(value: DateFormatPref.eu, label: Text('25/12/2024'), icon: Icon(null)),
                  ],
                  selected: {prefs.dateFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateDateFormat(value.first));
                  },
                ),
              ),
              _PreferencesTile(
                title: 'Time format',
                trailing: SegmentedButton<TimeFormatPref>(
                  segments: const [
                    ButtonSegment(value: TimeFormatPref.h24, label: Text('24h'), icon: Icon(null)),
                    ButtonSegment(value: TimeFormatPref.h12, label: Text('12h'), icon: Icon(null)),
                  ],
                  selected: {prefs.timeFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateTimeFormat(value.first));
                  },
                ),
              ),
              const SizedBox(height: 24),
              _SectionHeader(title: 'Appearance'),
              _PreferencesTile(
                title: 'Theme',
                trailing: SegmentedButton<ThemeMode>(
                  showSelectedIcon: true,
                  segments: const [
                    ButtonSegment(value: ThemeMode.system, label: Text('System'), icon: Icon(null)),
                    ButtonSegment(value: ThemeMode.light, label: Text('Light'), icon: Icon(null)),
                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark'), icon: Icon(null)),
                  ],
                  selected: {prefs.themeMode},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateThemeMode(value.first));
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

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class _PreferencesTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const _PreferencesTile({required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyLarge)),
          trailing,
        ],
      ),
    );
  }
}
