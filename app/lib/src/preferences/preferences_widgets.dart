import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/sync_bloc.dart';
import '../common/common.dart';

class PreferencesSectionHeader extends StatelessWidget {
  final String title;

  const PreferencesSectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
    );
  }
}

class PreferencesTile extends StatelessWidget {
  final String title;
  final Widget trailing;

  const PreferencesTile({super.key, required this.title, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(vertical: 8),
      child: Wrap(
        alignment: .spaceBetween,
        spacing: 8,
        crossAxisAlignment: .center,
        runSpacing: 4,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
          trailing,
        ],
      ),
    );
  }
}

class SyncStatusTile extends StatelessWidget {
  final SyncState state;

  const SyncStatusTile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.syncing) {
      return _buildTile(context, icon: FontAwesomeIcons.arrowsRotate, iconColor: colorScheme.primary, message: 'Syncing...', isAnimating: true);
    }

    if (state.lastSyncSuccess == false) {
      return _buildTile(
        context,
        icon: FontAwesomeIcons.circleExclamation,
        iconColor: colorScheme.error,
        message: 'Sync failed: ${state.error ?? "Unknown error"}',
      );
    }

    if (state.lastSynced != null) {
      return _buildTile(
        context,
        icon: FontAwesomeIcons.circleCheck,
        iconColor: Theme.of(context).colorScheme.primary,
        message: 'Last synced',
        trailing: DateTimeText(state.lastSynced!, style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String message,
    bool isAnimating = false,
    Widget? trailing,
  }) {
    return Row(
      children: [
        if (isAnimating)
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
        else
          FaIcon(icon, size: 14, color: iconColor),
        const SizedBox(width: 8),
        Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
        if (trailing != null) ...[const SizedBox(width: 4), trailing],
      ],
    );
  }
}

class PreferencesCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PreferencesCategoryCard({super.key, required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: FaIcon(icon, size: 28),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const FaIcon(FontAwesomeIcons.chevronRight, size: 16),
        onTap: onTap,
      ),
    );
  }
}
