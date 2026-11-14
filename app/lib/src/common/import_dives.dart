import 'package:btl10n/btl10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

import '../app_metadata.dart';
import '../dives_sites/dive_list_bloc.dart';

Future<void> importDives(BuildContext context) async {
  final file = await FilePicker.pickFile(
    type: platformIsMobile ? FileType.any : FileType.custom,
    allowedExtensions: platformIsMobile ? null : ['ssrf', 'xml', 'uddf', 'json'],
  );
  if (file?.path == null || !context.mounted) return;
  context.read<DiveListBloc>().add(DiveListEvent.importDives(file!.path!));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.importingDives)));
}
