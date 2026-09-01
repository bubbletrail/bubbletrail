import 'package:flutter/material.dart';

import 'adaptive_modal.dart';

// Shows an editor for a set of string values (tags, buddies, ...). On mobile
// this is a bottom sheet, on desktop a modal dialog. Existing values can be
// toggled on/off and new ones entered via the text field. Values in
// [featuredValues], along with the currently selected ones, are shown at the
// top; the rest are tucked away below a divider, collapsed until expanded.
// Returns the updated list of selected values, or null if the user cancelled.
Future<List<String>?> showChipsEditor({
  required BuildContext context,
  required String title,
  required String addLabel,
  required Iterable<String> selectedValues,
  required Iterable<String> availableValues,
  Iterable<String>? featuredValues,
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
      featuredValues: featuredValues,
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
    this.featuredValues,
    required this.textCapitalization,
    required this.createCharacters,
  });

  final String title;
  final String addLabel;
  final Iterable<String> selectedValues;
  final Iterable<String> availableValues;
  final Iterable<String>? featuredValues;
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
  bool _showOthers = false;

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
                  child: Column(crossAxisAlignment: .start, spacing: 8, children: _chipSections()),
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

  // The chip area: a single wrap when there is nothing to tuck away, otherwise
  // the featured values (plus whatever is selected) with everyone else below a
  // divider, collapsed until expanded. Selected values always stay in the top
  // area so they remain visible without expanding anything.
  List<Widget> _chipSections() {
    if (widget.featuredValues == null) return [_chipsWrap(_options)];

    final featured = {...widget.featuredValues!, ..._selected};
    if (featured.isEmpty) return [_chipsWrap(_options)];
    final others = _options.where((value) => !featured.contains(value)).toList();
    if (others.isEmpty) return [_chipsWrap(_options)];

    return [
      _chipsWrap(_options.where(featured.contains).toList()),
      TextButton.icon(
        onPressed: () => setState(() => _showOthers = !_showOthers),
        icon: Icon(_showOthers ? Icons.expand_less : Icons.expand_more),
        label: Text('Others (${others.length})'),
      ),
      if (_showOthers) _chipsWrap(others),
    ];
  }

  Wrap _chipsWrap(List<String> values) {
    return Wrap(spacing: 8, runSpacing: 4, children: values.map((value) => _chip(value)).toList());
  }

  FilterChip _chip(String value) {
    return FilterChip(
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
    );
  }
}
