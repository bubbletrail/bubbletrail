import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_routes.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';

class DiveListScreen extends StatelessWidget {
  const DiveListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(title: const Text('Dives'), actions: _actions(context), body: _body());
  }

  List<Widget> _actions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.file_upload),
        tooltip: 'Import SSRF file',
        onPressed: () async {
          final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['ssrf', 'xml']);
          if (result != null && result.files.single.path != null) {
            if (context.mounted) {
              context.read<DiveListBloc>().add(ImportDives(result.files.single.path!));
            }
          }
        },
      ),
      IconButton(
        icon: const Icon(Icons.add),
        tooltip: 'Add new dive',
        onPressed: () {
          context.goNamed(AppRouteName.divesNew);
        },
      ),
    ];
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
            return const EmptyStateWidget(message: 'No dives yet. Add your first dive!', icon: Icons.scuba_diving);
          }

          return DiveTableWidget(dives: dives, sitesByUuid: state.sitesByUuid, showSiteColumn: true);
        }

        return const Center(child: Text('Unknown state'));
      },
    );
  }
}
