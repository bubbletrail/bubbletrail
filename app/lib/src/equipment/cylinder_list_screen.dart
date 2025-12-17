import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../bloc/cylinderlist_bloc.dart';
import '../common/common.dart';

class CylinderListScreen extends StatelessWidget {
  const CylinderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Cylinders'),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Add new cylinder',
          onPressed: () => context.goNamed(AppRouteName.cylindersNew),
        ),
      ],
      body: BlocBuilder<CylinderListBloc, CylinderListState>(
        builder: (context, state) {
          if (state is CylinderListInitial || state is CylinderListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CylinderListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error loading cylinders', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(state.message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          if (state is CylinderListLoaded) {
            final cylinders = state.cylinders;

            if (cylinders.isEmpty) {
              return const Center(child: Text('No cylinders yet. Tap + to add one.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: cylinders.length,
              itemBuilder: (context, index) {
                final cylinder = cylinders[index];
                final sizeStr = cylinder.size != null ? '${cylinder.size!.toStringAsFixed(1)} L' : null;
                final wpStr = cylinder.workpressure != null ? '${cylinder.workpressure!.toInt()} bar' : null;
                final specs = [sizeStr, wpStr].where((s) => s != null).join(' / ');

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.propane_tank),
                    title: Text(cylinder.description ?? 'Cylinder #${cylinder.id}'),
                    subtitle: specs.isNotEmpty ? Text(specs) : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.goNamed(
                      AppRouteName.cylindersDetails,
                      pathParameters: {'cylinderID': cylinder.id.toString()},
                    ),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
