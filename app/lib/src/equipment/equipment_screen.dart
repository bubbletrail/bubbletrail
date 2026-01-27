import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/common.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Equipment'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTileCard(title: 'Equipment', subtitle: 'BCDs, regulators, wetsuits, etc.', onTap: () => context.goNamed(AppRouteName.equipmentList)),
          const SizedBox(height: 8),
          ListTileCard(title: 'Cylinders', subtitle: 'Available cylinder types and defaults', onTap: () => context.goNamed(AppRouteName.cylinders)),
        ],
      ),
    );
  }
}
