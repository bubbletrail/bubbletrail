double? tryParseUnitString(String? s) {
  if (s == null) return null;

  final asIs = double.tryParse(s);
  if (asIs != null) return asIs;

  // Handle percentage (e.g., "32.0%")
  if (s.endsWith('%')) {
    return double.tryParse(s.substring(0, s.length - 1));
  }

  final parts = s.split(' ');
  if (parts.length < 2) return null;

  switch (parts[1]) {
    case 'min': // "1:23 min"
      final minSec = parts[0].split(':');
      if (minSec.length != 2) return null;
      final min = double.tryParse(minSec[0]);
      final sec = double.tryParse(minSec[1]);
      if (min == null || sec == null) return null;
      return min * 60 + sec;
    default:
      return double.tryParse(parts[0]);
  }
}

DateTime? tryParseDateTime(String? date, String? time) {
  if (date == null) return null;

  try {
    // Parse date in format 'YYYY-MM-DD'
    final dateParts = date.split('-');
    if (dateParts.length != 3) return null;

    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);

    if (year == null || month == null || day == null) return null;

    // Parse time in format 'HH:MM:SS' if provided
    int hour = 0;
    int minute = 0;
    int second = 0;

    if (time != null) {
      final timeParts = time.split(':');
      if (timeParts.length >= 2) {
        hour = int.tryParse(timeParts[0]) ?? 0;
        minute = int.tryParse(timeParts[1]) ?? 0;
        if (timeParts.length >= 3) {
          second = int.tryParse(timeParts[2]) ?? 0;
        }
      }
    }

    return DateTime(year, month, day, hour, minute, second);
  } catch (e) {
    return null;
  }
}

// Serialization helpers
String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = (seconds % 60).round();
  return '$minutes:${secs.toString().padLeft(2, '0')} min';
}

String formatDepth(double meters) {
  // Use up to 3 decimal places, but remove trailing zeros
  final formatted = meters.toStringAsFixed(3);
  final trimmed = formatted.replaceAll(RegExp(r'\.?0+$'), '');
  return '$trimmed m';
}

String formatTemp(double celsius) {
  return '${celsius.toStringAsFixed(1)} C';
}

String formatDate(DateTime dt) {
  return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

String formatTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
}
