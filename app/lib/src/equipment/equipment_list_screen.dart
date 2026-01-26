import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/common.dart';
import 'equipment_list_bloc.dart';

class EquipmentListScreen extends StatelessWidget {
  const EquipmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Other Equipment'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new equipment', onPressed: () => context.goNamed(AppRouteName.equipmentNew))],
      body: BlocBuilder<EquipmentListBloc, EquipmentListState>(
        builder: (context, state) {
          if (state is EquipmentListInitial || state is EquipmentListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EquipmentListLoaded) {
            final equipment = state.equipment;

            if (equipment.isEmpty) {
              return const EmptyStateWidget(message: 'No equipment yet. Tap + to add one.', icon: Icons.inventory_2_outlined);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: equipment.length,
              itemBuilder: (context, index) {
                final item = equipment[index];
                return Card(
                  child: EquipmentListTile(
                    equipment: item,
                    onTap: (item) => context.goNamed(AppRouteName.equipmentDetails, pathParameters: {'equipmentID': item.id}),
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
