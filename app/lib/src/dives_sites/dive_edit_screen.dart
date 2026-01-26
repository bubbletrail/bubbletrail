import 'dart:math';

import 'package:chips_input_autocomplete/chips_input_autocomplete.dart';
import 'package:collection/collection.dart';
import 'package:btstore/btstore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as proto;

import '../equipment/cylinder_list_bloc.dart';
import '../equipment/equipment_list_bloc.dart';
import 'dive_details_bloc.dart';
import 'dive_list_bloc.dart';
import '../common/common.dart';

class DiveEditScreen extends StatefulWidget {
  const DiveEditScreen({super.key});

  @override
  State<DiveEditScreen> createState() => _DiveEditScreenState();
}

class _DiveEditScreenState extends State<DiveEditScreen> {
  late final Dive dive;
  late int _durationSeconds;
  late double _maxDepth;
  late final TextEditingController _divemasterController;
  late final TextEditingController _notesController;
  late final ChipsAutocompleteController _tagsController;
  late final ChipsAutocompleteController _buddiesController;
  late DateTime _selectedDateTime;
  late int? _rating;
  late List<_EditableDiveCylinder> _cylinders;
  late List<_EditableGasChange> _gasChanges;
  late List<_EditableWeightsystem> _weightsystems;
  late List<String> _availableTags;
  late List<String> _availableBuddies;
  late List<Site> _availableSites;
  late List<Cylinder> _availableCylinders;
  late List<Equipment> _availableEquipment;
  late List<Equipment> _selectedEquipment;

  Site? _selectedSite;

  @override
  void initState() {
    super.initState();

    final detailsState = context.read<DiveDetailsBloc>().state as DiveDetailsLoaded;
    dive = detailsState.dive;
    _selectedSite = detailsState.site;

    _selectedDateTime = dive.start.toDateTime();
    _durationSeconds = dive.duration;
    _maxDepth = dive.maxDepth;
    _divemasterController = TextEditingController(text: dive.divemaster);
    _notesController = TextEditingController(text: dive.notes);
    _tagsController = ChipsAutocompleteController();
    _buddiesController = ChipsAutocompleteController();
    _rating = dive.hasRating() ? dive.rating : null;

    final diveListState = context.read<DiveListBloc>().state as DiveListLoaded;
    _availableTags = diveListState.tags.sorted((a, b) => a.compareTo(b));
    _availableBuddies = diveListState.buddies.sorted((a, b) => a.compareTo(b));
    _availableSites = diveListState.sites;

    final cylinderListState = context.read<CylinderListBloc>().state as CylinderListLoaded;
    _availableCylinders = cylinderListState.cylinders;

    final equipmentListState = context.read<EquipmentListBloc>().state;
    if (equipmentListState is EquipmentListLoaded) {
      _availableEquipment = equipmentListState.equipment;
    } else {
      _availableEquipment = [];
    }
    _selectedEquipment = dive.equipment.toList();

    // Initialize cylinders from dive
    _cylinders = dive.cylinders.map((dc) => _EditableDiveCylinder.fromDiveCylinder(dc)).toList();

    // Initialize weightsystems from dive
    _weightsystems = dive.weightsystems.map((ws) => _EditableWeightsystem.fromWeightsystem(ws)).toList();

    // Extract gas change events
    _gasChanges = [];
    for (final event in dive.events) {
      if (event.type == .SAMPLE_EVENT_TYPE_GAS_CHANGE) {
        // The value field stores the cylinder index
        _gasChanges.add(_EditableGasChange(timeSeconds: event.time, cylinderIndex: event.value));
      }
    }
    // Sort by time
    _gasChanges.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
  }

  @override
  void dispose() {
    _divemasterController.dispose();
    _notesController.dispose();
    // _tagsController.dispose();
    // _buddiesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDateTime, firstDate: DateTime(1900), lastDate: DateTime(2100));
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(picked.year, picked.month, picked.day, _selectedDateTime.hour, _selectedDateTime.minute, _selectedDateTime.second);
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: .fromDateTime(_selectedDateTime));
    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(_selectedDateTime.year, _selectedDateTime.month, _selectedDateTime.day, picked.hour, picked.minute, 0);
      });
    }
  }

  Future<void> _selectDuration() async {
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => DurationPickerDialog(initialSeconds: _durationSeconds),
    );

    if (result != null) {
      setState(() {
        _durationSeconds = result;
      });
    }
  }

  String get _durationFormatted {
    final minutes = _durationSeconds ~/ 60;
    final seconds = _durationSeconds % 60;
    if (seconds == 0) {
      return '$minutes min';
    }
    return '$minutes:${seconds.toString().padLeft(2, '0')} min';
  }

  Future<void> _selectSite() async {
    if (_availableSites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No dive sites available')));
      return;
    }

    final result = await showSelectionDialog<Site>(
      context: context,
      title: 'Select dive site',
      items: _availableSites,
      selectedItem: _selectedSite,
      noneOption: 'No site',
      itemBuilder: (site) => ListTile(leading: const Icon(Icons.location_on_outlined), title: Text(site.name)),
    );

    if (!result.cancelled) {
      setState(() {
        _selectedSite = result.value;
      });
    }
  }

  Future<void> _addCylinder() async {
    if (_availableCylinders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cylinders defined. Add cylinders in Equipment first.')));
      return;
    }

    final result = await showSelectionDialog<Cylinder>(
      context: context,
      title: 'Select cylinder',
      items: _availableCylinders,
      itemBuilder: (cyl) {
        return ListTile(leading: const Icon(Icons.science_outlined), title: Text(cyl.description.isNotEmpty ? cyl.description : 'Cylinder ${cyl.id}'));
      },
    );

    if (!result.cancelled && result.value != null) {
      setState(() {
        _cylinders.add(_EditableDiveCylinder(cylinderId: result.value!.id, cylinder: result.value, oxygen: 21, helium: 0));
      });
    }
  }

  Future<void> _removeCylinder(int index) async {
    final hasGasChanges = _gasChanges.any((gc) => gc.cylinderIndex == index);
    if (hasGasChanges) {
      final confirmed = await showConfirmationDialog(
        context: context,
        title: 'Remove cylinder',
        message: 'This cylinder has gas change events. Removing it will also remove those events.',
        confirmText: 'Remove',
        isDestructive: true,
      );
      if (confirmed) {
        _doRemoveCylinder(index);
      }
    } else {
      _doRemoveCylinder(index);
    }
  }

  void _doRemoveCylinder(int index) {
    setState(() {
      _cylinders.removeAt(index);
      // Remove gas changes for this cylinder and reindex others
      _gasChanges.removeWhere((gc) => gc.cylinderIndex == index);
      for (final gc in _gasChanges) {
        if (gc.cylinderIndex > index) {
          gc.cylinderIndex--;
        }
      }
    });
  }

  Future<void> _editCylinderGas(int index) async {
    final cyl = _cylinders[index];
    final o2Controller = TextEditingController(text: cyl.oxygen.toString());
    final heController = TextEditingController(text: cyl.helium.toString());

    Cylinder? selectedCylinder = cyl.cylinder;

    // Track pressure values in metric (bar)
    double? startPressure = cyl.beginPressure?.toDouble();
    double? endPressure = cyl.endPressure?.toDouble();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${selectedCylinder?.description ?? 'Cylinder ${index + 1}'}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: .min,
              children: [
                if (_availableCylinders.isNotEmpty) ...[
                  DropdownButtonFormField<String>(
                    initialValue: selectedCylinder?.id,
                    decoration: const InputDecoration(labelText: 'Cylinder type', border: OutlineInputBorder()),
                    items: _availableCylinders.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.description.isNotEmpty ? c.description : 'Cylinder ${c.id}'));
                    }).toList(),
                    onChanged: (id) {
                      if (id != null) {
                        setDialogState(() {
                          selectedCylinder = _availableCylinders.firstWhere((c) => c.id == id);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: o2Controller,
                        decoration: const InputDecoration(labelText: 'Oxygen %', border: OutlineInputBorder()),
                        keyboardType: const .numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: heController,
                        decoration: const InputDecoration(labelText: 'Helium %', border: OutlineInputBorder()),
                        keyboardType: const .numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                PressureEditor(label: 'Start pressure', initialValue: startPressure, onChanged: (value) => startPressure = value),
                const SizedBox(height: 16),
                PressureEditor(label: 'End pressure', initialValue: endPressure, onChanged: (value) => endPressure = value),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
            TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
          ],
        ),
      ),
    );

    if (result == true) {
      setState(() {
        if (selectedCylinder != null) {
          cyl.cylinderId = selectedCylinder!.id;
          cyl.cylinder = selectedCylinder;
        }
        cyl.oxygen = int.tryParse(o2Controller.text) ?? 0;
        cyl.helium = int.tryParse(heController.text) ?? 0;
        cyl.beginPressure = startPressure;
        cyl.endPressure = endPressure;
      });
    }

    o2Controller.dispose();
    heController.dispose();
  }

  Future<void> _addGasChange(int cylinderIndex) async {
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => DurationPickerDialog(initialSeconds: 0, maxSeconds: _durationSeconds, title: 'Gas change time'),
    );

    if (result != null) {
      setState(() {
        _gasChanges.add(_EditableGasChange(timeSeconds: result, cylinderIndex: cylinderIndex));
        _gasChanges.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
      });
    }
  }

  void _removeGasChange(int index) {
    setState(() {
      _gasChanges.removeAt(index);
    });
  }

  static const _defaultWeightTypes = ['Backplate', 'Belt', 'Harness', 'Integrated', 'Trim'];

  void _addWeightsystem() {
    setState(() {
      _weightsystems.add(_EditableWeightsystem(description: '', weight: null));
    });
    // Immediately open the edit dialog for the new weight
    _editWeightsystem(_weightsystems.length - 1);
  }

  void _removeWeightsystem(int index) {
    setState(() {
      _weightsystems.removeAt(index);
    });
  }

  Future<void> _editWeightsystem(int index) async {
    final ws = _weightsystems[index];
    final descController = TextEditingController(text: ws.description);

    // Track weight in metric (kg)
    double? weight = ws.weight;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(ws.description.isNotEmpty ? 'Edit ${ws.description}' : 'Add weight'),
        content: Column(
          mainAxisSize: .min,
          children: [
            Autocomplete<String>(
              initialValue: TextEditingValue(text: ws.description),
              optionsBuilder: (textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return _defaultWeightTypes;
                }
                return _defaultWeightTypes.where((type) => type.toLowerCase().contains(textEditingValue.text.toLowerCase()));
              },
              onSelected: (selection) {
                descController.text = selection;
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                // Sync the autocomplete controller with our descController
                controller.text = descController.text;
                controller.addListener(() {
                  descController.text = controller.text;
                });
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                  textCapitalization: .words,
                );
              },
            ),
            const SizedBox(height: 16),
            WeightEditor(label: 'Weight', initialValue: weight, onChanged: (value) => weight = value),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Save')),
        ],
      ),
    );

    if (result == true) {
      setState(() {
        ws.description = descController.text.trim();
        ws.weight = weight;
      });
    } else if (ws.description.isEmpty && ws.weight == null) {
      // User cancelled on a new empty weight, remove it
      setState(() {
        _weightsystems.removeAt(index);
      });
    }

    descController.dispose();
  }

  Future<void> _selectEquipment() async {
    final result = await showEquipmentSelectionDialog(context: context, allEquipment: _availableEquipment, selectedEquipment: _selectedEquipment);
    if (result != null) {
      setState(() {
        _selectedEquipment = result;
      });
    }
  }

  void _saveDive() {
    final upd = dive.rebuild((dive) {
      // Update dive properties
      dive.start = proto.Timestamp.fromDateTime(_selectedDateTime);

      if (dive.logs.isEmpty || dive.logs.first.isSynthetic) {
        // Manual dive, we should (re)create a log
        dive.logs.clear();
        dive.logs.add(_manualLog(_selectedDateTime, _durationSeconds, _maxDepth));
      }

      if (_rating != null) {
        dive.rating = _rating!;
      } else {
        dive.clearRating();
      }

      dive.siteId = _selectedSite?.id ?? '';
      dive.divemaster = _divemasterController.text.trim();
      dive.notes = _notesController.text.trim();

      // Update buddies
      dive.buddies.clear();
      dive.buddies.addAll(_buddiesController.chips);

      // Update tags
      dive.tags.clear();
      dive.tags.addAll(_tagsController.chips);

      // Update cylinders
      dive.cylinders.clear();
      dive.cylinders.addAll(_cylinders.map((c) => c.toDiveCylinder()));

      // Update weight systems
      dive.weightsystems.clear();
      dive.weightsystems.addAll(_weightsystems.map((ws) => ws.toWeightsystem()));

      // Update equipment
      dive.equipment.clear();
      dive.equipment.addAll(_selectedEquipment);

      // Update gas change events
      dive.events.clear();
      dive.events.addAll(_gasChanges.map((gs) => gs.toSampleEvent()));

      // Clear tissues, since times and gases may have changed
      dive.clearStartTissues();
      dive.clearEndTissues();
      dive.clearEndSurfGf();

      // Update calculated info.
      dive.recalculateMetadata();
    });

    // Send update event to bloc
    context.read<DiveDetailsBloc>().add(DiveDetailsEvent.saveAndClose(upd));
  }

  void _saveAndPop() {
    _saveDive();
    context.pop();
  }

  void _cancel() {
    context.pop();
  }

  String _equipmentTitle(Equipment item) {
    if (item.name.isNotEmpty) {
      return item.name;
    }
    if (item.manufacturer.isNotEmpty && item.type.isNotEmpty) {
      return '${item.manufacturer} ${item.type}';
    }
    if (item.type.isNotEmpty) {
      return item.type;
    }
    return 'Equipment #${item.id}';
  }

  @override
  Widget build(BuildContext context) {
    final canEditDepthDuration = dive.logs.isEmpty || dive.logs.first.isSynthetic;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _saveAndPop();
        }
      },
      child: ScreenScaffold(
        title: Text('Edit dive #${dive.number}'),
        actions: [IconButton(icon: const Icon(Icons.close), onPressed: _cancel, tooltip: 'Discard changes')],
        body: SingleChildScrollView(
          padding: const .all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 16,
            children: [
              Row(
                spacing: 16,
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder(), suffixIcon: Icon(Icons.calendar_today)),
                        child: DateText(_selectedDateTime),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                        child: TimeText(_selectedDateTime),
                      ),
                    ),
                  ),
                ],
              ),
              if (canEditDepthDuration)
                Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _selectDuration,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder(), suffixIcon: Icon(Icons.timer)),
                          child: Text(_durationFormatted),
                        ),
                      ),
                    ),
                    Expanded(
                      child: DepthEditor(
                        label: 'Max depth',
                        initialValue: _maxDepth,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _maxDepth = val;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              Builder(
                builder: (context) {
                  return InkWell(
                    onTap: _selectSite,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Dive site', border: OutlineInputBorder(), suffixIcon: Icon(Icons.location_on_outlined)),
                      child: Text(
                        _selectedSite?.name ?? 'No site selected',
                        style: _selectedSite == null ? TextStyle(color: Theme.of(context).hintColor) : null,
                      ),
                    ),
                  );
                },
              ),
              // Cylinders section
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text('Cylinders', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(icon: const Icon(Icons.add), onPressed: _addCylinder, tooltip: 'Add cylinder'),
                    ],
                  ),
                  if (_cylinders.isEmpty)
                    Padding(
                      padding: const .symmetric(vertical: 8),
                      child: Text('No cylinders. Tap + to add one.', style: TextStyle(color: Theme.of(context).hintColor)),
                    )
                  else
                    ...List.generate(_cylinders.length, (index) {
                      final cyl = _cylinders[index];
                      final gasChangesForCyl = _gasChanges.where((gc) => gc.cylinderIndex == index).toList();

                      return Card(
                        margin: const .only(bottom: 8),
                        child: Padding(
                          padding: const .all(12),
                          child: Column(
                            crossAxisAlignment: .start,
                            children: [
                              CylinderTile(
                                index: index,
                                description: cyl.cylinder?.description ?? 'Cylinder ${index + 1}',
                                oxygenPct: cyl.oxygen,
                                heliumPct: cyl.helium,
                                beginPressure: cyl.beginPressure ?? 0,
                                endPressure: cyl.endPressure ?? 0,
                                trailing: Row(
                                  mainAxisSize: .min,
                                  children: [
                                    IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editCylinderGas(index), tooltip: 'Edit gas mix'),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline, size: 18),
                                      onPressed: () => _removeCylinder(index),
                                      tooltip: 'Remove cylinder',
                                    ),
                                  ],
                                ),
                                contentPadding: .zero,
                              ),
                              const SizedBox(height: 8),
                              Text('Gas changes:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: .bold)),
                              ...gasChangesForCyl.map((gc) {
                                final gcIndex = _gasChanges.indexOf(gc);
                                return Padding(
                                  padding: const .only(left: 8, top: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          gc.timeSeconds == 0 ? '• Start of dive' : '• ${gc.timeFormatted} switch to this cylinder',
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ),
                                      InkWell(onTap: () => _removeGasChange(gcIndex), child: const Icon(Icons.close, size: 14)),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 4),
                              TextButton.icon(
                                onPressed: () => _addGasChange(index),
                                icon: const Icon(Icons.add, size: 14),
                                label: const Text('Add gas change'),
                                style: TextButton.styleFrom(padding: .zero, minimumSize: const Size(0, 32)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
              // Weight systems section
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text('Weight Systems', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(icon: const Icon(Icons.add), onPressed: _addWeightsystem, tooltip: 'Add weight'),
                    ],
                  ),
                  if (_weightsystems.isEmpty)
                    Padding(
                      padding: const .symmetric(vertical: 8),
                      child: Text('No weight systems. Tap + to add one.', style: TextStyle(color: Theme.of(context).hintColor)),
                    )
                  else
                    ...List.generate(_weightsystems.length, (index) {
                      final ws = _weightsystems[index];
                      return Card(
                        margin: const .only(bottom: 8),
                        child: Padding(
                          padding: const .all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  children: [
                                    Text(ws.description.isNotEmpty ? ws.description : 'Weight ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                                    if (ws.weight != null) WeightText(ws.weight!, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editWeightsystem(index), tooltip: 'Edit'),
                              IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => _removeWeightsystem(index), tooltip: 'Remove'),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
              // Equipment section
              Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text('Equipment', style: Theme.of(context).textTheme.titleMedium),
                      IconButton(icon: const Icon(Icons.edit), onPressed: _selectEquipment, tooltip: 'Select equipment'),
                    ],
                  ),
                  if (_selectedEquipment.isEmpty)
                    Padding(
                      padding: const .symmetric(vertical: 8),
                      child: Text('No equipment selected', style: TextStyle(color: Theme.of(context).hintColor)),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: _selectedEquipment
                          .map(
                            (e) => Chip(
                              avatar: EquipmentIcons.icon(EquipmentIcons.forType(e.type), color: Theme.of(context).colorScheme.primary),
                              label: Text(_equipmentTitle(e)),
                            ),
                          )
                          .toList(),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Text('Rating', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: .generate(5, (index) {
                      final starValue = index + 1;
                      return IconButton(
                        icon: Icon(_rating != null && starValue <= _rating! ? Icons.star : Icons.star_border, color: Colors.amber, size: 28),
                        onPressed: () {
                          setState(() {
                            _rating = starValue == _rating ? null : starValue;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              Builder(
                builder: (context) {
                  return ChipsInputAutocomplete(
                    controller: _tagsController,
                    options: _availableTags,
                    initialChips: dive.tags.toList(),
                    decorationTextField: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder()),
                    addChipOnSelection: true,
                    placeChipsSectionAbove: false,
                    paddingInsideWidgetContainer: .zero,
                    secondaryTheme: true,
                  );
                },
              ),
              TextField(
                controller: _divemasterController,
                decoration: const InputDecoration(labelText: 'Divemaster', border: OutlineInputBorder()),
                textCapitalization: .words,
              ),
              Builder(
                builder: (context) {
                  return ChipsInputAutocomplete(
                    controller: _buddiesController,
                    options: _availableBuddies,
                    initialChips: dive.buddies.toList(),
                    decorationTextField: const InputDecoration(labelText: 'Buddies', border: OutlineInputBorder()),
                    addChipOnSelection: true,
                    placeChipsSectionAbove: false,
                    paddingInsideWidgetContainer: .zero,
                    secondaryTheme: true,
                    createCharacters: [','],
                  );
                },
              ),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
                maxLines: 6,
                autocorrect: true,
                textCapitalization: .sentences,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Editable wrapper for a dive cylinder with mutable fields
class _EditableDiveCylinder {
  String cylinderId;
  Cylinder? cylinder;
  int oxygen;
  int helium;
  double? beginPressure;
  double? endPressure;

  _EditableDiveCylinder({required this.cylinderId, this.cylinder, required this.oxygen, required this.helium, this.beginPressure, this.endPressure});

  factory _EditableDiveCylinder.fromDiveCylinder(DiveCylinder dc) {
    return _EditableDiveCylinder(
      cylinderId: dc.cylinderId,
      cylinder: dc.hasCylinder() ? dc.cylinder : null,
      oxygen: (dc.oxygen * 100).toInt(),
      helium: (dc.helium * 100).toInt(),
      beginPressure: dc.beginPressure,
      endPressure: dc.endPressure,
    );
  }

  DiveCylinder toDiveCylinder() {
    return DiveCylinder(
      cylinderId: cylinderId,
      cylinder: cylinder,
      oxygen: oxygen.toDouble() / 100,
      helium: helium.toDouble() / 100,
      beginPressure: beginPressure?.toDouble(),
      endPressure: endPressure?.toDouble(),
    );
  }

  String get gasDescription => formatGasPercentage(oxygen, helium);
}

/// Editable gas change event
class _EditableGasChange {
  int timeSeconds;
  int cylinderIndex;

  _EditableGasChange({required this.timeSeconds, required this.cylinderIndex});

  String get timeFormatted {
    final minutes = timeSeconds ~/ 60;
    final seconds = timeSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  SampleEvent toSampleEvent() {
    return SampleEvent(type: .SAMPLE_EVENT_TYPE_GAS_CHANGE, time: timeSeconds, value: cylinderIndex);
  }
}

/// Editable wrapper for a weight system
class _EditableWeightsystem {
  String description;
  double? weight;

  _EditableWeightsystem({required this.description, this.weight});

  factory _EditableWeightsystem.fromWeightsystem(Weightsystem ws) {
    return _EditableWeightsystem(description: ws.description, weight: ws.hasWeight() ? ws.weight : null);
  }

  Weightsystem toWeightsystem() {
    return Weightsystem(description: description, weight: weight);
  }
}

Log _manualLog(DateTime start, int durationSeconds, double maxDepth) {
  final samples = <LogSample>[];

  // We descend at 18 m/min
  final t0 = (maxDepth / 18 * 60).roundToDouble();
  // We ascend to half depth at 9 m/min
  final t2 = (maxDepth / 2 / 9 * 60).roundToDouble();
  // We ascend from there to the surface at 3 m/min
  final t3 = (maxDepth / 2 / 3 * 60).roundToDouble();
  // The bottom time is what remains, but at least zero. If this was a very
  // odd bounce dive we might overshoot the actual duration in the graph,
  // but whatever.
  final t1 = max(0.0, durationSeconds - t0 - t2 - t3);

  samples.add(LogSample(time: 0, depth: 0));
  samples.add(LogSample(time: 5, depth: 0.1));
  samples.add(LogSample(time: t0, depth: maxDepth));
  samples.add(LogSample(time: t0 + t1, depth: maxDepth));
  samples.add(LogSample(time: t0 + t1 + t2, depth: maxDepth / 2));
  samples.add(LogSample(time: t0 + t1 + t2 + t3, depth: 0.1));
  samples.add(LogSample(time: t0 + t1 + t2 + t3 + 5, depth: 0));

  return Log(
    model: 'Bubbletrail', //marks the log as synthetic
    dateTime: proto.Timestamp.fromDateTime(start),
    diveTime: durationSeconds,
    maxDepth: maxDepth,
    samples: samples,
  );
}
