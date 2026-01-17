import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import '../app_metadata.dart';

class WindowPreferences {
  static const _windowXKey = 'window_x';
  static const _windowYKey = 'window_y';
  static const _windowWidthKey = 'window_width';
  static const _windowHeightKey = 'window_height';
  static const _windowMaximizedKey = 'window_maximized';

  static const _defaultWidth = 1200.0;
  static const _defaultHeight = 800.0;

  static bool get isSupported => platformIsDesktop;

  static Future<void> initialize() async {
    if (!isSupported) return;

    await windowManager.ensureInitialized();

    final prefs = await SharedPreferences.getInstance();
    final width = prefs.getDouble(_windowWidthKey) ?? _defaultWidth;
    final height = prefs.getDouble(_windowHeightKey) ?? _defaultHeight;
    final x = prefs.getDouble(_windowXKey);
    final y = prefs.getDouble(_windowYKey);
    final isMaximized = prefs.getBool(_windowMaximizedKey) ?? false;

    final windowOptions = WindowOptions(size: Size(width, height), center: x == null || y == null, minimumSize: const Size(400, 300));

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      if (x != null && y != null) {
        await windowManager.setPosition(Offset(x, y));
      }
      if (isMaximized) {
        await windowManager.maximize();
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  static Future<void> save() async {
    if (!isSupported) return;

    final prefs = await SharedPreferences.getInstance();
    final isMaximized = await windowManager.isMaximized();

    await prefs.setBool(_windowMaximizedKey, isMaximized);

    if (!isMaximized) {
      final position = await windowManager.getPosition();
      final size = await windowManager.getSize();

      await prefs.setDouble(_windowXKey, position.dx);
      await prefs.setDouble(_windowYKey, position.dy);
      await prefs.setDouble(_windowWidthKey, size.width);
      await prefs.setDouble(_windowHeightKey, size.height);
    }
  }
}
