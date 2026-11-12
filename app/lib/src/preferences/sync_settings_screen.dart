import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../common/common.dart';
import 'preferences_store.dart';
import 'preferences_widgets.dart';

class SyncSettingsScreen extends StatelessWidget {
  const SyncSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.syncingSection),
      body: Consumer<PreferencesStore>(
        builder: (context, prefs, _) {
          return ListView(
            padding: const .all(16),
            children: [
              _SyncProviderTile(syncProvider: prefs.syncProvider),
              if (prefs.syncProvider == .bubbletrail || prefs.syncProvider == .s3)
                _S3ConfigSection(s3Config: prefs.s3Config, isBubbletrail: prefs.syncProvider == .bubbletrail),
            ],
          );
        },
      ),
    );
  }
}

class _SyncProviderTile extends StatelessWidget {
  final SyncProviderKind syncProvider;

  const _SyncProviderTile({required this.syncProvider});

  @override
  Widget build(BuildContext context) {
    final availableProviders = <SyncProviderKind>[.none, .bubbletrail, .s3];

    return PreferencesTile(
      title: context.l10n.syncProvider,
      trailing: DropdownButton<SyncProviderKind>(
        dropdownColor: Theme.of(context).colorScheme.primaryContainer,
        value: syncProvider,
        items: [
          for (final provider in availableProviders) DropdownMenuItem<SyncProviderKind>(value: provider, child: Text(_syncProviderLabel(context, provider))),
        ],
        onChanged: (value) {
          PreferencesStore.instance.syncProvider = value!;
        },
      ),
    );
  }

  String _syncProviderLabel(BuildContext context, SyncProviderKind provider) {
    return switch (provider) {
      .none => context.l10n.off,
      .bubbletrail => context.l10n.bubbletrailS3,
      .s3 => context.l10n.genericS3,
    };
  }
}

class _S3ConfigSection extends StatefulWidget {
  final S3Config s3Config;
  final bool isBubbletrail;

  const _S3ConfigSection({required this.s3Config, this.isBubbletrail = false});

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
    _endpointController = TextEditingController(text: widget.s3Config.endpoint);
    _bucketController = TextEditingController(text: widget.s3Config.bucket);
    _accessKeyController = TextEditingController(text: widget.s3Config.accessKey);
    _secretKeyController = TextEditingController(text: widget.s3Config.secretKey);
    _regionController = TextEditingController(text: widget.s3Config.region);
    _vaultKeyController = TextEditingController(text: widget.s3Config.vaultKey);
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
    PreferencesStore.instance.s3Config = config;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      spacing: 24,
      children: [
        const SizedBox(height: 8),
        Text(widget.isBubbletrail ? context.l10n.bubbletrailSyncConfiguration : context.l10n.s3Configuration, style: Theme.of(context).textTheme.titleSmall),
        if (!widget.isBubbletrail)
          TextField(
            controller: _endpointController,
            decoration: InputDecoration(labelText: context.l10n.endpoint, hintText: context.l10n.s3AmazonawsComOrMinioExampleCom, border: OutlineInputBorder()),
            onChanged: (_) => _saveConfig(),
            keyboardType: .url,
          ),
        if (!widget.isBubbletrail)
          TextField(
            controller: _regionController,
            decoration: InputDecoration(labelText: context.l10n.region, hintText: 'us-east-1', border: OutlineInputBorder()),
            onChanged: (_) => _saveConfig(),
            autocorrect: false,
          ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _bucketController,
              decoration: InputDecoration(labelText: context.l10n.bucket, hintText: context.l10n.myBucketName, border: OutlineInputBorder()),
              onChanged: (_) => _saveConfig(),
              autocorrect: false,
            ),
            Opacity(
              opacity: 0.7,
              child: Text(context.l10n.theBucketIsTheIdentifierForWhereYourCloudDataIsStored, style: Theme.of(context).textTheme.labelMedium),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: .start,
          spacing: 8,
          children: [
            TextField(
              controller: _accessKeyController,
              decoration: InputDecoration(labelText: context.l10n.accessKey, border: OutlineInputBorder()),
              onChanged: (_) => _saveConfig(),
              autocorrect: false,
            ),
            Opacity(
              opacity: 0.7,
              child: Text(context.l10n.theAccessKeyIsYourUsernameForAuthenticatingToTheStorageProvider, style: Theme.of(context).textTheme.labelMedium),
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
                labelText: context.l10n.secretKey,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureSecretKey ? Icons.visibility : Icons.visibility_off),
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
              child: Text(context.l10n.theSecretKeyIsYourPasswordForAuthenticatingToTheStorageProvider, style: Theme.of(context).textTheme.labelMedium),
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
                labelText: context.l10n.vaultKey,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureVaultKey ? Icons.visibility : Icons.visibility_off),
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
                context.l10n.theVaultKeyIsTheEncryptionPasswordForDataUploadedToTheCloudItPreventsTheStorageProvid,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
