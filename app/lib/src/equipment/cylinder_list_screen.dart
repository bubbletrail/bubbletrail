import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../common/common.dart';
import 'cylinder_list_bloc.dart';

class CylinderListScreen extends StatelessWidget {
  const CylinderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.cylinderTypes),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: context.l10n.addNewCylinderType, onPressed: () => context.goNamed(AppRouteName.cylindersNew))],
      body: BlocBuilder<CylinderListBloc, CylinderListState>(
        builder: (context, state) {
          if (state is CylinderListInitial || state is CylinderListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CylinderListLoaded) {
            final cylinders = state.cylinders;

            if (cylinders.isEmpty) {
              return EmptyStateWidget(message: context.l10n.noCylinderTypesYetTapToAddOne, icon: Icons.science_outlined);
            }

            return ListView.builder(
              padding: const .all(16),
              itemCount: cylinders.length,
              itemBuilder: (context, index) {
                final cylinder = cylinders[index];
                return Card(
                  child: CylinderTile(
                    index: index,
                    description: cylinder.description.isNotEmpty ? cylinder.description : context.l10n.cylinderType(cylinder.id),
                    volumeL: cylinder.volumeL,
                    workingPressureBar: cylinder.workingPressureBar,
                    volumeCuft: cylinder.volumeCuft,
                    workingPressurePsi: cylinder.workingPressurePsi,
                    defaultForBackgas: cylinder.defaultForBackgas,
                    defaultForDeepDeco: cylinder.defaultForDeepDeco,
                    defaultForShallowDeco: cylinder.defaultForShallowDeco,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.goNamed(AppRouteName.cylindersDetails, pathParameters: {'cylinderID': cylinder.id.toString()}),
                  ),
                );
              },
            );
          }

          return Center(child: Text(context.l10n.unknownState));
        },
      ),
    );
  }
}
