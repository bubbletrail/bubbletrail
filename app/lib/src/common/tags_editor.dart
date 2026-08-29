import 'package:flutter/material.dart';

import 'chips_editor.dart';

// Shows an editor for a dive's tags. On mobile this is a bottom sheet, on
// desktop a modal dialog. Returns the updated list of selected tags, or null
// if the user cancelled.
Future<List<String>?> showTagsEditor({required BuildContext context, required Iterable<String> selectedTags, required Iterable<String> availableTags}) {
  return showChipsEditor(context: context, title: 'Tags', addLabel: 'Add tag', selectedValues: selectedTags, availableValues: availableTags);
}
