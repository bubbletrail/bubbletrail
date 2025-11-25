import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'divelist_bloc.dart';
import 'divedetail_widget.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dive Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Add new dive
            },
          ),
        ],
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
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
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

            if (dives.isEmpty) {
              return const Center(child: Text('No dives yet. Add your first dive!'));
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Dive #')),
                    DataColumn(label: Text('Date')),
                    DataColumn(label: Text('Time')),
                    DataColumn(label: Text('Max Depth (m)')),
                    DataColumn(label: Text('Duration')),
                  ],
                  rows: dives.map((dive) {
                    final maxDepth = dive.divecomputers.isNotEmpty ? dive.divecomputers[0].maxDepth : 0.0;

                    return DataRow(
                      onSelectChanged: (selected) {
                        if (selected == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DiveDetailScreen(dive: dive),
                            ),
                          );
                        }
                      },
                      cells: [
                        DataCell(Text(dive.number.toString())),
                        DataCell(Text(DateFormat('yyyy-MM-dd').format(dive.start))),
                        DataCell(Text(DateFormat('HH:mm').format(dive.start))),
                        DataCell(Text(maxDepth.toStringAsFixed(1))),
                        DataCell(Text(_formatDuration(dive.duration))),
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

  String _formatDuration(double seconds) {
    final minutes = (seconds / 60).floor();
    return '$minutes min';
  }
}
