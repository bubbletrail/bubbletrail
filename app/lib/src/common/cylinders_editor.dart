import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import 'adaptive_modal.dart';
import 'measurement_editor.dart';

// A cylinder as returned by the editor. [originalIndex] is the position the
// cylinder held in the original list (null if newly added), which lets the
// caller remap gas-change events that reference cylinders by index.
class DiveCylinderEdit {
  final DiveCylinder cylinder;
  final int? originalIndex;

  const DiveCylinderEdit({required this.cylinder, required this.originalIndex});
}

// Shows an editor for a dive's cylinders and gas mixes. On mobile this is a
// bottom sheet, on desktop a modal dialog. Returns the updated list of
// cylinders, or null if the user cancelled.
Future<List<DiveCylinderEdit>?> showCylindersEditor({
  required BuildContext context,
  required List<DiveCylinder> cylinders,
  required List<Cylinder> availableCylinders,
}) {
  return showAdaptiveModal<List<DiveCylinderEdit>>(
    context: context,
    builder: (context) => _CylindersEditor(cylinders: cylinders, availableCylinders: availableCylinders),
  );
}

class _CylinderRow {
  final int? originalIndex;
  String cylinderId;
  Cylinder? cylinder;
  final TextEditingController oxygen;
  final TextEditingController helium;
  double? beginPressure;
  double? endPressure;

  _CylinderRow({
    required this.originalIndex,
    required this.cylinderId,
    required this.cylinder,
    required int oxygen,
    required int helium,
    this.beginPressure,
    this.endPressure,
  }) : oxygen = TextEditingController(text: oxygen.toString()),
       helium = TextEditingController(text: helium.toString());

  void dispose() {
    oxygen.dispose();
    helium.dispose();
  }

  DiveCylinderEdit toEdit() {
    return DiveCylinderEdit(
      cylinder: DiveCylinder(
        cylinderId: cylinderId,
        cylinder: cylinder,
        oxygen: (int.tryParse(oxygen.text) ?? 0) / 100,
        helium: (int.tryParse(helium.text) ?? 0) / 100,
        beginPressure: beginPressure,
        endPressure: endPressure,
      ),
      originalIndex: originalIndex,
    );
  }
}

class _CylindersEditor extends StatefulWidget {
  final List<DiveCylinder> cylinders;
  final List<Cylinder> availableCylinders;

  const _CylindersEditor({required this.cylinders, required this.availableCylinders});

  @override
  State<_CylindersEditor> createState() => _CylindersEditorState();
}

class _CylindersEditorState extends State<_CylindersEditor> {
  late final List<_CylinderRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.cylinders.indexed
        .map(
          (e) => _CylinderRow(
            originalIndex: e.$1,
            cylinderId: e.$2.cylinderId,
            cylinder: e.$2.hasCylinder() ? e.$2.cylinder : null,
            oxygen: (e.$2.oxygen * 100).round(),
            helium: (e.$2.helium * 100).round(),
            beginPressure: e.$2.hasBeginPressure() ? e.$2.beginPressure : null,
            endPressure: e.$2.hasEndPressure() ? e.$2.endPressure : null,
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _add() {
    final first = widget.availableCylinders.first;
    setState(() {
      _rows.add(_CylinderRow(originalIndex: null, cylinderId: first.id, cylinder: first, oxygen: 21, helium: 0));
    });
  }

  void _remove(int index) => setState(() => _rows.removeAt(index).dispose());

  List<DiveCylinderEdit> _result() => _rows.map((r) => r.toEdit()).toList();

  // The type options for a row: the globally available cylinders, plus the
  // row's own cylinder if it's no longer in that list.
  List<Cylinder> _optionsFor(_CylinderRow row) {
    final options = [...widget.availableCylinders];
    if (row.cylinder != null && !options.any((c) => c.id == row.cylinderId)) {
      options.insert(0, row.cylinder!);
    }
    return options;
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = widget.availableCylinders.isNotEmpty;
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Cylinders', style: Theme.of(context).textTheme.titleMedium),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  spacing: 8,
                  children: [
                    for (final (index, row) in _rows.indexed)
                      Card(
                        key: ObjectKey(row),
                        margin: .zero,
                        child: Padding(
                          padding: const .all(12),
                          child: Column(
                            crossAxisAlignment: .start,
                            spacing: 12,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _optionsFor(row).any((c) => c.id == row.cylinderId) ? row.cylinderId : null,
                                      decoration: const InputDecoration(labelText: 'Cylinder', border: OutlineInputBorder(), isDense: true),
                                      items: _optionsFor(row)
                                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.description.isNotEmpty ? c.description : 'Cylinder ${c.id}')))
                                          .toList(),
                                      onChanged: (id) {
                                        if (id == null) return;
                                        setState(() {
                                          row.cylinderId = id;
                                          row.cylinder = _optionsFor(row).firstWhere((c) => c.id == id);
                                        });
                                      },
                                    ),
                                  ),
                                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(index), tooltip: 'Remove'),
                                ],
                              ),
                              Row(
                                spacing: 16,
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: row.oxygen,
                                      decoration: const InputDecoration(labelText: 'Oxygen %', border: OutlineInputBorder(), isDense: true),
                                      keyboardType: const .numberWithOptions(decimal: true),
                                    ),
                                  ),
                                  Expanded(
                                    child: TextField(
                                      controller: row.helium,
                                      decoration: const InputDecoration(labelText: 'Helium %', border: OutlineInputBorder(), isDense: true),
                                      keyboardType: const .numberWithOptions(decimal: true),
                                    ),
                                  ),
                                ],
                              ),
                              PressureEditor(label: 'Start pressure', initialValue: row.beginPressure, onChanged: (value) => row.beginPressure = value),
                              PressureEditor(label: 'End pressure', initialValue: row.endPressure, onChanged: (value) => row.endPressure = value),
                            ],
                          ),
                        ),
                      ),
                    if (canAdd)
                      Align(
                        alignment: .centerLeft,
                        child: TextButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add cylinder')),
                      )
                    else
                      Text('No cylinders defined. Add cylinders in Equipment first.', style: TextStyle(color: Theme.of(context).hintColor)),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(context).pop(_result()), child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
