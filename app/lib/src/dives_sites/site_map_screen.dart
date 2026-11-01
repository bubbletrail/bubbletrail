import 'package:btl10n/btl10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/common.dart';
import 'dive_list_bloc.dart';
import 'site_map.dart';

class SiteMapScreen extends StatelessWidget {
  const SiteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(context.l10n.siteMap),
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListLoaded) {
            final sites = state.sites;

            if (sites.isEmpty) {
              return EmptyStateWidget(message: context.l10n.noDiveSitesYet, icon: Icons.location_on_outlined);
            }

            return AllSitesMap(sites: sites);
          }

          return Center(child: Text(context.l10n.unknownState));
        },
      ),
    );
  }
}
