import 'package:btl10n/btl10n.dart';
import 'package:material_ui/material_ui.dart';

/// Result of a selection dialog - distinguishes between cancelled and selected value
class SelectionResult<T> {
  final T? value;
  final bool cancelled;

  const SelectionResult.cancelled() : value = null, cancelled = true;
  const SelectionResult.none() : value = null, cancelled = false;
  const SelectionResult.selected(this.value) : cancelled = false;
}

/// Shows a confirmation dialog with a title, message, and confirm/cancel buttons.
///
/// Returns true if confirmed, false if cancelled.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String? confirmText,
  String? cancelText,
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(cancelText ?? context.l10n.cancel)),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: isDestructive ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error) : null,
          child: Text(confirmText ?? context.l10n.confirm),
        ),
      ],
    ),
  );
  return result ?? false;
}
