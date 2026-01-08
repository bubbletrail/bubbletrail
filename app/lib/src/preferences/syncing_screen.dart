import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../bloc/sync_bloc.dart';
import '../common/common.dart';
import 'preferences.dart';
import 'preferences_widgets.dart';

class SyncingScreen extends StatelessWidget {
  const SyncingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Syncing'),
      body: BlocBuilder<PreferencesBloc, PreferencesState>(
        builder: (context, state) {
          final prefs = state.preferences;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SyncProviderTile(prefs: prefs),
              if (prefs.syncProvider == SyncProviderKind.s3) _S3ConfigSection(prefs: prefs),
              const SizedBox(height: 24),
              BlocBuilder<SyncBloc, SyncState>(
                builder: (context, syncState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SyncStatusTile(state: syncState),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: syncState.syncing || prefs.syncProvider == SyncProviderKind.none
                            ? null
                            : () => context.read<SyncBloc>().add(const StartSyncing()),
                        icon: syncState.syncing
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.sync),
                        label: Text(syncState.syncing ? 'Syncing...' : 'Sync Now'),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SyncProviderTile extends StatelessWidget {
  final Preferences prefs;

  const _SyncProviderTile({required this.prefs});

  @override
  Widget build(BuildContext context) {
    final availableProviders = <SyncProviderKind>[SyncProviderKind.none, SyncProviderKind.s3];

    return PreferencesTile(
      title: 'Sync Provider',
      trailing: SegmentedButton<SyncProviderKind>(
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

  String _syncProviderLabel(SyncProviderKind provider) {
    return switch (provider) {
      SyncProviderKind.none => 'Off',
      SyncProviderKind.s3 => 'S3',
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
  late TextEditingController _syncKeyController;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.prefs.s3Config.endpoint);
    _bucketController = TextEditingController(text: widget.prefs.s3Config.bucket);
    _accessKeyController = TextEditingController(text: widget.prefs.s3Config.accessKey);
    _secretKeyController = TextEditingController(text: widget.prefs.s3Config.secretKey);
    _regionController = TextEditingController(text: widget.prefs.s3Config.region);
    _syncKeyController = TextEditingController(text: widget.prefs.s3Config.syncKey);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _regionController.dispose();
    _syncKeyController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    final config = S3Config(
      endpoint: _endpointController.text.trim(),
      bucket: _bucketController.text.trim(),
      accessKey: _accessKeyController.text.trim(),
      secretKey: _secretKeyController.text.trim(),
      region: _regionController.text.trim(),
      syncKey: _regionController.text.trim(),
    );
    context.read<PreferencesBloc>().add(UpdateS3Config(config));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        const SizedBox(height: 8),
        Text('S3 Configuration', style: Theme.of(context).textTheme.titleSmall),
        TextField(
          controller: _endpointController,
          decoration: const InputDecoration(labelText: 'Endpoint', hintText: 's3.amazonaws.com or minio.example.com', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
          keyboardType: TextInputType.url,
        ),
        TextField(
          controller: _bucketController,
          decoration: const InputDecoration(labelText: 'Bucket', hintText: 'my-bucket-name', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
          autocorrect: false,
        ),
        TextField(
          controller: _regionController,
          decoration: const InputDecoration(labelText: 'Region', hintText: 'us-east-1', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
          autocorrect: false,
        ),
        TextField(
          controller: _accessKeyController,
          decoration: const InputDecoration(labelText: 'Access Key', border: OutlineInputBorder()),
          onChanged: (_) => _saveConfig(),
          autocorrect: false,
        ),
        TextField(
          controller: _secretKeyController,
          decoration: const InputDecoration(labelText: 'Secret Key', border: OutlineInputBorder()),
          obscureText: true,
          autocorrect: false,
          onChanged: (_) => _saveConfig(),
        ),
        TextField(
          controller: _syncKeyController,
          decoration: const InputDecoration(labelText: 'Sync Key', border: OutlineInputBorder()),
          obscureText: true,
          autocorrect: false,
          onChanged: (_) => _saveConfig(),
        ),
      ],
    );
  }
}
