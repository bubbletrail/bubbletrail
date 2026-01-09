import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/preferences_bloc.dart';
import '../common/common.dart';
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
            padding: const .all(16),
            children: [
              _SyncProviderTile(prefs: prefs),
              if (prefs.syncProvider == .bubbletrail || prefs.syncProvider == .s3)
                _S3ConfigSection(prefs: prefs, isBubbletrail: prefs.syncProvider == .bubbletrail),
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
    final availableProviders = <SyncProviderKind>[.none, .bubbletrail, .s3];

    return PreferencesTile(
      title: 'Sync provider',
      trailing: DropdownButton<SyncProviderKind>(
        dropdownColor: Theme.of(context).colorScheme.primaryContainer,
        value: prefs.syncProvider,
        items: [for (final provider in availableProviders) DropdownMenuItem<SyncProviderKind>(value: provider, child: Text(_syncProviderLabel(provider)))],
        onChanged: (value) {
          context.read<PreferencesBloc>().add(UpdateSyncProvider(value!));
        },
      ),
    );
  }

  String _syncProviderLabel(SyncProviderKind provider) {
    return switch (provider) {
      .none => 'Off',
      .bubbletrail => 'Bubbletrail',
      .s3 => 'S3',
    };
  }
}

class _S3ConfigSection extends StatefulWidget {
  final Preferences prefs;
  final bool isBubbletrail;

  const _S3ConfigSection({required this.prefs, this.isBubbletrail = false});

  @override
  State<_S3ConfigSection> createState() => _S3ConfigSectionState();
}

class _S3ConfigSectionState extends State<_S3ConfigSection> {
  late TextEditingController _endpointController;
  late TextEditingController _bucketController;
  late TextEditingController _accessKeyController;
  late TextEditingController _secretKeyController;
  late TextEditingController _regionController;
  late TextEditingController _vaultKeyController;

  bool _obscureSecretKey = true;
  bool _obscureVaultKey = true;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(text: widget.prefs.s3Config.endpoint);
    _bucketController = TextEditingController(text: widget.prefs.s3Config.bucket);
    _accessKeyController = TextEditingController(text: widget.prefs.s3Config.accessKey);
    _secretKeyController = TextEditingController(text: widget.prefs.s3Config.secretKey);
    _regionController = TextEditingController(text: widget.prefs.s3Config.region);
    _vaultKeyController = TextEditingController(text: widget.prefs.s3Config.vaultKey);
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _bucketController.dispose();
    _accessKeyController.dispose();
    _secretKeyController.dispose();
    _regionController.dispose();
    _vaultKeyController.dispose();
    super.dispose();
  }

  void _saveConfig() {
    final config = S3Config(
      endpoint: widget.isBubbletrail ? 'sync.bubbletrail.net' : _endpointController.text.trim(),
      bucket: _bucketController.text.trim(),
      accessKey: _accessKeyController.text.trim(),
      secretKey: _secretKeyController.text.trim(),
      region: widget.isBubbletrail ? 'eu' : _regionController.text.trim(),
      vaultKey: _vaultKeyController.text.trim(),
    );
    context.read<PreferencesBloc>().add(UpdateS3Config(config));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 24,
      children: [
        const SizedBox(height: 8),
        Text(widget.isBubbletrail ? 'Bubbletrail sync configuration' : 'S3 configuration', style: Theme.of(context).textTheme.titleSmall),
        if (!widget.isBubbletrail)
          TextField(
            controller: _endpointController,
            decoration: const InputDecoration(labelText: 'Endpoint', hintText: 's3.amazonaws.com or minio.example.com', border: OutlineInputBorder()),
            onChanged: (_) => _saveConfig(),
            keyboardType: .url,
          ),
        if (!widget.isBubbletrail)
          TextField(
            controller: _regionController,
            decoration: const InputDecoration(labelText: 'Region', hintText: 'us-east-1', border: OutlineInputBorder()),
            onChanged: (_) => _saveConfig(),
            autocorrect: false,
          ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _bucketController,
              decoration: const InputDecoration(labelText: 'Bucket', hintText: 'my-bucket-name', border: OutlineInputBorder()),
              onChanged: (_) => _saveConfig(),
              autocorrect: false,
            ),
            Opacity(
              opacity: 0.7,
              child: Text('The bucket is the identifier for where your cloud data is stored.', style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _accessKeyController,
              decoration: const InputDecoration(labelText: 'Access key', border: OutlineInputBorder()),
              onChanged: (_) => _saveConfig(),
              autocorrect: false,
            ),
            Opacity(
              opacity: 0.7,
              child: Text('The access key is your username for authenticating to the storage provider.', style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _secretKeyController,
              decoration: InputDecoration(
                labelText: 'Secret key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: FaIcon(_obscureSecretKey ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash),
                  onPressed: () => setState(() => _obscureSecretKey = !_obscureSecretKey),
                ),
              ),
              obscureText: _obscureSecretKey,
              autocorrect: false,
              selectAllOnFocus: true,
              onChanged: (_) => _saveConfig(),
            ),
            Opacity(
              opacity: 0.7,
              child: Text('The secret key is your password for authenticating to the storage provider.', style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _vaultKeyController,
              decoration: InputDecoration(
                labelText: 'Vault key',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: FaIcon(_obscureVaultKey ? FontAwesomeIcons.eye : FontAwesomeIcons.eyeSlash),
                  onPressed: () => setState(() => _obscureVaultKey = !_obscureVaultKey),
                ),
              ),
              obscureText: _obscureVaultKey,
              autocorrect: false,
              selectAllOnFocus: true,
              onChanged: (_) => _saveConfig(),
            ),
            Opacity(
              opacity: 0.7,
              child: Text(
                'The vault key is the encryption password for data uploaded to the cloud. It prevents the storage provider from being able to read your data.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
