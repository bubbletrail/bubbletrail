import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cylinderdetails_bloc.dart';
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

  // Store values in metric units
  double? _size;
  double? _workpressure;

  @override
  void initState() {
    super.initState();
    final state = context.read<CylinderDetailsBloc>().state as CylinderDetailsLoaded;
    _originalCylinder = state.cylinder;
    _isNew = state.isNew;
    _descriptionController = TextEditingController(text: _originalCylinder.description);
    _size = _originalCylinder.hasSize() ? _originalCylinder.size : null;
    _workpressure = _originalCylinder.hasWorkpressure() ? _originalCylinder.workpressure : null;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  bool _saveCylinder() {
    final description = _descriptionController.text.trim();

    final updatedCylinder = Cylinder(id: _originalCylinder.id, description: description.isEmpty ? null : description, size: _size, workpressure: _workpressure);

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
        title: Text(_isNew ? 'New Cylinder' : 'Edit Cylinder'),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes')],
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), hintText: 'e.g., AL80, 12x232'),
              ),
              VolumeEditor(label: 'Size', initialValue: _size, onChanged: (value) => _size = value, hintText: 'e.g., 12.0'),
              PressureEditor(label: 'Working Pressure', initialValue: _workpressure, onChanged: (value) => _workpressure = value, hintText: 'e.g., 232'),
            ],
          ),
        ),
      ),
    );
  }
}
