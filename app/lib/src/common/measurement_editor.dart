import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../preferences/preferences_bloc.dart';
import 'common.dart';

/// A text field for editing measurements with a unit dropdown.
/// Values are always stored internally in metric/base units.
/// The display converts to/from the selected unit on the fly.
class MeasurementEditor<T extends Enum> extends StatefulWidget {
  /// Label for the text field
  final String label;

  /// Initial value in base/metric units (null if empty)
  final double? initialValue;

  /// List of available units for the dropdown
  final List<T> units;

  /// Returns the display label for a unit (e.g., "bar", "psi")
  final String Function(T unit) unitLabel;

  /// Converts a value from metric to the display unit
  final double Function(double value, T unit) fromMetric;

  /// Converts a value from the display unit to metric
  final double Function(double value, T unit) toMetric;

  /// Called when the value changes (value is in metric units, null if empty/invalid)
  final ValueChanged<double?>? onChanged;

  /// Returns the preferred unit from preferences
  final T Function(Preferences prefs) getPreferredUnit;

  /// Hint text for the field
  final String? hintText;

  const MeasurementEditor({
    super.key,
    required this.label,
    this.initialValue,
    required this.units,
    required this.unitLabel,
    required this.fromMetric,
    required this.toMetric,
    required this.getPreferredUnit,
    this.onChanged,
    this.hintText,
  });

  @override
  State<MeasurementEditor<T>> createState() => _MeasurementEditorState<T>();
}

class _MeasurementEditorState<T extends Enum> extends State<MeasurementEditor<T>> {
  late TextEditingController _controller;
  late T _selectedUnit;
  double? _metricValue;

  @override
  void initState() {
    super.initState();
    _metricValue = widget.initialValue;
    // Get the preferred unit from preferences
    final prefs = context.read<PreferencesBloc>().state.preferences;
    _selectedUnit = widget.getPreferredUnit(prefs);
    // Initialize the text field with the converted value
    _controller = TextEditingController(text: _metricValue != null ? formatDisplayValue(widget.fromMetric(_metricValue!, _selectedUnit)) : '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final parsed = double.tryParse(text);
    if (parsed != null) {
      _metricValue = widget.toMetric(parsed, _selectedUnit);
    } else if (text.isEmpty) {
      _metricValue = null;
    }
    widget.onChanged?.call(_metricValue);
  }

  void _onUnitChanged(T? newUnit) {
    if (newUnit == null || newUnit == _selectedUnit) return;

    // Get current display value
    final currentText = _controller.text;
    final currentDisplayValue = double.tryParse(currentText);

    setState(() {
      if (currentDisplayValue != null) {
        // Convert current display value to metric, then to new unit
        final metricValue = widget.toMetric(currentDisplayValue, _selectedUnit);
        final newDisplayValue = widget.fromMetric(metricValue, newUnit);
        _controller.text = formatDisplayValue(newDisplayValue);
        _metricValue = metricValue;
      }
      _selectedUnit = newUnit;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .start,
      spacing: 16,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder(), hintText: widget.hintText),
            keyboardType: const .numberWithOptions(decimal: true),
            onChanged: _onTextChanged,
          ),
        ),
        SizedBox(
          width: 80,
          child: DropdownButtonFormField<T>(
            initialValue: _selectedUnit,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: .symmetric(horizontal: 12, vertical: 16)),
            items: widget.units.map((unit) {
              return DropdownMenuItem<T>(value: unit, child: Text(widget.unitLabel(unit)));
            }).toList(),
            onChanged: _onUnitChanged,
          ),
        ),
      ],
    );
  }

  /// Get the current metric value
  double? get metricValue => _metricValue;
}

// Convenience constructors for common measurement types

class PressureEditor extends StatelessWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? hintText;

  const PressureEditor({super.key, required this.label, this.initialValue, this.onChanged, this.hintText});

  static double _fromMetric(double value, PressureUnit unit) {
    return switch (unit) {
      .bar => value,
      .psi => value * barToPsi,
    };
  }

  static double _toMetric(double value, PressureUnit unit) {
    return switch (unit) {
      .bar => value,
      .psi => value / barToPsi,
    };
  }

  static String _unitLabel(PressureUnit unit) {
    return switch (unit) {
      .bar => 'bar',
      .psi => 'psi',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementEditor<PressureUnit>(
      label: label,
      initialValue: initialValue,
      units: PressureUnit.values,
      unitLabel: _unitLabel,
      fromMetric: _fromMetric,
      toMetric: _toMetric,
      getPreferredUnit: (prefs) => prefs.pressureUnit,
      onChanged: onChanged,
      hintText: hintText,
    );
  }
}

class VolumeEditor extends StatelessWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? hintText;

  const VolumeEditor({super.key, required this.label, this.initialValue, this.onChanged, this.hintText});

  static double _fromMetric(double value, VolumeUnit unit) {
    return switch (unit) {
      .liters => value,
      .cuft => value * litersToCuft,
    };
  }

  static double _toMetric(double value, VolumeUnit unit) {
    return switch (unit) {
      .liters => value,
      .cuft => value / litersToCuft,
    };
  }

  static String _unitLabel(VolumeUnit unit) {
    return switch (unit) {
      .liters => 'L',
      .cuft => 'cuft',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementEditor<VolumeUnit>(
      label: label,
      initialValue: initialValue,
      units: VolumeUnit.values,
      unitLabel: _unitLabel,
      fromMetric: _fromMetric,
      toMetric: _toMetric,
      getPreferredUnit: (prefs) => prefs.volumeUnit,
      onChanged: onChanged,
      hintText: hintText,
    );
  }
}

class WeightEditor extends StatelessWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? hintText;

  const WeightEditor({super.key, required this.label, this.initialValue, this.onChanged, this.hintText});

  static double _fromMetric(double value, WeightUnit unit) {
    return switch (unit) {
      .kg => value,
      .lb => value * kgToLbs,
    };
  }

  static double _toMetric(double value, WeightUnit unit) {
    return switch (unit) {
      .kg => value,
      .lb => value / kgToLbs,
    };
  }

  static String _unitLabel(WeightUnit unit) {
    return switch (unit) {
      .kg => 'kg',
      .lb => 'lbs',
    };
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementEditor<WeightUnit>(
      label: label,
      initialValue: initialValue,
      units: WeightUnit.values,
      unitLabel: _unitLabel,
      fromMetric: _fromMetric,
      toMetric: _toMetric,
      getPreferredUnit: (prefs) => prefs.weightUnit,
      onChanged: onChanged,
      hintText: hintText,
    );
  }
}

class DepthEditor extends StatelessWidget {
  final String label;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final String? hintText;

  const DepthEditor({super.key, required this.label, this.initialValue, this.onChanged, this.hintText});

  static double _fromMetric(double value, DepthUnit unit) {
    return switch (unit) {
      .meters => value,
      .feet => value * metersToFeet,
    };
  }

  static double _toMetric(double value, DepthUnit unit) {
    return switch (unit) {
      .meters => value,
      .feet => value / metersToFeet,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MeasurementEditor<DepthUnit>(
      label: label,
      initialValue: initialValue,
      units: DepthUnit.values,
      unitLabel: (unit) => unit.label,
      fromMetric: _fromMetric,
      toMetric: _toMetric,
      getPreferredUnit: (prefs) => prefs.depthUnit,
      onChanged: onChanged,
      hintText: hintText,
    );
  }
}
