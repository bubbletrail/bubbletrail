import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/screen_scaffold.dart';
import 'preferences_bloc.dart';
import 'preferences_widgets.dart';

class UnitPreferencessScreen extends StatelessWidget {
  const UnitPreferencessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Units'),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final prefs = state.preferences;
          return ListView(
            padding: const .all(16),
            children: [
              PreferencesTile(
                title: 'Depth',
                trailing: SegmentedButton<DepthUnit>(
                  segments: [
                    ButtonSegment(value: .DEPTH_UNIT_METERS, label: Text('m'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .DEPTH_UNIT_FEET, label: Text('ft'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.depthUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.depthUnit = value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Pressure',
                trailing: SegmentedButton<PressureUnit>(
                  segments: [
                    ButtonSegment(value: .PRESSURE_UNIT_BAR, label: Text('bar'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .PRESSURE_UNIT_PSI, label: Text('psi'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.pressureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.pressureUnit = value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Temperature',
                trailing: SegmentedButton<TemperatureUnit>(
                  segments: [
                    ButtonSegment(value: .TEMPERATURE_UNIT_CELSIUS, label: Text('°C'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .TEMPERATURE_UNIT_FAHRENHEIT, label: Text('°F'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.temperatureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.temperatureUnit = value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Volume',
                trailing: SegmentedButton<VolumeUnit>(
                  segments: [
                    ButtonSegment(value: .VOLUME_UNIT_LITERS, label: Text('L'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .VOLUME_UNIT_CUFT, label: Text('cuft'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.volumeUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.volumeUnit = value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Weight',
                trailing: SegmentedButton<WeightUnit>(
                  segments: [
                    ButtonSegment(value: .WEIGHT_UNIT_KG, label: Text('kg'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .WEIGHT_UNIT_LB, label: Text('lbs'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.weightUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.weightUnit = value.first));
                  },
                ),
              ),
              const Divider(height: 16),
              PreferencesTile(
                title: 'Date format',
                trailing: SegmentedButton<DateFormatPref>(
                  segments: [
                    ButtonSegment(value: .DATE_FORMAT_EU, label: Text('25/12/2024'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .DATE_FORMAT_ISO, label: Text('2024-12-25'), icon: Icon(Icons.description)),
                    ButtonSegment(value: .DATE_FORMAT_US, label: Text('12/25/2024'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.dateFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.dateFormat = value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Time format',
                trailing: SegmentedButton<TimeFormatPref>(
                  segments: [
                    ButtonSegment(value: .TIME_FORMAT_H24, label: Text('24h'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .TIME_FORMAT_H12, label: Text('12h'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.timeFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.update((p) => p.timeFormat = value.first));
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
