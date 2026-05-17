import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import 'certification_details_bloc.dart';
import 'certification_photo_widgets.dart';

class CertificationDetailsScreen extends StatelessWidget {
  const CertificationDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CertificationDetailsBloc, CertificationDetailsState>(
      listener: (context, state) {
        if (state is CertificationDetailsClosed) context.pop();
      },
      builder: (context, state) {
        if (state is! CertificationDetailsLoaded) return const Placeholder();
        final cert = state.certification;
        return ScreenScaffold(
          title: Text(_title(cert)),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => context.goNamed(AppRouteName.certificationsDetailsEdit, pathParameters: {'certificationID': cert.id}),
            ),
            _popupMenuActions(context, cert),
          ],
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < narrowLayoutBreakpoint;
              final hasFront = cert.cardFrontId.isNotEmpty;
              final hasBack = cert.cardBackId.isNotEmpty;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (hasFront || hasBack)
                      _twoColumn(
                        isNarrow: isNarrow,
                        first: hasFront ? _PhotoView(label: 'Card front', photoId: cert.cardFrontId) : const SizedBox.shrink(),
                        second: hasBack ? _PhotoView(label: 'Card back', photoId: cert.cardBackId) : const SizedBox.shrink(),
                      ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: DataCardColumn(
                          children: [
                            if (cert.agency.isNotEmpty) ColumnRow(label: 'Agency', child: Text(cert.agency)),
                            if (cert.name.isNotEmpty) ColumnRow(label: 'Name', child: Text(cert.name)),
                            if (cert.number.isNotEmpty) ColumnRow(label: 'Number', child: Text(cert.number)),
                            if (cert.instructorName.isNotEmpty) ColumnRow(label: 'Instructor name', child: Text(cert.instructorName)),
                            if (cert.instructorNumber.isNotEmpty) ColumnRow(label: 'Instructor number', child: Text(cert.instructorNumber)),
                            if (cert.hasGranted()) ColumnRow(label: 'Granted', child: Text(DateFormat.yMMMd().format(cert.granted.toDateTime()))),
                            if (cert.hasExpires())
                              ColumnRow(
                                label: 'Expires',
                                child: _ExpiresText(expires: cert.expires.toDateTime()),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  static String _title(Certification cert) {
    final agency = cert.agency.trim();
    final name = cert.name.trim();
    if (agency.isNotEmpty && name.isNotEmpty) return '$agency – $name';
    if (name.isNotEmpty) return name;
    if (agency.isNotEmpty) return agency;
    return 'Certification';
  }

  Widget _twoColumn({required bool isNarrow, required Widget first, required Widget second}) {
    if (isNarrow) {
      return Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.stretch, children: [first, second]);
    }
    return Row(
      spacing: 16,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        Expanded(child: second),
      ],
    );
  }

  PopupMenuButton<String> _popupMenuActions(BuildContext context, Certification cert) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Certification'),
              content: const Text('Are you sure you want to delete this certification?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            context.read<CertificationDetailsBloc>().add(CertificationDetailsEvent.deleteAndClose(cert.id));
          }
        }
      },
      itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete certification'))],
    );
  }
}

class _PhotoView extends StatelessWidget {
  final String label;
  final String photoId;

  const _PhotoView({required this.label, required this.photoId});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            AspectRatio(
              aspectRatio: certificationCardAspectRatio,
              child: InkWell(
                onTap: () => showFullscreenPhoto(context, label: label, photoId: photoId),
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    border: Border.all(color: cs.outline),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: StoredPhoto(photoId: photoId),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiresText extends StatelessWidget {
  final DateTime expires;

  const _ExpiresText({required this.expires});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final formatted = DateFormat.yMMMd().format(expires);
    Widget? badge;
    if (expires.isBefore(now)) {
      badge = TextBadge(label: 'Expired', backgroundColor: cs.errorContainer, textColor: cs.onErrorContainer);
    } else if (expires.isBefore(now.add(const Duration(days: 90)))) {
      badge = TextBadge(label: 'Expiring', backgroundColor: cs.tertiaryContainer, textColor: cs.onTertiaryContainer);
    }
    if (badge == null) return Text(formatted);
    return Row(mainAxisSize: MainAxisSize.min, spacing: 8, children: [Text(formatted), badge]);
  }
}
