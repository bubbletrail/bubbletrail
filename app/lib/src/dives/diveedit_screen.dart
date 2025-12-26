import 'package:divestore/divestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../bloc/cylinderlist_bloc.dart';
import '../bloc/divedetails_bloc.dart';
import '../bloc/divelist_bloc.dart';
import '../common/common.dart';

/// Editable wrapper for a dive cylinder with mutable fields
class _EditableDiveCylinder {
  int cylinderId;
  Cylinder? cylinder;
  double? o2;
  double? he;
  double? start;
  double? end;

  _EditableDiveCylinder({required this.cylinderId, this.cylinder, this.o2, this.he, this.start, this.end});

  factory _EditableDiveCylinder.fromDiveCylinder(DiveCylinder dc) {
    return _EditableDiveCylinder(cylinderId: dc.cylinderId, cylinder: dc.cylinder, o2: dc.o2, he: dc.he, start: dc.start, end: dc.end);
  }

  DiveCylinder toDiveCylinder() {
    return DiveCylinder(cylinderId: cylinderId, cylinder: cylinder, o2: o2, he: he, start: start, end: end);
  }

  String get gasDescription {
    final o2Val = o2 ?? 21;
    final heVal = he ?? 0;
    if (heVal > 0) {
      return 'Tx${o2Val.round()}/${heVal.round()}';
    } else if (o2Val != 21) {
      return 'EAN${o2Val.round()}';
    }
    return 'Air';
  }
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
}

class DiveEditScreen extends StatefulWidget {
  const DiveEditScreen({super.key});

  @override
  State<DiveEditScreen> createState() => _DiveEditScreenState();
}

class _DiveEditScreenState extends State<DiveEditScreen> {
  late final Dive dive;
  late int _durationSeconds;
  late final TextEditingController _divemasterController;
  late final TextEditingController _buddiesController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late DateTime _selectedDateTime;
  late int? _rating;
  String? _selectedDivesiteId;
  late List<_EditableDiveCylinder> _cylinders;
  late List<_EditableGasChange> _gasChanges;

  @override
  void initState() {
    super.initState();
    dive = (context.read<DiveDetailsBloc>().state as DiveDetailsLoaded).dive;
    _selectedDateTime = dive.start;
    _durationSeconds = dive.duration;
    _divemasterController = TextEditingController(text: dive.divemaster ?? '');
    _buddiesController = TextEditingController(text: dive.buddies.join(', '));
    _notesController = TextEditingController(text: dive.notes ?? '');
    _tagsController = TextEditingController(text: dive.tags.join(', '));
    _rating = dive.rating;
    _selectedDivesiteId = dive.divesiteid;

    // Initialize cylinders from dive
    _cylinders = dive.cylinders.map((dc) => _EditableDiveCylinder.fromDiveCylinder(dc)).toList();

    // Extract gaschange events from all computer dives
    _gasChanges = [];
    for (final cd in dive.computerDives) {
      for (final event in cd.events) {
        if (event.type == SampleEventType.gasChange) {
          // The value field stores the cylinder index
          _gasChanges.add(_EditableGasChange(timeSeconds: event.time, cylinderIndex: event.value));
        }
      }
    }
    // Sort by time
    _gasChanges.sort((a, b) => a.timeSeconds.compareTo(b.timeSeconds));
  }

  @override
  void dispose() {
    _divemasterController.dispose();
    _buddiesController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
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
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_selectedDateTime));
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

  Future<void> _selectDivesite() async {
    final diveListState = context.read<DiveListBloc>().state;
    if (diveListState is! DiveListLoaded) return;

    final diveSites = diveListState.diveSites;
    if (diveSites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No dive sites available')));
      return;
    }

    final currentSite = _selectedDivesiteId != null ? diveListState.diveSitesByUuid[_selectedDivesiteId] : null;

    final result = await showSelectionDialog<Divesite>(
      context: context,
      title: 'Select Dive Site',
      items: diveSites,
      selectedItem: currentSite,
      noneOption: 'No site',
      itemBuilder: (site) => ListTile(leading: const Icon(Icons.location_on), title: Text(site.name)),
    );

    if (!result.cancelled) {
      setState(() {
        _selectedDivesiteId = result.value?.uuid;
      });
    }
  }

  Future<void> _addCylinder() async {
    final cylinderState = context.read<CylinderListBloc>().state;
    if (cylinderState is! CylinderListLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Loading cylinders...')));
      return;
    }

    final cylinders = cylinderState.cylinders;
    if (cylinders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No cylinders defined. Add cylinders in Equipment first.')));
      return;
    }

    final result = await showSelectionDialog<Cylinder>(
      context: context,
      title: 'Select Cylinder',
      items: cylinders,
      itemBuilder: (cyl) {
        final subtitle = [if (cyl.size != null) formatVolume(context, cyl.size!), if (cyl.workpressure != null) formatPressure(context, cyl.workpressure!)].join(' @ ');
        return ListTile(
          leading: const Icon(Icons.scuba_diving),
          title: Text(cyl.description ?? 'Cylinder ${cyl.id}'),
          subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
        );
      },
    );

    if (!result.cancelled && result.value != null) {
      setState(() {
        _cylinders.add(_EditableDiveCylinder(cylinderId: result.value!.id, cylinder: result.value, o2: 21, he: 0));
      });
    }
  }

  Future<void> _removeCylinder(int index) async {
    final hasGasChanges = _gasChanges.any((gc) => gc.cylinderIndex == index);
    if (hasGasChanges) {
      final confirmed = await showConfirmationDialog(
        context: context,
        title: 'Remove Cylinder',
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
    final o2Controller = TextEditingController(text: (cyl.o2 ?? 21).toString());
    final heController = TextEditingController(text: (cyl.he ?? 0).toString());
    final startController = TextEditingController(text: cyl.start?.toString() ?? '');
    final endController = TextEditingController(text: cyl.end?.toString() ?? '');

    final cylinderState = context.read<CylinderListBloc>().state;
    final availableCylinders = cylinderState is CylinderListLoaded ? cylinderState.cylinders : <Cylinder>[];
    Cylinder? selectedCylinder = cyl.cylinder;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${selectedCylinder?.description ?? 'Cylinder ${index + 1}'}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (availableCylinders.isNotEmpty) ...[
                DropdownButtonFormField<int>(
                  initialValue: selectedCylinder?.id,
                  decoration: const InputDecoration(labelText: 'Cylinder Type', border: OutlineInputBorder()),
                  items: availableCylinders.map((c) {
                    final subtitle = [if (c.size != null) formatVolume(context, c.size!), if (c.workpressure != null) formatPressure(context, c.workpressure!)].join(' @ ');
                    return DropdownMenuItem(value: c.id, child: Text(c.description ?? 'Cylinder ${c.id}${subtitle.isNotEmpty ? ' ($subtitle)' : ''}'));
                  }).toList(),
                  onChanged: (id) {
                    if (id != null) {
                      setDialogState(() {
                        selectedCylinder = availableCylinders.firstWhere((c) => c.id == id);
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
                      decoration: const InputDecoration(labelText: 'O2 %', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: heController,
                      decoration: const InputDecoration(labelText: 'He %', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      decoration: const InputDecoration(labelText: 'Start (bar)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      decoration: const InputDecoration(labelText: 'End (bar)', border: OutlineInputBorder()),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                ],
              ),
            ],
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
        cyl.o2 = double.tryParse(o2Controller.text);
        cyl.he = double.tryParse(heController.text);
        cyl.start = double.tryParse(startController.text);
        cyl.end = double.tryParse(endController.text);
      });
    }

    o2Controller.dispose();
    heController.dispose();
    startController.dispose();
    endController.dispose();
  }

  Future<void> _addGasChange(int cylinderIndex) async {
    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) => DurationPickerDialog(initialSeconds: 0, maxSeconds: _durationSeconds, title: 'Gas Change Time'),
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

  void _saveDive() {
    try {
      // Update dive properties
      dive.start = _selectedDateTime;
      dive.duration = _durationSeconds;
      dive.rating = _rating;
      dive.divesiteid = _selectedDivesiteId;
      dive.divemaster = _divemasterController.text.trim().isEmpty ? null : _divemasterController.text.trim();
      dive.notes = _notesController.text.trim().isEmpty ? null : _notesController.text.trim();

      // Update buddies
      final buddiesText = _buddiesController.text.trim();
      dive.buddies = buddiesText.isEmpty ? {} : buddiesText.split(',').map((b) => b.trim()).where((b) => b.isNotEmpty).toSet();

      // Update tags
      final tagsText = _tagsController.text.trim();
      dive.tags = tagsText.isEmpty ? {} : tagsText.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toSet();

      // Update cylinders
      dive.cylinders = _cylinders.map((c) => c.toDiveCylinder()).toList();

      // Update gas change events
      // Find existing "Manual Entry" computer dive or prepare to create one
      const manualEntryModel = 'Manual Entry';
      ComputerDive? manualCd = dive.computerDives.where((cd) => cd.model == manualEntryModel).firstOrNull;

      if (_gasChanges.isNotEmpty) {
        // Convert gas changes to events
        final events = _gasChanges.map((gc) {
          return SampleEvent(
            time: gc.timeSeconds,
            type: SampleEventType.gasChange,
            flags: const SampleEventFlags(0),
            value: gc.cylinderIndex,
          );
        }).toList();

        if (manualCd != null) {
          // Replace the manual computer dive with updated events
          dive.computerDives.remove(manualCd);
        }
        // Create new manual computer dive
        manualCd = ComputerDive(
          model: manualEntryModel,
          maxDepth: dive.maxDepth,
          avgDepth: dive.meanDepth,
          events: events,
        );
        dive.computerDives.add(manualCd);
      } else if (manualCd != null) {
        // No gas changes, remove manual computer dive if it only had events
        if (manualCd.samples.isEmpty) {
          dive.computerDives.remove(manualCd);
        }
      }

      // Send update event to bloc
      context.read<DiveDetailsBloc>().add(UpdateDiveDetails(dive));

      // Navigate back
      context.pop();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dive updated successfully')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving dive: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: Text('Edit Dive #${dive.number}'),
      actions: [IconButton(icon: const Icon(Icons.save), onPressed: _saveDive, tooltip: 'Save')],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Text(DateFormat.yMd().format(_selectedDateTime)),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: _selectTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Time', border: OutlineInputBorder(), suffixIcon: Icon(Icons.access_time)),
                      child: Text(DateFormat.Hms().format(_selectedDateTime)),
                    ),
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: _selectDuration,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder(), suffixIcon: Icon(Icons.timer)),
                child: Text(_durationFormatted),
              ),
            ),
            Builder(
              builder: (context) {
                final diveListState = context.watch<DiveListBloc>().state;
                final selectedSite = _selectedDivesiteId != null && diveListState is DiveListLoaded ? diveListState.diveSitesByUuid[_selectedDivesiteId] : null;

                return InkWell(
                  onTap: _selectDivesite,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Dive Site', border: OutlineInputBorder(), suffixIcon: Icon(Icons.location_on)),
                    child: Text(selectedSite?.name ?? 'No site selected', style: selectedSite == null ? TextStyle(color: Theme.of(context).hintColor) : null),
                  ),
                );
              },
            ),
            // Cylinders section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cylinders', style: Theme.of(context).textTheme.titleMedium),
                    IconButton(icon: const Icon(Icons.add), onPressed: _addCylinder, tooltip: 'Add cylinder'),
                  ],
                ),
                if (_cylinders.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No cylinders. Tap + to add one.', style: TextStyle(color: Theme.of(context).hintColor)),
                  )
                else
                  ...List.generate(_cylinders.length, (index) {
                    final cyl = _cylinders[index];
                    final gasChangesForCyl = _gasChanges.where((gc) => gc.cylinderIndex == index).toList();
                    final isFirstCylinder = index == 0;
                    final hasGasChangeAtStart = gasChangesForCyl.any((gc) => gc.timeSeconds == 0);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(cyl.cylinder?.description ?? 'Cylinder ${index + 1}', style: Theme.of(context).textTheme.titleSmall),
                                      Text(
                                        '${cyl.gasDescription}${cyl.start != null || cyl.end != null ? ' • ${cyl.start != null ? formatPressure(context, cyl.start!) : '?'} → ${cyl.end != null ? formatPressure(context, cyl.end!) : '?'}' : ''}',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: () => _editCylinderGas(index), tooltip: 'Edit gas mix'),
                                IconButton(icon: const Icon(Icons.delete, size: 20), onPressed: () => _removeCylinder(index), tooltip: 'Remove cylinder'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Gas changes:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            if (isFirstCylinder && !hasGasChangeAtStart)
                              Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Text('• Start of dive', style: Theme.of(context).textTheme.bodySmall),
                              ),
                            ...gasChangesForCyl.map((gc) {
                              final gcIndex = _gasChanges.indexOf(gc);
                              return Padding(
                                padding: const EdgeInsets.only(left: 8, top: 4),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        gc.timeSeconds == 0 ? '• Start of dive' : '• ${gc.timeFormatted} switch to this cylinder',
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ),
                                    InkWell(onTap: () => _removeGasChange(gcIndex), child: const Icon(Icons.close, size: 16)),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 4),
                            TextButton.icon(
                              onPressed: () => _addGasChange(index),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Gas Change'),
                              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rating', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return IconButton(
                      icon: Icon(_rating != null && starValue <= _rating! ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
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
            TextField(
              controller: _tagsController,
              decoration: const InputDecoration(labelText: 'Tags', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            TextField(
              controller: _divemasterController,
              decoration: const InputDecoration(labelText: 'Divemaster', border: OutlineInputBorder()),
            ),
            TextField(
              controller: _buddiesController,
              decoration: const InputDecoration(labelText: 'Buddies', border: OutlineInputBorder(), helperText: 'Comma-separated'),
              maxLines: 2,
            ),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
              maxLines: 6,
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveDive,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
