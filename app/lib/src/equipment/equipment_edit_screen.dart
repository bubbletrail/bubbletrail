import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;

import 'equipment_details_bloc.dart';
import '../common/common.dart';

class EquipmentEditScreen extends StatefulWidget {
  const EquipmentEditScreen({super.key});

  @override
  State<EquipmentEditScreen> createState() => _EquipmentEditScreenState();
}

class _EquipmentEditScreenState extends State<EquipmentEditScreen> {
  late final Equipment _originalEquipment;
  late final bool _isNew;
  late final TextEditingController _typeController;
  late final TextEditingController _manufacturerController;
  late final TextEditingController _nameController;
  late final TextEditingController _serialController;
  late final TextEditingController _priceController;

  double? _weight;
  DateTime? _purchaseDate;
  DateTime? _nextService;

  static const _equipmentTypes = [
    'BCD',
    'Regulator',
    'Wetsuit',
    'Drysuit',
    'Mask',
    'Fins',
    'Computer',
    'Light',
    'Camera',
    'SMB',
    'Reel',
    'Weight belt',
    'Hood',
    'Gloves',
    'Boots',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<EquipmentDetailsBloc>().state as EquipmentDetailsLoaded;
    _originalEquipment = state.equipment;
    _isNew = state.isNew;

    _typeController = TextEditingController(text: _originalEquipment.type);
    _manufacturerController = TextEditingController(text: _originalEquipment.manufacturer);
    _nameController = TextEditingController(text: _originalEquipment.name);
    _serialController = TextEditingController(text: _originalEquipment.serial);
    _priceController = TextEditingController(text: _originalEquipment.hasPurchasePrice() ? formatDisplayValue(_originalEquipment.purchasePrice) : '');

    _weight = _originalEquipment.hasWeight() ? _originalEquipment.weight : null;
    _purchaseDate = _originalEquipment.hasPurchaseDate() ? _originalEquipment.purchaseDate.toDateTime() : null;
    _nextService = _originalEquipment.hasNextService() ? _originalEquipment.nextService.toDateTime() : null;
  }

  @override
  void dispose() {
    _typeController.dispose();
    _manufacturerController.dispose();
    _nameController.dispose();
    _serialController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool _saveEquipment() {
    final type = _typeController.text.trim();
    final manufacturer = _manufacturerController.text.trim();
    final name = _nameController.text.trim();
    final serial = _serialController.text.trim();
    final price = double.tryParse(_priceController.text.trim());

    final updatedEquipment = Equipment(
      id: _originalEquipment.id,
      type: type.isEmpty ? null : type,
      manufacturer: manufacturer.isEmpty ? null : manufacturer,
      name: name.isEmpty ? null : name,
      serial: serial.isEmpty ? null : serial,
      purchasePrice: price,
      weight: _weight,
      purchaseDate: _purchaseDate != null ? proto.Timestamp.fromDateTime(_purchaseDate!) : null,
      nextService: _nextService != null ? proto.Timestamp.fromDateTime(_nextService!) : null,
    );

    context.read<EquipmentDetailsBloc>().add(EquipmentDetailsEvent.updateAndClose(updatedEquipment));
    return true;
  }

  void _cancel() {
    context.pop();
  }

  Future<void> _selectPurchaseDate() async {
    final date = await showDatePicker(context: context, initialDate: _purchaseDate ?? DateTime.now(), firstDate: DateTime(1990), lastDate: DateTime.now());
    if (date != null) {
      setState(() => _purchaseDate = date);
    }
  }

  Future<void> _selectNextService() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _nextService ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (date != null) {
      setState(() => _nextService = date);
    }
  }

  PopupMenuButton<String> _popupMenuActions() {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete Equipment'),
              content: const Text('Are you sure you want to delete this equipment?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
              ],
            ),
          );

          if (confirmed == true && mounted) {
            context.read<EquipmentDetailsBloc>().add(EquipmentDetailsEvent.deleteAndClosed(_originalEquipment.id));
          }
        }
      },
      itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete equipment'))],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveEquipment();
        }
      },
      child: BlocListener<EquipmentDetailsBloc, EquipmentDetailsState>(
        listener: (context, state) {
          if (state is EquipmentDetailsClosed) context.pop();
        },
        child: ScreenScaffold(
          title: Text(_isNew ? 'New Equipment' : 'Edit Equipment'),
          actions: [
            if (!_isNew) _popupMenuActions(),
            IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes'),
          ],
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTypeField(),
                TextField(
                  controller: _manufacturerController,
                  decoration: const InputDecoration(labelText: 'Manufacturer', border: OutlineInputBorder()),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Model/Name', border: OutlineInputBorder()),
                ),
                TextField(
                  controller: _serialController,
                  decoration: const InputDecoration(labelText: 'Serial Number', border: OutlineInputBorder()),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Purchase Price', border: OutlineInputBorder()),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                WeightEditor(label: 'Weight', initialValue: _weight, onChanged: (value) => _weight = value),
                Row(
                  spacing: 16,
                  children: [
                    Expanded(child: _buildDateField('Purchase Date', _purchaseDate, _selectPurchaseDate, () => setState(() => _purchaseDate = null))),
                    Expanded(child: _buildDateField('Next Service', _nextService, _selectNextService, () => setState(() => _nextService = null))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeField() {
    return Autocomplete<String>(
      initialValue: TextEditingValue(text: _typeController.text),
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return _equipmentTypes;
        }
        return _equipmentTypes.where((type) => type.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (selection) {
        _typeController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder(), hintText: 'e.g., BCD, Regulator, Wetsuit'),
          onChanged: (value) => _typeController.text = value,
        );
      },
    );
  }

  Widget _buildDateField(String label, DateTime? value, VoidCallback onTap, VoidCallback onClear) {
    final formatted = value != null ? DateFormat.yMMMd().format(value) : null;
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: value != null ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear) : null,
        ),
        child: Text(formatted ?? 'Not set', style: formatted == null ? TextStyle(color: Theme.of(context).hintColor) : null),
      ),
    );
  }
}
