import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app_routes.dart';
import '../common/common.dart';
import 'certification_list_bloc.dart';

class CertificationListScreen extends StatelessWidget {
  const CertificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: const Text('Certifications'),
      actions: [IconButton(icon: const Icon(Icons.add), tooltip: 'Add new certification', onPressed: () => context.goNamed(AppRouteName.certificationsNew))],
      body: BlocBuilder<CertificationListBloc, CertificationListState>(
        builder: (context, state) {
          if (state is CertificationListInitial || state is CertificationListLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CertificationListLoaded) {
            final certs = state.certifications;

            if (certs.isEmpty) {
              return const EmptyStateWidget(message: 'No certifications yet. Tap + to add one.', icon: Icons.card_membership_outlined);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certs.length,
              itemBuilder: (context, index) {
                final cert = certs[index];
                return Card(
                  child: CertificationTile(
                    certification: cert,
                    trailing: const Icon(Icons.chevron_right, size: 16),
                    onTap: () => context.goNamed(AppRouteName.certificationsDetails, pathParameters: {'certificationID': cert.id}),
                  ),
                );
              },
            );
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class CertificationTile extends StatelessWidget {
  final Certification certification;
  final Widget? trailing;
  final VoidCallback? onTap;

  const CertificationTile({super.key, required this.certification, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cert = certification;

    final title = _title(cert);
    final details = <Widget>[];

    if (cert.certificationNumber.isNotEmpty) {
      details.add(LabeledChip(label: 'Number', child: Text(cert.certificationNumber)));
    }
    if (cert.hasGranted()) {
      details.add(LabeledChip(label: 'Granted', child: Text(DateFormat.yMMMd().format(cert.granted.toDateTime()))));
    }
    if (cert.hasExpires()) {
      details.add(LabeledChip(label: 'Expires', child: Text(DateFormat.yMMMd().format(cert.expires.toDateTime()))));
    }
    if (cert.instructorName.isNotEmpty) {
      details.add(LabeledChip(label: 'Instructor', child: Text(cert.instructorName)));
    }

    final badges = <Widget>[];
    if (cert.hasExpires()) {
      final expiry = cert.expires.toDateTime();
      final now = DateTime.now();
      if (expiry.isBefore(now)) {
        badges.add(TextBadge(label: 'Expired', backgroundColor: cs.errorContainer, textColor: cs.onErrorContainer));
      } else if (expiry.isBefore(now.add(const Duration(days: 60)))) {
        badges.add(TextBadge(label: 'Expiring', backgroundColor: cs.tertiaryContainer, textColor: cs.onTertiaryContainer));
      }
    }

    return ListTile(
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Row(
          spacing: 8,
          children: [
            Flexible(child: Text(title)),
            ...badges,
          ],
        ),
      ),
      subtitle: details.isEmpty ? null : Wrap(spacing: 8, runSpacing: 8, children: details),
      trailing: trailing,
      onTap: onTap,
    );
  }

  static String _title(Certification cert) {
    final agency = cert.agency.trim();
    final name = cert.certificationName.trim();
    if (agency.isNotEmpty && name.isNotEmpty) return '$agency – $name';
    if (name.isNotEmpty) return name;
    if (agency.isNotEmpty) return agency;
    return 'Certification #${cert.id}';
  }
}
