import 'package:flutter/material.dart';

import 'adaptive_modal.dart';

// Shows an editor for a dive's rating. On mobile this is a bottom sheet, on
// desktop a modal dialog. Returns the selected rating (0 meaning no rating),
// or null if the user cancelled.
Future<int?> showRatingEditor({required BuildContext context, required int rating}) {
  return showAdaptiveModal<int>(
    context: context,
    builder: (context) => _RatingEditor(rating: rating),
  );
}

class _RatingEditor extends StatefulWidget {
  const _RatingEditor({required this.rating});

  final int rating;

  @override
  State<_RatingEditor> createState() => _RatingEditorState();
}

class _RatingEditorState extends State<_RatingEditor> {
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
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
            Text('Rating', style: Theme.of(context).textTheme.titleMedium),
            Row(
              mainAxisAlignment: .center,
              children: .generate(5, (index) {
                final starValue = index + 1;
                return IconButton(
                  icon: Icon(starValue <= _rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                  // Tapping the current rating clears it, matching the edit screen.
                  onPressed: () => setState(() => _rating = starValue == _rating ? 0 : starValue),
                );
              }),
            ),
            Row(
              mainAxisAlignment: .end,
              spacing: 8,
              children: [
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.of(context).pop(_rating), child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
