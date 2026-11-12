import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/common.dart';

class EquipmentScreen extends StatelessWidget {
  const EquipmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.equipment),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTileCard(
            title: context.l10n.equipment,
            subtitle: context.l10n.bcdsRegulatorsWetsuitsEtc,
            onTap: () => context.goNamed(AppRouteName.equipmentList),
          ),
          const SizedBox(height: 8),
          ListTileCard(
            title: context.l10n.cylinderTypes,
            subtitle: context.l10n.availableCylinderTypesAndDefaults,
            onTap: () => context.goNamed(AppRouteName.cylinders),
          ),
          const SizedBox(height: 8),
          ListTileCard(
            title: context.l10n.certifications,
            subtitle: context.l10n.diverCertificationCards,
            onTap: () => context.goNamed(AppRouteName.certifications),
          ),
        ],
      ),
    );
  }
}
