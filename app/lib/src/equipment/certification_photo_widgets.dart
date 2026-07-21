import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_metadata.dart';
import '../providers/storage_provider.dart';

// Renders a photo stored in the photo store by id. Shows a spinner while
// loading and a placeholder if the photo data isn't available locally yet
// (e.g. not yet downloaded from sync).
class StoredPhoto extends StatefulWidget {
  final String photoId;

  const StoredPhoto({super.key, required this.photoId});

  @override
  State<StoredPhoto> createState() => _StoredPhotoState();
}

class _StoredPhotoState extends State<StoredPhoto> {
  Uint8List? _bytes;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(StoredPhoto old) {
    super.didUpdateWidget(old);
    if (old.photoId != widget.photoId) {
      _bytes = null;
      _loading = true;
      _load();
    }
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

class FullscreenPhoto extends StatefulWidget {
  final Uint8List bytes;
  final String label;

  const FullscreenPhoto({super.key, required this.bytes, required this.label});

  @override
  State<FullscreenPhoto> createState() => _FullscreenPhotoState();
}

class _FullscreenPhotoState extends State<FullscreenPhoto> {
  bool _barVisible = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    // Cert cards are landscape; on mobile the rest of the app is locked to
    // portrait, so unlock to landscape while the viewer is up and restore on
    // close.
    if (platformIsMobile) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    _scheduleHide();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    if (platformIsMobile) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _barVisible = false);
    });
  }

  // Any tap reveals the bar and restarts the auto-hide countdown.
  void _revealBar() {
    setState(() => _barVisible = true);
    _scheduleHide();
  }

  @override
  Widget build(BuildContext context) {
    // macOS uses fullSizeContentView so the Flutter surface extends under the
    // title bar / traffic lights, and the title bar height is reported neither
    // via MediaQuery.padding (so SafeArea is a no-op) nor viewPadding. Hard
    // code the standard ~28px clearance on macOS; other platforms get their
    // real viewPadding.
    final basePadding = MediaQuery.of(context).viewPadding;
    final padding = Platform.isMacOS ? basePadding.copyWith(top: basePadding.top + 28) : EdgeInsets.zero;
    return Container(
      color: Colors.black,
      // Behaviour: opaque so taps on the black letterbox area (not just the
      // image) also reveal the bar.
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _revealBar,
        child: Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(minScale: 1.0, maxScale: 6.0, child: Image.memory(widget.bytes, fit: BoxFit.contain)),
            ),
            Positioned(
              top: padding.top,
              left: padding.left,
              right: padding.right,
              // Fade and shrink upwards; IgnorePointer while hidden so the close
              // button doesn't swallow the reveal tap.
              child: IgnorePointer(
                ignoring: !_barVisible,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 250),
                  offset: _barVisible ? Offset.zero : const Offset(0, -1),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: _barVisible ? 1.0 : 0.0,
                    child: AppBar(
                      backgroundColor: Colors.grey.shade800.withAlpha(128),
                      foregroundColor: Colors.white,
                      title: Text(widget.label),
                      leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pop()),
                    ),
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

// Pushes the fullscreen photo viewer above the StatefulShell so the nav rail /
// bottom bar gets covered by it. Reads the photo from the store if only an id
// is supplied.
Future<void> showFullscreenPhoto(BuildContext context, {required String label, Uint8List? bytes, String? photoId}) async {
  bytes ??= photoId != null && photoId.isNotEmpty ? await StorageProvider.instance.store.photos.readData(photoId) : null;
  if (bytes == null || !context.mounted) return;
  await Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, _, _) => FullscreenPhoto(bytes: bytes!, label: label),
    ),
  );
}
