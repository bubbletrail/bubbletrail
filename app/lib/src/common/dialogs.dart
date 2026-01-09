import 'package:flutter/material.dart';

/// Result of a selection dialog - distinguishes between cancelled and selected value
class SelectionResult<T> {
  final T? value;
  final bool cancelled;

  const SelectionResult.cancelled() : value = null, cancelled = true;
  const SelectionResult.selected(this.value) : cancelled = false;
}

/// Shows a dialog for selecting an item from a list.
///
/// Returns a [SelectionResult] that indicates whether the dialog was cancelled
/// or a value was selected. If [noneOption] is provided, it will be shown as
/// the first item and selecting it will return a result with null value.
Future<SelectionResult<T>> showSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required Widget Function(T item) itemBuilder,
  T? selectedItem,
  String? noneOption,
}) async {
  // Use a sentinel to distinguish cancel from selecting "none"
  const cancelledSentinel = Object();

  final result = await showDialog<Object?>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: .maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: items.length + (noneOption != null ? 1 : 0),
          itemBuilder: (context, index) {
            if (noneOption != null && index == 0) {
              return ListTile(
                leading: const Icon(Icons.clear),
                title: Text(noneOption),
                selected: selectedItem == null,
                onTap: () => Navigator.of(dialogContext).pop(null),
              );
            }
            final item = items[noneOption != null ? index - 1 : index];
            return InkWell(
              onTap: () => Navigator.of(dialogContext).pop(item),
              child: Container(
                color: item == selectedItem ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
                child: itemBuilder(item),
              ),
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(dialogContext).pop(cancelledSentinel), child: const Text('Cancel'))],
    ),
  );

  if (identical(result, cancelledSentinel)) {
    return const SelectionResult.cancelled();
  }
  return .selected(result as T?);
}

/// Shows a confirmation dialog with a title, message, and confirm/cancel buttons.
///
/// Returns true if confirmed, false if cancelled.
Future<bool> showConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
  bool isDestructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: Text(cancelText)),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: isDestructive ? TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error) : null,
          child: Text(confirmText),
        ),
      ],
    ),
  );
  return result ?? false;
}
