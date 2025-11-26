import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../common/divetable_widget.dart';
import '../bloc/divelist_bloc.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dives'),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: null)],
      ),
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
                  Text('Error loading dives', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(state.message, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
                ],
              ),
            );
          }

          if (state is DiveListLoaded) {
            final dives = state.dives;
            final diveSites = state.diveSites;

            if (dives.isEmpty) {
              return const Center(child: Text('No dives yet. Add your first dive!'));
            }

            return DiveTableWidget(dives: dives, diveSites: diveSites, showSiteColumn: true);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}
