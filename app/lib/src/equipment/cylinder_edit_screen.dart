import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import 'cylinder_details_bloc.dart';
import '../common/common.dart';

class CylinderEditScreen extends StatefulWidget {
  const CylinderEditScreen({super.key});

  @override
  State<CylinderEditScreen> createState() => _CylinderEditScreenState();
}

class _CylinderEditScreenState extends State<CylinderEditScreen> {
  late final Cylinder _originalCylinder;
  late final bool _isNew;
  late final TextEditingController _descriptionController;
  late final TextEditingController _volumeLController;
  late final TextEditingController _volumeCuftController;
  late final TextEditingController _pressureBarController;
  late final TextEditingController _pressurePsiController;

  // Metric values (always populated for storage)
  double _size = 0;
  double _workpressure = 0;

  // Imperial values (only populated when editing in imperial mode)
  double _sizeCuft = 0;
  double _workpressurePsi = 0;

  // Track if we're editing in imperial mode
  late bool _isImperialMode;

  @override
  void initState() {
    super.initState();
    final state = context.read<CylinderDetailsBloc>().state as CylinderDetailsLoaded;
    _originalCylinder = state.cylinder;
    _isNew = state.isNew;
    _descriptionController = TextEditingController(text: _originalCylinder.description);

    _isImperialMode = _originalCylinder.hasVolumeCuft();

    _size = _originalCylinder.volumeL;
    _workpressure = _originalCylinder.workingPressureBar;

    if (_originalCylinder.hasVolumeCuft() && _originalCylinder.hasWorkingPressurePsi()) {
      _sizeCuft = _originalCylinder.volumeCuft;
      _workpressurePsi = _originalCylinder.workingPressurePsi;
    } else {
      _sizeCuft = lToCuft(_originalCylinder.volumeL * _originalCylinder.workingPressureBar);
      _workpressurePsi = barToPSI(_originalCylinder.workingPressureBar);
    }

    _volumeLController = TextEditingController(text: formatDisplayValue(_size));
    _pressureBarController = TextEditingController(text: formatDisplayValue(_workpressure));
    _volumeCuftController = TextEditingController(text: formatDisplayValue(_sizeCuft));
    _pressurePsiController = TextEditingController(text: formatDisplayValue(_workpressurePsi));
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _saveCylinder() {
    final description = _descriptionController.text.trim();

    final updatedCylinder = Cylinder(
      id: _originalCylinder.id,
      description: description.isEmpty ? null : description,
      volumeL: _size,
      workingPressureBar: _workpressure,
      volumeCuft: _isImperialMode ? _sizeCuft : null,
      workingPressurePsi: _isImperialMode ? _workpressurePsi : null,
    );

    context.read<CylinderDetailsBloc>().add(UpdateCylinderDetails(updatedCylinder));

    return true;
  }

  void _saveAndPop() {
    if (_saveCylinder()) {
      context.pop();
    }
  }

  void _cancel() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveAndPop();
        }
      },
      child: ScreenScaffold(
        title: Text(_isNew ? 'New cylinder' : 'Edit cylinder'),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes')],
        body: Padding(
          padding: const .all(16.0),
          child: Column(spacing: 16, children: [_descriptionCard(), platformIsMobile ? _verticalCards(context) : _horisontalCards(context)]),
        ),
      ),
    );
  }

  TextField _descriptionCard() {
    return TextField(
      controller: _descriptionController,
      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), hintText: 'e.g., AL80, 12x232'),
    );
  }

  Flex _horisontalCards(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Expanded(child: _metricCard(context)),
        Expanded(child: _imperialCard(context)),
      ],
    );
  }

  Flex _verticalCards(BuildContext context) {
    return Column(spacing: 16, children: [_metricCard(context), _imperialCard(context)]);
  }

  Card _metricCard(BuildContext context) {
    return Card(
      margin: .zero,
      child: Padding(
        padding: const .all(8.0),
        child: Opacity(
          opacity: _isImperialMode ? 0.5 : 1.0,
          child: Column(
            spacing: 16,
            crossAxisAlignment: .start,
            children: [
              Text('Metric', style: Theme.of(context).textTheme.titleMedium),
              TextField(
                controller: _volumeLController,
                decoration: InputDecoration(labelText: 'Water volume (L)', border: const OutlineInputBorder(), hintText: 'e.g. 12'),
                keyboardType: const .numberWithOptions(decimal: true),
                onChanged: _didSetVolumeL,
                onTap: () => setState(() {
                  _isImperialMode = false;
                }),
              ),
              TextField(
                controller: _pressureBarController,
                decoration: InputDecoration(labelText: 'Working pressure (bar)', border: const OutlineInputBorder(), hintText: 'e.g. 232'),
                keyboardType: const .numberWithOptions(decimal: true),
                onChanged: _didSetPressureBar,
                onTap: () => setState(() {
                  _isImperialMode = false;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Card _imperialCard(BuildContext context) {
    return Card(
      margin: .zero,
      child: Padding(
        padding: const .all(8.0),
        child: Opacity(
          opacity: _isImperialMode ? 1.0 : 0.5,
          child: Column(
            spacing: 16,
            crossAxisAlignment: .start,
            children: [
              Text('Imperial', style: Theme.of(context).textTheme.titleMedium),
              TextField(
                controller: _volumeCuftController,
                decoration: InputDecoration(labelText: 'Size (cuft)', border: const OutlineInputBorder(), hintText: 'e.g. 80'),
                keyboardType: const .numberWithOptions(decimal: true),
                onChanged: _didSetVolumeCuft,
                onTap: () => setState(() {
                  _isImperialMode = true;
                }),
              ),
              TextField(
                controller: _pressurePsiController,
                decoration: InputDecoration(labelText: 'Working pressure (psi)', border: const OutlineInputBorder(), hintText: 'e.g. 3000'),
                keyboardType: const .numberWithOptions(decimal: true),
                onChanged: _didSetPressurePsi,
                onTap: () => setState(() {
                  _isImperialMode = true;
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _didSetPressureBar(String s) {
    final val = double.tryParse(s) ?? 0;
    setState(() {
      _workpressure = val;
      _workpressurePsi = barToPSI(val);
      _pressurePsiController.text = formatDisplayValue(_workpressurePsi);
      _isImperialMode = false;
    });
  }

  void _didSetVolumeL(String s) {
    final val = double.tryParse(s) ?? 0;
    setState(() {
      _size = val;
      _sizeCuft = lToCuft(_size * _workpressure);
      _volumeCuftController.text = formatDisplayValue(_sizeCuft);
      _isImperialMode = false;
    });
  }

  void _didSetPressurePsi(String s) {
    final val = double.tryParse(s) ?? 0;
    setState(() {
      _workpressurePsi = val;
      _workpressure = psiToBar(val);
      _pressureBarController.text = formatDisplayValue(_workpressure);
      _size = cuftToL(_sizeCuft) / _workpressure;
      _volumeLController.text = formatDisplayValue(_size);
      _isImperialMode = true;
    });
  }

  void _didSetVolumeCuft(String s) {
    final val = double.tryParse(s) ?? 0;
    setState(() {
      _sizeCuft = val;
      _size = cuftToL(_sizeCuft) / _workpressure;
      _volumeLController.text = formatDisplayValue(_size);
      _isImperialMode = true;
    });
  }
}

double barToPSI(double bar) => bar * barToPsi;
double psiToBar(double psi) => psi / barToPsi;
double lToCuft(double liters) => liters * litersToCuft;
double cuftToL(double cuft) => cuft / litersToCuft;
