import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// A widget that displays an error state with an icon, title, and message.
///
/// Used for showing error states in list screens and other places where
/// data loading may fail.
class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.title, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(16),
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Icon(FluentIcons.error_circle_24_regular, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, style: Theme.of(context).textTheme.bodyMedium, textAlign: .center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onRetry, icon: const Icon(FluentIcons.arrow_sync_24_regular), label: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}

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
