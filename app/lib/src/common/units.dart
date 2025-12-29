import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../preferences/preferences.dart';

String formatDepth(BuildContext context, num depth) {
  final unit = context.read<PreferencesBloc>().state.preferences.depthUnit;
  switch (unit) {
    case DepthUnit.meters:
      return '${depth.toStringAsFixed(1)} m';
    case DepthUnit.feet:
      return '${(depth * 3.28).toStringAsFixed(0)} ft';
  }
}

int convertDepth(BuildContext context, num depth) {
  final unit = context.read<PreferencesBloc>().state.preferences.depthUnit;
  switch (unit) {
    case DepthUnit.meters:
      return depth.round();
    case DepthUnit.feet:
      return (depth * 3.28).round();
  }
}

String formatTemperature(BuildContext context, num temperature) {
  final unit = context.read<PreferencesBloc>().state.preferences.temperatureUnit;
  switch (unit) {
    case TemperatureUnit.celsius:
      return '${temperature.toStringAsFixed(1)} °C';
    case TemperatureUnit.fahrenheit:
      return '${(temperature * 1.8 + 32).toStringAsFixed(0)} °F';
  }
}

String formatPressure(BuildContext context, num pressure) {
  final unit = context.read<PreferencesBloc>().state.preferences.pressureUnit;
  switch (unit) {
    case PressureUnit.bar:
      return '${pressure.toStringAsFixed(0)} bar';
    case PressureUnit.psi:
      return '${(pressure * 14.504).toStringAsFixed(0)} psi';
  }
}

String formatVolume(BuildContext context, num volume) {
  final unit = context.read<PreferencesBloc>().state.preferences.volumeUnit;
  switch (unit) {
    case VolumeUnit.liters:
      return '${volume.toStringAsFixed(1)} L';
    case VolumeUnit.cuft:
      return '${(volume * 0.0353).toStringAsFixed(1)} cuft';
  }
}

String formatWeight(BuildContext context, num weight) {
  final unit = context.read<PreferencesBloc>().state.preferences.weightUnit;
  switch (unit) {
    case WeightUnit.kg:
      return '${weight.toStringAsFixed(1)} kg';
    case WeightUnit.lbs:
      return '${(weight * 2.205).toStringAsFixed(1)} lbs';
  }
}

String formatDuration(int seconds) {
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  if (secs == 0) {
    return '${minutes}m';
  }
  return '${minutes}m ${secs}s';
}

class DepthText extends StatelessWidget {
  final num depth;

  const DepthText(this.depth, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PreferencesBloc>();
    return Text(formatDepth(context, depth));
  }
}

class TemperatureText extends StatelessWidget {
  final num temperature;

  const TemperatureText(this.temperature, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PreferencesBloc>();
    return Text(formatTemperature(context, temperature));
  }
}

class PressureText extends StatelessWidget {
  final num pressure;

  const PressureText(this.pressure, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PreferencesBloc>();
    return Text(formatPressure(context, pressure));
  }
}

class VolumeText extends StatelessWidget {
  final num volume;

  const VolumeText(this.volume, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PreferencesBloc>();
    return Text(formatVolume(context, volume));
  }
}

class WeightText extends StatelessWidget {
  final num weight;

  const WeightText(this.weight, {super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<PreferencesBloc>();
    return Text(formatWeight(context, weight));
  }
}
