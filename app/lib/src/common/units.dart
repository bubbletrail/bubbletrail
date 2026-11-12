import 'package:btl10n/btl10n.dart';
import 'package:btproto/btproto.dart';
import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

import '../preferences/preferences_store.dart';
import 'common.dart';

export '../preferences/preferences.dart';

const litersToCuft = 0.0353147;
const kgToLbs = 2.20462;
const barToPsi = 14.504;
const metersToFeet = 3.28084;

// Date and time formatting

String formatDate(DateFormatPref pref, DateTime date) {
  return DateFormat(pref.format).format(date);
}

String formatTime(TimeFormatPref pref, DateTime time) {
  return DateFormat(pref.format).format(time);
}

String formatDateTime(PreferencesStore prefs, DateTime dateTime) {
  return '${formatDate(prefs.dateFormat, dateTime)} ${formatTime(prefs.timeFormat, dateTime)}';
}

String formatLogTimestamp(TimeFormatPref pref, DateTime time) {
  final format = pref == .h24 ? 'HH:mm:ss.SSS' : 'h:mm:ss.SSS a';
  return DateFormat(format).format(time);
}

String formatLogLine(TimeFormatPref timeFormat, LogRecord record) {
  final time = formatLogTimestamp(timeFormat, record.time);
  final level = formatLogLevel(record.level);
  return '$time $level ${record.loggerName}: ${record.message}';
}

String formatLogLevel(Level level) {
  if (level == .FINE || level == .FINER || level == .FINEST) {
    return 'DEBUG';
  }
  return level.name;
}

Color getLogLevelColor(Level level, ThemeData theme) {
  if (level >= .SEVERE) {
    return theme.colorScheme.error;
  } else if (level >= .WARNING) {
    return Colors.orange;
  } else if (level >= .INFO) {
    return theme.colorScheme.onSurface;
  } else {
    return theme.colorScheme.onSurfaceVariant;
  }
}

String formatDepth(AppLocalizations l10n, DepthUnit unit, num depth) {
  switch (unit) {
    case .meters:
      return l10n.measurement(depth.toStringAsFixed(1), unit.label(l10n));
    case .feet:
      return l10n.measurement((depth * metersToFeet).toStringAsFixed(0), unit.label(l10n));
  }
}

int convertDepth(DepthUnit unit, num depth) {
  switch (unit) {
    case .meters:
      return depth.round();
    case .feet:
      return (depth * metersToFeet).round();
  }
}

String formatTemperature(AppLocalizations l10n, TemperatureUnit unit, num temperature) {
  switch (unit) {
    case .celsius:
      return l10n.measurement(temperature.toStringAsFixed(1), unit.label(l10n));
    case .fahrenheit:
      return l10n.measurement((temperature * 1.8 + 32).toStringAsFixed(0), unit.label(l10n));
  }
}

String formatPressure(AppLocalizations l10n, PressureUnit unit, num pressure) {
  switch (unit) {
    case .bar:
      return l10n.measurement(pressure.toStringAsFixed(0), unit.label(l10n));
    case .psi:
      return l10n.measurement((pressure * barToPsi).toStringAsFixed(0), unit.label(l10n));
  }
}

String formatVolume(AppLocalizations l10n, VolumeUnit unit, num volume, {precise = false}) {
  switch (unit) {
    case .liters:
      if (precise) return l10n.measurement(volume.toStringAsFixed(1), unit.label(l10n));
      return l10n.measurement(formatDisplayValue(volume), unit.label(l10n));
    case .cuft:
      final val = volume * litersToCuft;
      if (precise) return l10n.measurement(val.toStringAsFixed(2), unit.label(l10n));
      return l10n.measurement(formatDisplayValue(val), unit.label(l10n));
  }
}

String formatWeight(AppLocalizations l10n, WeightUnit unit, num weight) {
  switch (unit) {
    case .kg:
      return l10n.measurement(weight.toStringAsFixed(1), unit.label(l10n));
    case .lb:
      return l10n.measurement((weight * kgToLbs).toStringAsFixed(1), unit.label(l10n));
  }
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '$minutes:${secs.toString().padLeft(2, '0')}';
}

String formatMinutes(AppLocalizations l10n, int seconds) {
  final minutes = (seconds / 60).round();
  return l10n.minutesDuration(minutes);
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
    return Text(formatMinutes(context.l10n, seconds), style: style);
  }
}

// Displays a date and time. When [timezone] (an IANA name) is given, [dateTime]
// is assumed to be a UTC instant and is converted into that zone, with the zone
// abbreviation (e.g. "CEST") appended; otherwise it's shown as-is.
class DateTimeText extends StatelessWidget {
  final DateTime dateTime;
  final String? timezone;
  final TextStyle? style;

  const DateTimeText(this.dateTime, {super.key, this.timezone, this.style});

  @override
  Widget build(BuildContext context) {
    final (dateFormat, timeFormat) = context.select<PreferencesStore, (DateFormatPref, TimeFormatPref)>((p) => (p.dateFormat, p.timeFormat));
    final zoned = inZone(dateTime, timezone);
    final local = zoned ?? dateTime;
    // final suffix = zoned != null ? ' ${zoned.timeZoneName}' : '';
    return Text('${formatDate(dateFormat, local)} ${formatTime(timeFormat, local)}', style: style);
  }
}

class TimeText extends StatelessWidget {
  final DateTime dateTime;
  final String? timezone;
  final TextStyle? style;

  const TimeText(this.dateTime, {super.key, this.timezone, this.style});

  @override
  Widget build(BuildContext context) {
    final timeFormat = context.select<PreferencesStore, TimeFormatPref>((p) => p.timeFormat);
    final zoned = inZone(dateTime, timezone);
    final local = zoned ?? dateTime;
    final suffix = zoned != null ? ' ${zoned.timeZoneName}' : '';
    return Text('${formatTime(timeFormat, local)}$suffix', style: style);
  }
}

class DateText extends StatelessWidget {
  final DateTime dateTime;
  final String? timezone;
  final TextStyle? style;

  const DateText(this.dateTime, {super.key, this.timezone, this.style});

  @override
  Widget build(BuildContext context) {
    final dateFormat = context.select<PreferencesStore, DateFormatPref>((p) => p.dateFormat);
    // Convert into the zone too: near midnight the local calendar date can
    // differ from the UTC one.
    final local = inZone(dateTime, timezone) ?? dateTime;
    return Text(formatDate(dateFormat, local), style: style);
  }
}

class DepthText extends StatelessWidget {
  final String prefix;
  final num depth;

  const DepthText(this.depth, {this.prefix = '', super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, DepthUnit>((p) => p.depthUnit);
    return Text(prefix + formatDepth(context.l10n, unit, depth));
  }
}

class TemperatureText extends StatelessWidget {
  final num temperature;

  const TemperatureText(this.temperature, {super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, TemperatureUnit>((p) => p.temperatureUnit);
    return Text(formatTemperature(context.l10n, unit, temperature));
  }
}

class PressureText extends StatelessWidget {
  final num pressure;
  final IconData? icon;

  const PressureText(this.pressure, {this.icon, super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, PressureUnit>((p) => p.pressureUnit);
    return IconText(icon, formatPressure(context.l10n, unit, pressure));
  }
}

class VolumeText extends StatelessWidget {
  final num volume;
  final IconData? icon;
  final String suffix;
  final bool precise;

  const VolumeText(this.volume, {this.icon, this.suffix = '', super.key, this.precise = false});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, VolumeUnit>((p) => p.volumeUnit);
    return IconText(icon, formatVolume(context.l10n, unit, volume, precise: precise) + suffix);
  }
}

class WeightText extends StatelessWidget {
  final num weight;
  final TextStyle? style;

  const WeightText(this.weight, {this.style, super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, WeightUnit>((p) => p.weightUnit);
    return Text(formatWeight(context.l10n, unit, weight), style: style);
  }
}

class DecoModelText extends StatelessWidget {
  final DecoModel model;

  const DecoModelText(this.model, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(format(context));
  }

  String format(BuildContext context) {
    switch (model.type) {
      case .DECO_MODEL_TYPE_UNSPECIFIED:
        return context.l10n.unspecified;
      case .DECO_MODEL_TYPE_NONE:
        return context.l10n.none;
      case .DECO_MODEL_TYPE_BUHLMANN:
        if (model.hasGfLow()) {
          return context.l10n.buhlmannGradientFactors(model.gfLow, model.gfHigh);
        } else {
          return context.l10n.buhlmann;
        }
      case .DECO_MODEL_TYPE_VPM:
        return context.l10n.vpm(model.conservatism);
      case .DECO_MODEL_TYPE_RGBM:
        return context.l10n.rgbm(model.conservatism);
      case .DECO_MODEL_TYPE_DCIEM:
        return context.l10n.dciem(model.conservatism);
      default:
        return context.l10n.unknown;
    }
  }
}

class DecoStatusText extends StatelessWidget {
  final DecoStatus status;

  const DecoStatusText(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final unit = context.select<PreferencesStore, DepthUnit>((p) => p.depthUnit);
    switch (status.type) {
      case .DECO_STOP_TYPE_DECO_STOP:
        return Text(context.l10n.deco(formatMinutes(context.l10n, status.tts), formatDepth(context.l10n, unit, status.depth)));
      case .DECO_STOP_TYPE_DEEP_STOP:
        return Text(context.l10n.deepStop(formatMinutes(context.l10n, status.time), formatDepth(context.l10n, unit, status.depth)));
      case .DECO_STOP_TYPE_SAFETY_STOP:
        return Text(context.l10n.safetyStop(formatMinutes(context.l10n, status.time), formatDepth(context.l10n, unit, status.depth)));
      case .DECO_STOP_TYPE_NDL:
        return Text(context.l10n.ndl(formatMinutes(context.l10n, status.time)));
      case .DECO_STOP_TYPE_UNSPECIFIED:
        return Text('-');
      default:
        return Text(context.l10n.unknown);
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

String formatGasPercentage(BuildContext context, num oxygenPct, num heliumPct) {
  if (heliumPct > 0) {
    return context.l10n.trimix(oxygenPct.round(), heliumPct.round());
  } else if (oxygenPct > 0 && oxygenPct.round() != 21) {
    return context.l10n.nitrox(oxygenPct.round());
  }
  return context.l10n.air;
}

String formatGasFraction(BuildContext context, double oxygen, double helium) {
  return formatGasPercentage(context, 100 * oxygen, 100 * helium);
}
