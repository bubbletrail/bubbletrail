import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../common/screen_scaffold.dart';
import 'preferences.dart';
import 'preferences_widgets.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Units'),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final prefs = state.preferences;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PreferencesTile(
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
              PreferencesTile(
                title: 'Pressure',
                trailing: SegmentedButton<PressureUnit>(
                  segments: const [
                    ButtonSegment(value: PressureUnit.bar, label: Text('bar')),
                    ButtonSegment(value: PressureUnit.psi, label: Text('psi')),
                  ],
                  selected: {prefs.pressureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdatePressureUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Temperature',
                trailing: SegmentedButton<TemperatureUnit>(
                  segments: const [
                    ButtonSegment(value: TemperatureUnit.celsius, label: Text('°C')),
                    ButtonSegment(value: TemperatureUnit.fahrenheit, label: Text('°F')),
                  ],
                  selected: {prefs.temperatureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateTemperatureUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Volume',
                trailing: SegmentedButton<VolumeUnit>(
                  segments: const [
                    ButtonSegment(value: VolumeUnit.liters, label: Text('L')),
                    ButtonSegment(value: VolumeUnit.cuft, label: Text('cuft')),
                  ],
                  selected: {prefs.volumeUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateVolumeUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Weight',
                trailing: SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: WeightUnit.kg, label: Text('kg')),
                    ButtonSegment(value: WeightUnit.lb, label: Text('lbs')),
                  ],
                  selected: {prefs.weightUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateWeightUnit(value.first));
                  },
                ),
              ),
              const Divider(height: 16),
              PreferencesTile(
                title: 'Date format',
                trailing: SegmentedButton<DateFormatPref>(
                  segments: const [
                    ButtonSegment(value: DateFormatPref.iso, label: Text('2024-12-25')),
                    ButtonSegment(value: DateFormatPref.us, label: Text('12/25/2024')),
                    ButtonSegment(value: DateFormatPref.eu, label: Text('25/12/2024')),
                  ],
                  selected: {prefs.dateFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateDateFormat(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Time format',
                trailing: SegmentedButton<TimeFormatPref>(
                  segments: const [
                    ButtonSegment(value: TimeFormatPref.h24, label: Text('24h')),
                    ButtonSegment(value: TimeFormatPref.h12, label: Text('12h')),
                  ],
                  selected: {prefs.timeFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(UpdateTimeFormat(value.first));
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
