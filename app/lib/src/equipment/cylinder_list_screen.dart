import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import 'cylinder_list_bloc.dart';
import '../common/common.dart';

class CylinderListScreen extends StatelessWidget {
  const CylinderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Cylinders'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new cylinder', onPressed: () => context.goNamed(AppRouteName.cylindersNew))],
      body: BlocBuilder<CylinderListBloc, CylinderListState>(
        builder: (context, state) {
          if (state is CylinderListInitial || state is CylinderListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CylinderListLoaded) {
            final cylinders = state.cylinders;

            if (cylinders.isEmpty) {
              return const EmptyStateWidget(message: 'No cylinders yet. Tap + to add one.', icon: Icons.science_outlined);
            }

            return ListView.builder(
              padding: const .all(16),
              itemCount: cylinders.length,
              itemBuilder: (context, index) {
                final cylinder = cylinders[index];
                return Card(
                  child: CylinderTile(
                    index: index,
                    description: cylinder.description.isNotEmpty ? cylinder.description : 'Cylinder #${cylinder.id}',
                    volumeL: cylinder.volumeL,
                    workingPressureBar: cylinder.workingPressureBar,
                    volumeCuft: cylinder.volumeCuft,
                    workingPressurePsi: cylinder.workingPressurePsi,
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.goNamed(AppRouteName.cylindersDetails, pathParameters: {'cylinderID': cylinder.id.toString()}),
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
