import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/preferences_bloc.dart';
import '../preferences/preferences.dart';
import 'common.dart';

// Date and time formatting

String formatDate(DateFormatPref pref, DateTime date) {
  return DateFormat(pref.format).format(date);
}

String formatTime(TimeFormatPref pref, DateTime time) {
  return DateFormat(pref.format).format(time);
}

String formatDateTime(Preferences pref, DateTime dateTime) {
  return '${formatDate(pref.dateFormat, dateTime)} ${formatTime(pref.timeFormat, dateTime)}';
}

String formatDepth(DepthUnit unit, num depth) {
  switch (unit) {
    case DepthUnit.meters:
      return '${depth.toStringAsFixed(1)} ${unit.label}';
    case DepthUnit.feet:
      return '${(depth * 3.28).toStringAsFixed(0)} ${unit.label}';
  }
}

int convertDepth(DepthUnit unit, num depth) {
  switch (unit) {
    case DepthUnit.meters:
      return depth.round();
    case DepthUnit.feet:
      return (depth * 3.28).round();
  }
}

String formatTemperature(TemperatureUnit unit, num temperature) {
  switch (unit) {
    case TemperatureUnit.celsius:
      return '${temperature.toStringAsFixed(1)} ${unit.label}';
    case TemperatureUnit.fahrenheit:
      return '${(temperature * 1.8 + 32).toStringAsFixed(0)} ${unit.label}';
  }
}

String formatPressure(PressureUnit unit, num pressure) {
  switch (unit) {
    case PressureUnit.bar:
      return '${pressure.toStringAsFixed(0)} ${unit.label}';
    case PressureUnit.psi:
      return '${(pressure * 14.504).toStringAsFixed(0)} ${unit.label}';
  }
}

String formatVolume(VolumeUnit unit, num volume) {
  switch (unit) {
    case VolumeUnit.liters:
      return '${volume.toStringAsFixed(1)} ${unit.label}';
    case VolumeUnit.cuft:
      return '${(volume * 0.0353).toStringAsFixed(1)} ${unit.label}';
  }
}

String formatWeight(WeightUnit unit, num weight) {
  switch (unit) {
    case WeightUnit.kg:
      return '${weight.toStringAsFixed(1)} ${unit.label}';
    case WeightUnit.lb:
      return '${(weight * 2.205).toStringAsFixed(1)} ${unit.label}';
  }
}

String formatSAC(VolumeUnit unit, num sac) {
  switch (unit) {
    case VolumeUnit.liters:
      return '${sac.toStringAsFixed(1)} ${unit.label}/min';
    case VolumeUnit.cuft:
      return '${(sac * 0.0353).toStringAsFixed(2)} ${unit.label}/min';
  }
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

class DurationText extends StatelessWidget {
  final int seconds;
  final TextStyle? style;

  const DurationText(this.seconds, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(formatDuration(seconds), style: style);
  }
}

class DateTimeText extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const DateTimeText(this.dateTime, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesBloc>().state.preferences;
    return Text(formatDateTime(prefs, dateTime), style: style);
  }
}

class TimeText extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const TimeText(this.dateTime, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesBloc>().state.preferences;
    return Text(formatTime(prefs.timeFormat, dateTime), style: style);
  }
}

class DateText extends StatelessWidget {
  final DateTime dateTime;
  final TextStyle? style;

  const DateText(this.dateTime, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesBloc>().state.preferences;
    return Text(formatDate(prefs.dateFormat, dateTime), style: style);
  }
}

class DepthText extends StatelessWidget {
  final num depth;

  const DepthText(this.depth, {super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.depthUnit;
    return Text(formatDepth(unit, depth));
  }
}

class TemperatureText extends StatelessWidget {
  final num temperature;

  const TemperatureText(this.temperature, {super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.temperatureUnit;
    return Text(formatTemperature(unit, temperature));
  }
}

class PressureText extends StatelessWidget {
  final num pressure;
  final IconData? icon;

  const PressureText(this.pressure, {this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.pressureUnit;
    return IconText(icon, formatPressure(unit, pressure));
  }
}

class VolumeText extends StatelessWidget {
  final num volume;
  final String suffix;

  const VolumeText(this.volume, {this.suffix = '', super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.volumeUnit;
    return Text(formatVolume(unit, volume) + suffix);
  }
}

class WeightText extends StatelessWidget {
  final num weight;
  final TextStyle? style;

  const WeightText(this.weight, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.weightUnit;
    return Text(formatWeight(unit, weight), style: style);
  }
}
