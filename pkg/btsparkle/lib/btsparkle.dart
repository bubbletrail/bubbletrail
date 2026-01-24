import 'dart:async';
import 'package:flutter/services.dart';

class BTSparkle {
  static const platform = MethodChannel('btsparkle');

  static Future<void> checkForUpdates() async {
    await platform.invokeMethod<void>('checkForUpdates');
  }
}
