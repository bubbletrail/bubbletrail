import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_routes.dart';
import 'equipment_list_bloc.dart';
import '../common/common.dart';

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
                  child: ListTile(
                    leading: _equipmentIcon(item.type),
                    title: Text(_equipmentTitle(item)),
                    subtitle: _equipmentSubtitle(item),
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.goNamed(AppRouteName.equipmentDetails, pathParameters: {'equipmentID': item.id}),
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

  Widget _equipmentIcon(String type) {
    final iconData = switch (type.toLowerCase()) {
      'bcd' => Icons.shield_outlined,
      'regulator' => Icons.air,
      'wetsuit' || 'drysuit' => Icons.checkroom,
      'mask' => Icons.visibility,
      'fins' => Icons.flutter_dash,
      'computer' => Icons.watch,
      'light' || 'torch' => Icons.flashlight_on,
      'camera' => Icons.camera_alt,
      _ => Icons.inventory_2_outlined,
    };
    return Icon(iconData);
  }

  String _equipmentTitle(Equipment item) {
    if (item.name.isNotEmpty) {
      return item.name;
    }
    if (item.manufacturer.isNotEmpty && item.type.isNotEmpty) {
      return '${item.manufacturer} ${item.type}';
    }
    if (item.type.isNotEmpty) {
      return item.type;
    }
    return 'Equipment #${item.id}';
  }

  Widget? _equipmentSubtitle(Equipment item) {
    final parts = <String>[];
    if (item.type.isNotEmpty && item.name.isNotEmpty) {
      parts.add(item.type);
    }
    if (item.manufacturer.isNotEmpty && item.name.isNotEmpty) {
      parts.add(item.manufacturer);
    }
    if (item.hasNextService()) {
      final date = item.nextService.toDateTime();
      final formatted = DateFormat.yMMMd().format(date);
      final isOverdue = date.isBefore(DateTime.now());
      parts.add(isOverdue ? 'Service overdue ($formatted)' : 'Next service: $formatted');
    }
    if (parts.isEmpty) return null;
    return Text(parts.join(' \u2022 '));
  }
}
