import 'package:flutter/material.dart';

import '../app_metadata.dart';

// Shows an editor for a single piece of text. On mobile this is a bottom
// sheet, on desktop a modal dialog. Returns the trimmed new value, or null if
// the user cancelled.
Future<String?> showTextEditor({
  required BuildContext context,
  required String title,
  required String initialValue,
  String? label,
  int maxLines = 1,
  TextCapitalization textCapitalization = TextCapitalization.none,
}) {
  final editor = _TextEditor(title: title, initialValue: initialValue, label: label, maxLines: maxLines, textCapitalization: textCapitalization);
  if (platformIsMobile) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        // Lift the sheet above the on-screen keyboard while typing.
        padding: .only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: editor,
      ),
    );
  }
  return showDialog<String>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(constraints: const .tightFor(width: 480), child: editor),
    ),
  );
}

class _TextEditor extends StatefulWidget {
  const _TextEditor({required this.title, required this.initialValue, required this.label, required this.maxLines, required this.textCapitalization});

  final String title;
  final String initialValue;
  final String? label;
  final int maxLines;
  final TextCapitalization textCapitalization;

  @override
  State<_TextEditor> createState() => _TextEditorState();
}

class _TextEditorState extends State<_TextEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            TextField(
              controller: _controller,
              autofocus: true,
              minLines: widget.maxLines,
              maxLines: widget.maxLines,
              decoration: InputDecoration(labelText: widget.label, border: const OutlineInputBorder()),
              textCapitalization: widget.textCapitalization,
              autocorrect: widget.maxLines > 1,
              // Submit single-line fields on enter; multiline keeps enter as newline.
              textInputAction: widget.maxLines > 1 ? .newline : .done,
              onSubmitted: widget.maxLines > 1 ? null : (value) => Navigator.of(context).pop(value.trim()),
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(context).pop(_controller.text.trim()), child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
