import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';

class DiveSiteListScreen extends StatelessWidget {
  const DiveSiteListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Dive Sites'),
      body: BlocBuilder<DiveListBloc, DiveListState>(
        builder: (context, state) {
          if (state is DiveListInitial || state is DiveListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DiveListError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text('Error loading dive sites', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(state.message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          if (state is DiveListLoaded) {
            final diveSites = state.diveSites;

            if (diveSites.isEmpty) {
              return const Center(child: Text('No dive sites yet.'));
            }

            final t = Theme.of(context);

            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Country')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Body of Water')),
                    DataColumn(label: Text('Difficulty')),
                    DataColumn(label: Text('# Dives')),
                  ],
                  dividerThickness: 0,
                  dataRowMinHeight: t.visualDensity == VisualDensity.compact ? 24 : 32,
                  dataRowMaxHeight: t.visualDensity == VisualDensity.compact ? 32 : 48,
                  showCheckboxColumn: false,
                  rows: diveSites.map((site) {
                    final divesAtSite = state.dives.where((d) => d.divesiteid == site.uuid.trim()).length;
                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          context.goNamed(AppRouteName.sitesDetails, pathParameters: {'siteID': site.uuid});
                        }
                      },
                      cells: [
                        DataCell(Text(site.name)),
                        DataCell(Text(site.country ?? '-')),
                        DataCell(Text(site.location ?? '-')),
                        DataCell(Text(site.bodyOfWater ?? '-')),
                        DataCell(Text(site.difficulty ?? '-')),
                        DataCell(Text(divesAtSite.toString())),
                      ],
                    );
                  }).toList(),
                ),
              ),
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
