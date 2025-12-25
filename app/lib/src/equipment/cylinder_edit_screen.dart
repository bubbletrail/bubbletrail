import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/cylinderdetails_bloc.dart';
import '../bloc/cylinderlist_bloc.dart';
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
    _descriptionController = TextEditingController(text: _originalCylinder.description ?? '');
    _sizeController = TextEditingController(text: _originalCylinder.size?.toString() ?? '');
    _workpressureController = TextEditingController(text: _originalCylinder.workpressure?.toString() ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _sizeController.dispose();
    _workpressureController.dispose();
    super.dispose();
  }

  void _saveCylinder() {
    try {
      final description = _descriptionController.text.trim();
      final sizeText = _sizeController.text.trim();
      final wpText = _workpressureController.text.trim();

      final size = sizeText.isNotEmpty ? double.tryParse(sizeText) : null;
      final workpressure = wpText.isNotEmpty ? double.tryParse(wpText) : null;

      if (sizeText.isNotEmpty && size == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid size value')));
        return;
      }

      if (wpText.isNotEmpty && workpressure == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid working pressure value')));
        return;
      }

      final updatedCylinder = Cylinder(id: _originalCylinder.id, description: description.isEmpty ? null : description, size: size, workpressure: workpressure);

      // Send update event to bloc
      context.read<CylinderDetailsBloc>().add(UpdateCylinderDetails(updatedCylinder));

      // Reload cylinder list to reflect changes
      context.read<CylinderListBloc>().add(const LoadCylinders());

      // Navigate back
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_isNew ? 'Cylinder created successfully' : 'Cylinder updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving cylinder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text(_isNew ? 'New Cylinder' : 'Edit Cylinder'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveCylinder, tooltip: 'Save')],
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCylinder,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text(_isNew ? 'Create Cylinder' : 'Save Changes', style: const TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
