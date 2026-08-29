import 'package:flutter/material.dart';

import '../app_metadata.dart';

// Presents [builder] as a modal, adapting to the platform: a bottom sheet on
// mobile and a centred dialog (constrained to [dialogWidth]) on desktop.
// Returns whatever the modal is popped with, or null if dismissed.
Future<T?> showAdaptiveModal<T>({required BuildContext context, required WidgetBuilder builder, double dialogWidth = 480}) {
  if (platformIsMobile) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        // Lift the sheet above the on-screen keyboard while a field is focused.
        padding: .only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: builder(context),
      ),
    );
  }
  return showDialog<T>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: .tightFor(width: dialogWidth),
        child: builder(context),
      ),
    ),
  );
}
