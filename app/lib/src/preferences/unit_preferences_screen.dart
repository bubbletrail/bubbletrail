import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'preferences_bloc.dart';
import '../common/screen_scaffold.dart';
import 'preferences.dart';
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
                  segments: const [
                    ButtonSegment(value: .meters, label: Text('m'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .feet, label: Text('ft'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.depthUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateDepthUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Pressure',
                trailing: SegmentedButton<PressureUnit>(
                  segments: const [
                    ButtonSegment(value: .bar, label: Text('bar'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .psi, label: Text('psi'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.pressureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updatePressureUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Temperature',
                trailing: SegmentedButton<TemperatureUnit>(
                  segments: const [
                    ButtonSegment(value: .celsius, label: Text('°C'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .fahrenheit, label: Text('°F'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.temperatureUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateTemperatureUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Volume',
                trailing: SegmentedButton<VolumeUnit>(
                  segments: const [
                    ButtonSegment(value: .liters, label: Text('L'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .cuft, label: Text('cuft'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.volumeUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateVolumeUnit(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Weight',
                trailing: SegmentedButton<WeightUnit>(
                  segments: const [
                    ButtonSegment(value: .kg, label: Text('kg'), icon: Icon(Icons.public)),
                    ButtonSegment(value: .lb, label: Text('lbs'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.weightUnit},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateWeightUnit(value.first));
                  },
                ),
              ),
              const Divider(height: 16),
              PreferencesTile(
                title: 'Date format',
                trailing: SegmentedButton<DateFormatPref>(
                  segments: const [
                    ButtonSegment(value: DateFormatPref.eu, label: Text('25/12/2024'), icon: Icon(Icons.public)),
                    ButtonSegment(value: DateFormatPref.iso, label: Text('2024-12-25'), icon: Icon(Icons.description)),
                    ButtonSegment(value: DateFormatPref.us, label: Text('12/25/2024'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.dateFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateDateFormat(value.first));
                  },
                ),
              ),
              PreferencesTile(
                title: 'Time format',
                trailing: SegmentedButton<TimeFormatPref>(
                  segments: const [
                    ButtonSegment(value: TimeFormatPref.h24, label: Text('24h'), icon: Icon(Icons.public)),
                    ButtonSegment(value: TimeFormatPref.h12, label: Text('12h'), icon: Icon(Icons.star_border)),
                  ],
                  selected: {prefs.timeFormat},
                  onSelectionChanged: (value) {
                    context.read<PreferencesBloc>().add(PreferencesEvent.updateTimeFormat(value.first));
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
