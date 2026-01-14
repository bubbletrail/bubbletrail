import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
        IconButton(icon: const Icon(FluentIcons.add_24_regular), tooltip: 'Add new cylinder', onPressed: () => context.goNamed(AppRouteName.cylindersNew)),
      ],
      body: BlocBuilder<CylinderListBloc, CylinderListState>(
        builder: (context, state) {
          if (state is CylinderListInitial || state is CylinderListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CylinderListLoaded) {
            final cylinders = state.cylinders;

            if (cylinders.isEmpty) {
              return const EmptyStateWidget(message: 'No cylinders yet. Tap + to add one.', icon: FluentIcons.beaker_24_regular);
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
                    trailing: const Icon(FluentIcons.chevron_right_24_regular, size: 16),
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
