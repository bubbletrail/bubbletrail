import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../bloc/sync_bloc.dart';
import '../common/common.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, state) {
        return ScreenScaffold(
          title: const Text('Equipment'),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: state.syncing ? null : () => context.read<SyncBloc>().add(const StartSyncing()),
            label: Text(state.syncing ? 'Syncing...' : 'Sync'),
            icon: state.syncing ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.sync),
          ),
          body: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _EquipmentCategoryCard(icon: Icons.scuba_diving, title: 'Cylinders', onTap: () => context.goNamed(AppRouteName.cylinders)),
                  _EquipmentCategoryCard(icon: Icons.settings, title: 'Preferences', onTap: () => context.goNamed(AppRouteName.settings)),
                ],
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SyncStatusTile(state: state),
                    const SizedBox(height: 8),
                    Text(
                      'Bubbletrail $appVer ($gitVer)',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                    DateTimeText(
                      buildTime,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SyncStatusTile extends StatelessWidget {
  final SyncState state;

  const _SyncStatusTile({required this.state});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.syncing) {
      return _buildTile(
        context,
        icon: Icons.sync,
        iconColor: colorScheme.primary,
        message: 'Syncing...',
        isAnimating: true,
      );
    }

    if (state.lastSyncSuccess == false) {
      return _buildTile(
        context,
        icon: Icons.error_outline,
        iconColor: colorScheme.error,
        message: 'Sync failed: ${state.error ?? "Unknown error"}',
      );
    }

    if (state.lastSynced != null) {
      return _buildTile(
        context,
        icon: Icons.check_circle_outline,
        iconColor: Colors.green,
        message: 'Last synced',
        trailing: DateTimeText(state.lastSynced!, style: Theme.of(context).textTheme.bodySmall),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTile(BuildContext context, {required IconData icon, required Color iconColor, required String message, bool isAnimating = false, Widget? trailing}) {
    return Row(
      children: [
        if (isAnimating)
          SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: iconColor))
        else
          Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Text(message, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: iconColor)),
        if (trailing != null) ...[
          const SizedBox(width: 4),
          trailing,
        ],
      ],
    );
  }
}

class _EquipmentCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _EquipmentCategoryCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
