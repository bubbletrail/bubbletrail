import 'dart:async';
import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;

import '../app_metadata.dart';
import '../common/common.dart';
import '../providers/storage_provider.dart';
import 'certification_details_bloc.dart';

final _log = Logger('certification_edit_screen.dart');

// Standard credit card aspect ratio is ~1.586:1, but we use 16:10 (1.6:1) as
// a close-enough visual approximation that lines up with common layouts.
const _cardAspectRatio = 16 / 10;

const double _narrowLayoutBreakpoint = 600;

class CertificationEditScreen extends StatefulWidget {
  const CertificationEditScreen({super.key});

  @override
  State<CertificationEditScreen> createState() => _CertificationEditScreenState();
}

class _CertificationEditScreenState extends State<CertificationEditScreen> {
  late final Certification _original;
  late final bool _isNew;

  late final TextEditingController _agencyController;
  late final TextEditingController _nameController;
  late final TextEditingController _numberController;
  late final TextEditingController _instructorNameController;
  late final TextEditingController _instructorNumberController;

  DateTime? _granted;
  DateTime? _expires;

  // Photo state: either an existing photo ID from the store, or freshly picked
  // bytes pending save, or null. _clear marks the user explicitly removing an
  // existing photo without replacing it.
  String _frontPhotoId = '';
  String _backPhotoId = '';
  Uint8List? _newFront;
  Uint8List? _newBack;
  bool _clearFront = false;
  bool _clearBack = false;

  bool _validationFailed = false;

  static const _agencies = ['PADI', 'SSI', 'NAUI', 'GUE', 'TDI', 'SDI', 'BSAC', 'CMAS', 'RAID', 'IANTD'];

  @override
  void initState() {
    super.initState();
    final state = context.read<CertificationDetailsBloc>().state as CertificationDetailsLoaded;
    _original = state.certification;
    _isNew = state.isNew;

    _agencyController = TextEditingController(text: _original.agency);
    _nameController = TextEditingController(text: _original.name);
    _numberController = TextEditingController(text: _original.number);
    _instructorNameController = TextEditingController(text: _original.instructorName);
    _instructorNumberController = TextEditingController(text: _original.instructorNumber);

    _granted = _original.hasGranted() ? _original.granted.toDateTime() : null;
    _expires = _original.hasExpires() ? _original.expires.toDateTime() : null;

    _frontPhotoId = _original.cardFrontId;
    _backPhotoId = _original.cardBackId;
  }

  @override
  void dispose() {
    _agencyController.dispose();
    _nameController.dispose();
    _numberController.dispose();
    _instructorNameController.dispose();
    _instructorNumberController.dispose();
    super.dispose();
  }

  bool _validate() {
    final ok = _agencyController.text.trim().isNotEmpty && _nameController.text.trim().isNotEmpty && _numberController.text.trim().isNotEmpty;
    if (!ok) setState(() => _validationFailed = true);
    return ok;
  }

  void _save() {
    if (!_validate()) return;

    final updated = _original.rebuild((b) {
      b.agency = _agencyController.text.trim();
      b.name = _nameController.text.trim();
      b.number = _numberController.text.trim();

      final instructorName = _instructorNameController.text.trim();
      final instructorNumber = _instructorNumberController.text.trim();
      if (instructorName.isEmpty) {
        b.clearInstructorName();
      } else {
        b.instructorName = instructorName;
      }
      if (instructorNumber.isEmpty) {
        b.clearInstructorNumber();
      } else {
        b.instructorNumber = instructorNumber;
      }

      if (_granted != null) {
        b.granted = proto.Timestamp.fromDateTime(_granted!);
      } else {
        b.clearGranted();
      }
      if (_expires != null) {
        b.expires = proto.Timestamp.fromDateTime(_expires!);
      } else {
        b.clearExpires();
      }
    });

    context.read<CertificationDetailsBloc>().add(
      CertificationDetailsEvent.updateAndClose(updated, newCardFront: _newFront, newCardBack: _newBack, clearCardFront: _clearFront, clearCardBack: _clearBack),
    );
  }

  void _cancel() {
    context.read<CertificationDetailsBloc>().add(const CertificationDetailsEvent.close());
  }

  Future<void> _selectGranted() async {
    final date = await showDatePicker(context: context, initialDate: _granted ?? DateTime.now(), firstDate: DateTime(1960), lastDate: DateTime.now());
    if (date != null) setState(() => _granted = _asUtcDate(date));
  }

  Future<void> _selectExpires() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _expires ?? DateTime.now().add(const Duration(days: 365 * 2)),
      firstDate: DateTime(1960),
      lastDate: DateTime.now().add(const Duration(days: 365 * 20)),
    );
    if (date != null) setState(() => _expires = _asUtcDate(date));
  }

  // showDatePicker returns midnight in local time; we store calendar dates as
  // UTC midnight so the displayed Y/M/D matches the user's selection regardless
  // of timezone (proto Timestamp.fromDateTime / toDateTime go via UTC).
  DateTime _asUtcDate(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<Uint8List?> _pickImage() async {
    final picker = ImagePicker();
    final source = await _chooseSource();
    if (source == null) return null;
    try {
      final file = await picker.pickImage(source: source, imageQuality: 85);
      if (file == null) return null;
      return await file.readAsBytes();
    } catch (e) {
      _log.warning('failed to pick image', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
      return null;
    }
  }

  Future<ImageSource?> _chooseSource() async {
    if (!platformIsMobile) return ImageSource.gallery;
    return showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFront() async {
    final bytes = await _pickImage();
    if (bytes == null) return;
    setState(() {
      _newFront = bytes;
      _clearFront = false;
    });
  }

  Future<void> _pickBack() async {
    final bytes = await _pickImage();
    if (bytes == null) return;
    setState(() {
      _newBack = bytes;
      _clearBack = false;
    });
  }

  void _removeFront() {
    setState(() {
      _newFront = null;
      _clearFront = _frontPhotoId.isNotEmpty;
    });
  }

  void _removeBack() {
    setState(() {
      _newBack = null;
      _clearBack = _backPhotoId.isNotEmpty;
    });
  }

  PopupMenuButton<String> _popupMenuActions() {
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
          if (confirmed == true && mounted) {
            context.read<CertificationDetailsBloc>().add(CertificationDetailsEvent.deleteAndClose(_original.id));
          }
        }
      },
      itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete certification'))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _save();
      },
      child: BlocListener<CertificationDetailsBloc, CertificationDetailsState>(
        listener: (context, state) {
          if (state is CertificationDetailsClosed) context.pop();
        },
        child: ScreenScaffold(
          title: Text(_isNew ? 'New Certification' : 'Edit Certification'),
          actions: [
            if (!_isNew) _popupMenuActions(),
            IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes'),
          ],
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < _narrowLayoutBreakpoint;
              final instructorName = TextField(
                controller: _instructorNameController,
                decoration: const InputDecoration(labelText: 'Instructor Name', border: OutlineInputBorder()),
              );
              final instructorNumber = TextField(
                controller: _instructorNumberController,
                decoration: const InputDecoration(labelText: 'Instructor Number', border: OutlineInputBorder()),
              );
              final granted = _buildDateField('Granted', _granted, _selectGranted, () => setState(() => _granted = null));
              final expires = _buildDateField('Expires', _expires, _selectExpires, () => setState(() => _expires = null));
              final cardFront = _PhotoCard(
                label: 'Card front',
                photoId: _frontPhotoId,
                newBytes: _newFront,
                cleared: _clearFront,
                onPick: _pickFront,
                onRemove: _removeFront,
              );
              final cardBack = _PhotoCard(
                label: 'Card back',
                photoId: _backPhotoId,
                newBytes: _newBack,
                cleared: _clearBack,
                onPick: _pickBack,
                onRemove: _removeBack,
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAgencyField(),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Certification Name *',
                        border: const OutlineInputBorder(),
                        hintText: 'e.g., Open Water Diver',
                        errorText: _validationFailed && _nameController.text.trim().isEmpty ? 'Required' : null,
                      ),
                      onChanged: (_) {
                        if (_validationFailed) setState(() {});
                      },
                    ),
                    TextField(
                      controller: _numberController,
                      decoration: InputDecoration(
                        labelText: 'Certification Number *',
                        border: const OutlineInputBorder(),
                        errorText: _validationFailed && _numberController.text.trim().isEmpty ? 'Required' : null,
                      ),
                      onChanged: (_) {
                        if (_validationFailed) setState(() {});
                      },
                    ),
                    _twoColumn(isNarrow: isNarrow, first: instructorName, second: instructorNumber),
                    _twoColumn(isNarrow: isNarrow, first: granted, second: expires),
                    _twoColumn(isNarrow: isNarrow, first: cardFront, second: cardBack, crossAxisStart: true),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAgencyField() {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _agencyController.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return _agencies;
        return _agencies.where((a) => a.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) => _agencyController.text = selection,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Agency *',
            border: const OutlineInputBorder(),
            hintText: 'e.g., PADI, SSI',
            errorText: _validationFailed && controller.text.trim().isEmpty ? 'Required' : null,
          ),
          onChanged: (value) {
            _agencyController.text = value;
            if (_validationFailed) setState(() {});
          },
        );
      },
    );
  }

  Widget _twoColumn({required bool isNarrow, required Widget first, required Widget second, bool crossAxisStart = false}) {
    if (isNarrow) {
      return Column(spacing: 16, crossAxisAlignment: CrossAxisAlignment.stretch, children: [first, second]);
    }
    return Row(
      spacing: 16,
      crossAxisAlignment: crossAxisStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(child: first),
        Expanded(child: second),
      ],
    );
  }

  Widget _buildDateField(String label, DateTime? value, VoidCallback onTap, VoidCallback onClear) {
    final formatted = value != null ? DateFormat.yMMMd().format(value) : null;
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear) : null,
        ),
        child: Text(formatted ?? 'Not set', style: formatted == null ? TextStyle(color: Theme.of(context).hintColor) : null),
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String label;
  final String photoId;
  final Uint8List? newBytes;
  final bool cleared;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoCard({required this.label, required this.photoId, required this.newBytes, required this.cleared, required this.onPick, required this.onRemove});

  bool get _hasContent => newBytes != null || (!cleared && photoId.isNotEmpty);

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
            Row(
              children: [
                Expanded(child: Text(label, style: Theme.of(context).textTheme.titleMedium)),
                if (_hasContent) ...[
                  IconButton(icon: const Icon(Icons.refresh), tooltip: 'Replace photo', onPressed: onPick),
                  IconButton(icon: const Icon(Icons.delete_outline), tooltip: 'Remove photo', onPressed: onRemove),
                ],
              ],
            ),
            AspectRatio(
              aspectRatio: _cardAspectRatio,
              child: Builder(
                builder: (context) {
                  return InkWell(
                    // Empty placeholder: tap to pick. Filled: tap to view
                    // full-screen. Replacement is the explicit Replace button
                    // so an accidental tap doesn't blow the picker open.
                    onTap: _hasContent ? () => _viewFullscreen(context) : onPick,
                    child: Container(
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: _buildPreview(context)),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    if (newBytes != null) {
      return Image.memory(newBytes!, fit: BoxFit.cover);
    }
    if (!cleared && photoId.isNotEmpty) {
      return _StoredPhoto(photoId: photoId);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 40, color: Theme.of(context).hintColor),
          const SizedBox(height: 4),
          Text('Tap to add photo', style: TextStyle(color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }

  Future<void> _viewFullscreen(BuildContext context) async {
    Uint8List? bytes = newBytes;
    if (bytes == null && !cleared && photoId.isNotEmpty) {
      bytes = await StorageProvider.instance.store.photos.readData(photoId);
    }
    if (bytes == null || !context.mounted) return;
    // rootNavigator pushes above the StatefulShell, so the nav rail / bottom
    // bar gets covered by the fullscreen viewer.
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        pageBuilder: (_, _, _) => _FullscreenPhoto(bytes: bytes!, label: label),
      ),
    );
  }
}

class _FullscreenPhoto extends StatelessWidget {
  final Uint8List bytes;
  final String label;

  const _FullscreenPhoto({required this.bytes, required this.label});

  @override
  Widget build(BuildContext context) {
    // macOS uses fullSizeContentView so the Flutter surface extends under the
    // title bar / traffic lights, and the title bar height is reported neither
    // via MediaQuery.padding (so SafeArea is a no-op) nor viewPadding. Hard
    // code the standard ~28px clearance on macOS; other platforms get their
    // real viewPadding.
    final basePadding = MediaQuery.of(context).viewPadding;
    final padding = Platform.isMacOS ? basePadding.copyWith(top: basePadding.top + 28) : basePadding;
    return Container(
      color: Colors.black,
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              title: Text(label),
              leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
            ),
            Expanded(
              child: Center(
                child: InteractiveViewer(minScale: 1.0, maxScale: 6.0, child: Image.memory(bytes, fit: BoxFit.contain)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoredPhoto extends StatefulWidget {
  final String photoId;

  const _StoredPhoto({required this.photoId});

  @override
  State<_StoredPhoto> createState() => _StoredPhotoState();
}

class _StoredPhotoState extends State<_StoredPhoto> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await StorageProvider.instance.store.photos.readData(widget.photoId);
    if (!mounted) return;
    setState(() {
      _bytes = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_bytes == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image_outlined, size: 40, color: Theme.of(context).hintColor),
            const SizedBox(height: 4),
            Text('Photo not yet downloaded', style: TextStyle(color: Theme.of(context).hintColor)),
          ],
        ),
      );
    }
    return Image.memory(_bytes!, fit: BoxFit.cover);
  }
}
