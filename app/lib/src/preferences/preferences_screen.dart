import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../bloc/sync_bloc.dart';
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
              _SectionHeader(title: 'Cloud Sync'),
              _SyncProviderTile(prefs: prefs),
              if (prefs.syncProvider == SyncProvider.s3) _S3ConfigSection(prefs: prefs),
              const SizedBox(height: 24),
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

class _SyncProviderTile extends StatelessWidget {
  final Preferences prefs;

  const _SyncProviderTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Filter available providers based on platform
    final availableProviders = <SyncProvider>[SyncProvider.none, if (Platform.isIOS || Platform.isMacOS) SyncProvider.icloud, SyncProvider.s3];

    return _PreferencesTile(
      title: 'Sync Provider',
      trailing: SegmentedButton<SyncProvider>(
        segments: [
          for (final provider in availableProviders) ButtonSegment(value: provider, label: Text(_syncProviderLabel(provider)), icon: const Icon(null)),
        ],
        selected: {prefs.syncProvider},
        onSelectionChanged: (value) {
          context.read<PreferencesBloc>().add(UpdateSyncProvider(value.first));
        },
      ),
    );
  }

  String _syncProviderLabel(SyncProvider provider) {
    return switch (provider) {
      SyncProvider.none => 'Off',
      SyncProvider.icloud => 'iCloud',
      SyncProvider.s3 => 'S3',
    };
  }
}

class _S3ConfigSection extends StatefulWidget {
  final Preferences prefs;

  const _S3ConfigSection({required this.prefs});

  @override
  State<_S3ConfigSection> createState() => _S3ConfigSectionState();
}

class _S3ConfigSectionState extends State<_S3ConfigSection> {
  late TextEditingController _endpointController;
  late TextEditingController _bucketController;
  late TextEditingController _accessKeyController;
  late TextEditingController _secretKeyController;
  late TextEditingController _regionController;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.prefs.s3Config.endpoint);
    _bucketController = TextEditingController(text: widget.prefs.s3Config.bucket);
    _accessKeyController = TextEditingController(text: widget.prefs.s3Config.accessKey);
    _secretKeyController = TextEditingController(text: widget.prefs.s3Config.secretKey);
    _regionController = TextEditingController(text: widget.prefs.s3Config.region);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _regionController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    final config = S3Config(
      endpoint: _endpointController.text.trim(),
      bucket: _bucketController.text.trim(),
      accessKey: _accessKeyController.text.trim(),
      secretKey: _secretKeyController.text.trim(),
      region: _regionController.text.trim(),
    );
    context.read<PreferencesBloc>().add(UpdateS3Config(config));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('S3 Configuration', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 12),
        TextField(
          controller: _endpointController,
          decoration: const InputDecoration(labelText: 'Endpoint', hintText: 's3.amazonaws.com or minio.example.com', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _bucketController,
          decoration: const InputDecoration(labelText: 'Bucket', hintText: 'my-bucket-name', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _regionController,
          decoration: const InputDecoration(labelText: 'Region', hintText: 'us-east-1', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _accessKeyController,
          decoration: const InputDecoration(labelText: 'Access Key', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _secretKeyController,
          decoration: const InputDecoration(labelText: 'Secret Key', border: OutlineInputBorder()),
          obscureText: true,
          onChanged: (_) => _saveConfig(),
        ),
        const SizedBox(height: 12),
        BlocBuilder<SyncBloc, SyncState>(
          builder: (context, syncState) {
            return Row(
              children: [
                if (widget.prefs.s3Config.isConfigured)
                  const Icon(Icons.check_circle, color: Colors.green)
                else
                  const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(widget.prefs.s3Config.isConfigured ? 'Configured' : 'Not configured', style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          },
        ),
      ],
    );
  }
}
