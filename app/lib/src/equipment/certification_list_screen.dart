import 'package:btproto/btproto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import '../app_routes.dart';
import '../common/common.dart';
import '../providers/storage_provider.dart';
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
                  clipBehavior: Clip.antiAlias,
                  child: CertificationTile(
                    certification: cert,
                    trailing: const Icon(Icons.chevron_right),
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

    final badges = <Widget>[];
    if (cert.hasExpires()) {
      final expiry = cert.expires.toDateTime();
      final now = DateTime.now();
      if (expiry.isBefore(now)) {
        badges.add(TextBadge(label: 'Expired', backgroundColor: cs.errorContainer, textColor: cs.onErrorContainer));
      } else if (expiry.isBefore(now.add(const Duration(days: 90)))) {
        badges.add(TextBadge(label: 'Expiring', backgroundColor: cs.tertiaryContainer, textColor: cs.onTertiaryContainer));
      }
    }

    return InkWell(
      onTap: onTap,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cert.cardFrontId.isNotEmpty)
              AspectRatio(
                aspectRatio: certificationCardAspectRatio,
                child: _FrontThumbnail(photoId: cert.cardFrontId),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      spacing: 8,
                      children: [
                        Flexible(child: Text(title)),
                        ...badges,
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (trailing != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Center(child: trailing),
              ),
          ],
        ),
      ),
    );
  }

  static String _title(Certification cert) {
    final agency = cert.agency.trim();
    final name = cert.name.trim();
    if (agency.isNotEmpty && name.isNotEmpty) return '$name ($agency)';
    if (name.isNotEmpty) return name;
    if (agency.isNotEmpty) return agency;
    return 'Certification #${cert.id}';
  }
}

class _FrontThumbnail extends StatefulWidget {
  final String photoId;

  const _FrontThumbnail({required this.photoId});

  @override
  State<_FrontThumbnail> createState() => _FrontThumbnailState();
}

class _FrontThumbnailState extends State<_FrontThumbnail> {
  Uint8List? _bytes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(_FrontThumbnail old) {
    super.didUpdateWidget(old);
    if (old.photoId != widget.photoId) {
      _bytes = null;
      _load();
    }
  }

  Future<void> _load() async {
    final data = await StorageProvider.instance.store.photos.readThumbnail(widget.photoId);
    if (!mounted) return;
    setState(() => _bytes = data);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // DecorationImage rather than Image.memory: the latter reports the photo's
    // natural pixel size as its intrinsic dimensions, which makes the
    // enclosing IntrinsicHeight blow the row up to the original photo size.
    // DecorationImage paints into whatever box the parent provides without
    // contributing to intrinsic sizing.
    if (_bytes != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(image: MemoryImage(_bytes!), fit: BoxFit.cover),
        ),
      );
    }
    return Container(
      color: cs.surfaceContainerHighest,
      child: Icon(Icons.image_outlined, size: 20, color: cs.onSurfaceVariant),
    );
  }
}
