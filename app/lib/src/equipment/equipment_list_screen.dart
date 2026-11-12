import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
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
      title: Text(context.l10n.otherEquipment),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: context.l10n.addNewEquipment, onPressed: () => context.goNamed(AppRouteName.equipmentNew))],
      body: BlocBuilder<EquipmentListBloc, EquipmentListState>(
        builder: (context, state) {
          if (state is EquipmentListInitial || state is EquipmentListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is EquipmentListLoaded) {
            final equipment = state.visibleEquipment;
            final hasArchived = state.equipment.any((e) => e.archived);

            if (state.equipment.isEmpty) {
              return EmptyStateWidget(message: context.l10n.noEquipmentYetTapToAddOne, icon: Icons.inventory_2_outlined);
            }

            return Column(
              children: [
                if (hasArchived)
                  SwitchListTile(
                    title: Text(context.l10n.showArchived),
                    value: state.showArchived,
                    onChanged: (_) => context.read<EquipmentListBloc>().add(EquipmentListEvent.toggleShowArchived()),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: const .all(16),
                    itemCount: equipment.length,
                    itemBuilder: (context, index) {
                      final item = equipment[index];
                      return Card(
                        child: EquipmentListTile(
                          equipment: item,
                          diveCount: state.diveCountByEquipmentId[item.id] ?? 0,
                          diveSeconds: state.diveSecondsByEquipmentId[item.id] ?? 0,
                          onTap: (item) => context.goNamed(AppRouteName.equipmentDetails, pathParameters: {'equipmentID': item.id}),
                          trailing: Icons.chevron_right,
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }

          return Center(child: Text(context.l10n.unknownState));
        },
      ),
    );
  }
}
