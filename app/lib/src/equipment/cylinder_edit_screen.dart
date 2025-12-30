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
  late final TextEditingController _sizeController;
  late final TextEditingController _workpressureController;

  @override
  void initState() {
    super.initState();
    final state = context.read<CylinderDetailsBloc>().state as CylinderDetailsLoaded;
    _originalCylinder = state.cylinder;
    _isNew = state.isNew;
    _descriptionController = TextEditingController(text: _originalCylinder.description);
    _sizeController = TextEditingController(text: _originalCylinder.hasSize() ? _originalCylinder.size.toString() : '');
    _workpressureController = TextEditingController(text: _originalCylinder.hasWorkpressure() ? _originalCylinder.workpressure.toString() : '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _sizeController.dispose();
    _workpressureController.dispose();
    super.dispose();
  }

  bool _saveCylinder() {
    final description = _descriptionController.text.trim();
    final sizeText = _sizeController.text.trim();
    final wpText = _workpressureController.text.trim();

    final size = sizeText.isNotEmpty ? double.tryParse(sizeText) : null;
    final workpressure = wpText.isNotEmpty ? double.tryParse(wpText) : null;

    if (sizeText.isNotEmpty && size == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid size value')));
      return false;
    }

    if (wpText.isNotEmpty && workpressure == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid working pressure value')));
      return false;
    }

    final updatedCylinder = Cylinder(id: _originalCylinder.id, description: description.isEmpty ? null : description, size: size, workpressure: workpressure);

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
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), hintText: 'e.g., AL80, Steel HP100'),
              ),
              TextField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size (liters)', border: OutlineInputBorder(), hintText: 'e.g., 11.1'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              TextField(
                controller: _workpressureController,
                decoration: const InputDecoration(labelText: 'Working Pressure (bar)', border: OutlineInputBorder(), hintText: 'e.g., 207'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
