import 'package:flutter/material.dart';

Color darken(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  final f = 1 - percent / 100;
  return .fromARGB((c.a * 255).round(), (c.r * 255 * f).round(), (c.g * 255 * f).round(), (c.b * 255 * f).round());
}

Color lighten(Color c, [int percent = 10]) {
  assert(1 <= percent && percent <= 100);
  final p = percent / 100;
  return .fromARGB(
    (c.a * 255).round(),
    (255 * (c.r + ((1 - c.r) * p))).round(),
    (255 * (c.g + ((1 - c.g) * p))).round(),
    (255 * (c.b + ((1 - c.b) * p))).round(),
  );
}
