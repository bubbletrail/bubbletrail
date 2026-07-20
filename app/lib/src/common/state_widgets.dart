import 'package:flutter/material.dart';

/// A widget that displays an empty state with an optional icon and action.
///
/// Used for showing empty states in list screens when there's no data yet.
class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({super.key, required this.message, this.icon, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            if (icon != null) ...[Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline), const SizedBox(height: 16)],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.outline),
              textAlign: .center,
            ),
            if (actionLabel != null && onAction != null) ...[const SizedBox(height: 16), FilledButton(onPressed: onAction, child: Text(actionLabel!))],
          ],
        ),
      ),
    );
  }
}
