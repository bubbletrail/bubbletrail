import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../bloc/preferences_bloc.dart';
import 'common.dart';

export '../preferences/preferences.dart';

const litersToCuft = 0.0353147;
const kgToLbs = 2.20462;
const barToPsi = 14.504;
const metersToFeet = 3.28;

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

String formatLogTimestamp(TimeFormatPref pref, DateTime time) {
  final format = pref == TimeFormatPref.h24 ? 'HH:mm:ss.SSS' : 'h:mm:ss.SSS a';
  return DateFormat(format).format(time);
}

String formatLogLine(TimeFormatPref timeFormat, LogRecord record) {
  final time = formatLogTimestamp(timeFormat, record.time);
  final level = formatLogLevel(record.level);
  return '$time $level ${record.loggerName}: ${record.message}';
}

String formatLogLevel(Level level) {
  if (level == Level.FINE || level == Level.FINER || level == Level.FINEST) {
    return 'DEBUG';
  }
  return level.name;
}

Color getLogLevelColor(Level level, ThemeData theme) {
  if (level >= Level.SEVERE) {
    return theme.colorScheme.error;
  } else if (level >= Level.WARNING) {
    return Colors.orange;
  } else if (level >= Level.INFO) {
    return theme.colorScheme.onSurface;
  } else {
    return theme.colorScheme.onSurfaceVariant;
  }
}

String formatDepth(DepthUnit unit, num depth) {
  switch (unit) {
    case DepthUnit.meters:
      return '${depth.toStringAsFixed(1)} ${unit.label}';
    case DepthUnit.feet:
      return '${(depth * metersToFeet).toStringAsFixed(0)} ${unit.label}';
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
      return '${formatDisplayValue(volume)} ${unit.label}';
    case VolumeUnit.cuft:
      final val = volume * 0.0353;
      return '${formatDisplayValue(val)} ${unit.label}';
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

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

String formatMinutes(int seconds) {
  final minutes = (seconds / 60).round();
  return '$minutes min';
}

String formatLatitude(double val) {
  final d = val >= 0 ? 'N' : 'S';
  return formatLatLng(d, val.abs());
}

String formatLongitude(double val) {
  final d = val >= 0 ? 'E' : 'W';
  return formatLatLng(d, val.abs());
}

String formatLatLng(String hemisphere, double val) {
  final degrees = val.toInt();
  final minutes = (val - degrees) * 60;
  return '$degrees° ${minutes.toStringAsFixed(3)}\' $hemisphere';
}

class DurationText extends StatelessWidget {
  final int seconds;
  final TextStyle? style;

  const DurationText(this.seconds, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(formatMinutes(seconds), style: style);
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
  final String prefix;
  final num depth;

  const DepthText(this.depth, {this.prefix = '', super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.depthUnit;
    return Text(prefix + formatDepth(unit, depth));
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
  final IconData? icon;
  final String suffix;

  const VolumeText(this.volume, {this.icon, this.suffix = '', super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.volumeUnit;
    return IconText(icon, formatVolume(unit, volume) + suffix);
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

class DecoModelText extends StatelessWidget {
  final DecoModel model;

  const DecoModelText(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(format());
  }

  String format() {
    switch (model.type) {
      case DecoModelType.DECO_MODEL_TYPE_UNSPECIFIED:
        return 'Unspecified';
      case DecoModelType.DECO_MODEL_TYPE_NONE:
        return 'None';
      case DecoModelType.DECO_MODEL_TYPE_BUHLMANN:
        if (model.hasGfLow()) {
          return 'Bühlmann GF ${model.gfLow}/${model.gfHigh}';
        } else {
          return 'Bühlmann';
        }
      case DecoModelType.DECO_MODEL_TYPE_VPM:
        return 'VPM ${model.conservatism}';
      case DecoModelType.DECO_MODEL_TYPE_RGBM:
        return 'RGBM ${model.conservatism}';
      case DecoModelType.DECO_MODEL_TYPE_DCIEM:
        return 'DCIEM ${model.conservatism}';
      default:
        return 'Unknown';
    }
  }
}

class DecoStatusText extends StatelessWidget {
  final DecoStatus status;

  const DecoStatusText(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.watch<PreferencesBloc>().state.preferences.depthUnit;
    switch (status.type) {
      case DecoStopType.DECO_STOP_TYPE_DECO_STOP:
        return Text('Deco ${formatMinutes(status.time)} @ ${formatDepth(unit, status.depth)}');
      case DecoStopType.DECO_STOP_TYPE_DEEP_STOP:
        return Text('Deep stop ${formatMinutes(status.time)} @ ${formatDepth(unit, status.depth)}');
      case DecoStopType.DECO_STOP_TYPE_SAFETY_STOP:
        return Text('Safety stop ${formatMinutes(status.time)} @ ${formatDepth(unit, status.depth)}');
      case DecoStopType.DECO_STOP_TYPE_NDL:
        return Text('${formatMinutes(status.time)} NDL');
      case DecoStopType.DECO_STOP_TYPE_UNSPECIFIED:
        return Text('-');
      default:
        return Text('Unknown');
    }
  }
}

String formatDisplayValue(num value) {
  // Use reasonable precision
  var precision = 1;
  if (value < 1) precision = 2;
  if (value > 25) precision = 0;
  final formatted = value.toStringAsFixed(precision);
  // Remove trailing zeros after decimal point
  if (formatted.contains('.')) {
    var result = formatted.replaceAll(RegExp(r'0+$'), '');
    if (result.endsWith('.')) {
      result = result.substring(0, result.length - 1);
    }
    return result;
  }
  return formatted;
}

String formatGasPercentage(num oxygenPct, num heliumPct) {
  if (heliumPct > 0) {
    return 'Tx${oxygenPct.round()}/${heliumPct.round()}';
  } else if (oxygenPct > 0 && oxygenPct.round() != 21) {
    return 'EAN${oxygenPct.round()}';
  }
  return 'Air';
}

String formatGasFraction(double oxygen, double helium) {
  return formatGasPercentage(100 * oxygen, 100 * helium);
}
