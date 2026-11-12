import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import '../common/no_fly.dart';
import 'dive_list_bloc.dart';
import 'dive_table.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(title: Text(context.l10n.dives), actions: [NoFlyIndicator(), _addAction(context)], body: _body());
  }

  Widget _addAction(BuildContext context) {
    if (!platformSupportsConnect) {
      return IconButton(icon: const Icon(Icons.add), tooltip: context.l10n.addNewDive, onPressed: () => context.goNamed(AppRouteName.divesNew));
    }

    return PopupMenuButton<String>(
      tooltip: context.l10n.addNewDive,
      icon: const Icon(Icons.add),
      onSelected: (value) {
        if (value == 'download') {
          context.goNamed(AppRouteName.connect);
        } else if (value == 'manual') {
          context.goNamed(AppRouteName.divesNew);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'download',
          child: Row(spacing: 12, children: [Icon(Icons.download), Text(context.l10n.downloadFromComputer)]),
        ),
        PopupMenuItem(
          value: 'manual',
          child: Row(spacing: 12, children: [Icon(Icons.edit), Text(context.l10n.enterManually)]),
        ),
      ],
    );
  }

  BlocBuilder<DiveListBloc, DiveListState> _body() {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is DiveListInitial || state is DiveListLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DiveListLoaded) {
          final dives = state.dives;

          if (dives.isEmpty) {
            return EmptyStateWidget(message: context.l10n.noDivesYetAddYourFirstDive, icon: Icons.water_drop_outlined);
          }

          return DiveTable(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: true, enableFilters: true);
        }

        return Center(child: Text(context.l10n.unknownState));
      },
    );
  }
}
