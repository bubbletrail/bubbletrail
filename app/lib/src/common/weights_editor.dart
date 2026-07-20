import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import 'adaptive_modal.dart';
import 'measurement_editor.dart';

// Shows an editor for a dive's weight systems. On mobile this is a bottom
// sheet, on desktop a modal dialog. Returns the updated list of weight
// systems, or null if the user cancelled.
Future<List<Weightsystem>?> showWeightsEditor({required BuildContext context, required Iterable<Weightsystem> weights}) {
  return showAdaptiveModal<List<Weightsystem>>(
    context: context,
    builder: (context) => _WeightsEditor(weights: weights.toList()),
  );
}

// Suggested weight system types, offered as quick-select chips.
const _defaultWeightTypes = ['Backplate', 'Belt', 'Harness', 'Integrated', 'Trim'];

class _WeightRow {
  final TextEditingController description;
  double? weight;

  _WeightRow({required String description, this.weight}) : description = TextEditingController(text: description);

  void dispose() => description.dispose();
}

class _WeightsEditor extends StatefulWidget {
  final List<Weightsystem> weights;

  const _WeightsEditor({required this.weights});

  @override
  State<_WeightsEditor> createState() => _WeightsEditorState();
}

class _WeightsEditorState extends State<_WeightsEditor> {
  late final List<_WeightRow> _rows;

  @override
  void initState() {
    super.initState();
    _rows = widget.weights.map((w) => _WeightRow(description: w.description, weight: w.hasWeight() ? w.weight : null)).toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _add() => setState(() => _rows.add(_WeightRow(description: '')));

  void _remove(int index) => setState(() => _rows.removeAt(index).dispose());

  List<Weightsystem> _result() => _rows.map((r) => Weightsystem(description: r.description.text.trim(), weight: r.weight)).toList();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 16,
          children: [
            Text('Weights', style: Theme.of(context).textTheme.titleMedium),
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
                            spacing: 8,
                            children: [
                              Row(
                                spacing: 8,
                                children: [
                                  // Editable dropdown: pick a default type or type a custom one.
                                  Expanded(
                                    child: DropdownMenu<String>(
                                      controller: row.description,
                                      expandedInsets: .zero,
                                      requestFocusOnTap: true,
                                      enableFilter: true,
                                      label: const Text('Type'),
                                      dropdownMenuEntries: _defaultWeightTypes.map((type) => DropdownMenuEntry(value: type, label: type)).toList(),
                                    ),
                                  ),
                                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => _remove(index), tooltip: 'Remove'),
                                ],
                              ),
                              WeightEditor(label: 'Weight', initialValue: row.weight, onChanged: (value) => row.weight = value),
                            ],
                          ),
                        ),
                      ),
                    Align(
                      alignment: .centerLeft,
                      child: TextButton.icon(onPressed: _add, icon: const Icon(Icons.add), label: const Text('Add weight')),
                    ),
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
