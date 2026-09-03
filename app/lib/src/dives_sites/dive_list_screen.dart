import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import 'dive_list_bloc.dart';
import '../common/common.dart';
import 'dive_table.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(title: const Text('Dives'), actions: [_addAction(context)], body: _body());
  }

  Widget _addAction(BuildContext context) {
    if (!platformSupportsConnect) {
      return IconButton(icon: const Icon(Icons.add), tooltip: 'Add new dive', onPressed: () => context.goNamed(AppRouteName.divesNew));
    }

    return PopupMenuButton<String>(
      tooltip: 'Add new dive',
      icon: const Icon(Icons.add),
      onSelected: (value) {
        if (value == 'download') {
          context.goNamed(AppRouteName.connect);
        } else if (value == 'manual') {
          context.goNamed(AppRouteName.divesNew);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'download',
          child: Row(spacing: 12, children: [Icon(Icons.download), Text('Download from computer')]),
        ),
        const PopupMenuItem(
          value: 'manual',
          child: Row(spacing: 12, children: [Icon(Icons.edit), Text('Enter manually')]),
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
            return const EmptyStateWidget(message: 'No dives yet. Add your first dive!', icon: Icons.water_drop_outlined);
          }

          return DiveTable(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: true);
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }
}
