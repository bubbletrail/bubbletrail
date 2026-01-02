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
                bottom: 16,
                child: Column(
                  children: [
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
