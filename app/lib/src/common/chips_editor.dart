import 'package:flutter/material.dart';

import 'adaptive_modal.dart';

// Shows an editor for a set of string values (tags, buddies, ...). On mobile
// this is a bottom sheet, on desktop a modal dialog. Existing values can be
// toggled on/off and new ones entered via the text field. Returns the updated
// list of selected values, or null if the user cancelled.
Future<List<String>?> showChipsEditor({
  required BuildContext context,
  required String title,
  required String addLabel,
  required Iterable<String> selectedValues,
  required Iterable<String> availableValues,
  TextCapitalization textCapitalization = TextCapitalization.none,
  List<String> createCharacters = const [],
}) {
  return showAdaptiveModal<List<String>>(
    context: context,
    builder: (context) => _ChipsEditor(
      title: title,
      addLabel: addLabel,
      selectedValues: selectedValues,
      availableValues: availableValues,
      textCapitalization: textCapitalization,
      createCharacters: createCharacters,
    ),
  );
}

class _ChipsEditor extends StatefulWidget {
  const _ChipsEditor({
    required this.title,
    required this.addLabel,
    required this.selectedValues,
    required this.availableValues,
    required this.textCapitalization,
    required this.createCharacters,
  });

  final String title;
  final String addLabel;
  final Iterable<String> selectedValues;
  final Iterable<String> availableValues;
  final TextCapitalization textCapitalization;
  // Characters that, when typed, commit the current text as a new value (e.g. ',').
  final List<String> createCharacters;

  @override
  State<_ChipsEditor> createState() => _ChipsEditorState();
}

class _ChipsEditorState extends State<_ChipsEditor> {
  late final Set<String> _selected;
  // All values we can offer as toggleable chips: the union of what's available
  // globally and what's already selected, kept sorted for a stable order.
  late final List<String> _options;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = widget.selectedValues.toSet();
    _options = {...widget.availableValues, ...widget.selectedValues}.toList()..sort(_caseInsensitive);
    _controller.addListener(_handleCreateCharacters);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static int _caseInsensitive(String a, String b) => a.toLowerCase().compareTo(b.toLowerCase());

  void _handleCreateCharacters() {
    if (widget.createCharacters.isEmpty) return;
    final text = _controller.text;
    for (final ch in widget.createCharacters) {
      if (text.contains(ch)) {
        _addValue(text.replaceAll(ch, ''));
        return;
      }
    }
  }

  void _addValue(String value) {
    final v = value.trim();
    if (v.isEmpty) {
      _controller.clear();
      return;
    }
    setState(() {
      _selected.add(v);
      if (!_options.contains(v)) {
        _options.add(v);
        _options.sort(_caseInsensitive);
      }
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const .all(16.0),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          spacing: 16,
          children: [
            Text(widget.title, style: Theme.of(context).textTheme.titleMedium),
            if (_options.isNotEmpty)
              Flexible(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: _options
                        .map(
                          (value) => FilterChip(
                            label: Text(value),
                            selected: _selected.contains(value),
                            onSelected: (sel) {
                              setState(() {
                                if (sel) {
                                  _selected.add(value);
                                } else {
                                  _selected.remove(value);
                                }
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: widget.addLabel,
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(icon: const Icon(Icons.add), onPressed: () => _addValue(_controller.text), tooltip: widget.addLabel),
              ),
              textCapitalization: widget.textCapitalization,
              autocorrect: false,
              onSubmitted: _addValue,
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(context).pop(_selected.toList()..sort(_caseInsensitive)), child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
