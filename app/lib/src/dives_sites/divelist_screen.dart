import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import 'dive_list_bloc.dart';
import '../common/common.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dives'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new dive', onPressed: () => context.goNamed(AppRouteName.divesNew))],
      body: _body(),
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

          return DiveTableWidget(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: true);
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }
}
