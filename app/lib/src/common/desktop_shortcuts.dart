import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../app_metadata.dart';

/// A screen action with an optional keyboard binding and a menu entry.
class DesktopAction {
  final LogicalKeyboardKey key;
  final String label;
  final VoidCallback? invoke;
  final bool shift;
  final String? menuValue;

  const DesktopAction(this.key, this.label, this.invoke, {this.shift = false, this.menuValue});

  SingleActivator get activator => SingleActivator(
    key,
    meta: defaultTargetPlatform == TargetPlatform.macOS,
    control: defaultTargetPlatform != TargetPlatform.macOS,
    shift: shift,
    includeRepeats: false,
  );

  String get hint =>
      '${defaultTargetPlatform != TargetPlatform.macOS ? '⌃' : ''}${shift ? '⇧' : ''}${defaultTargetPlatform == TargetPlatform.macOS ? '⌘' : ''}${key.keyLabel}';
}

/// App navigation uses MaterialApp.shortcuts so bindings surround the root
/// focus scope as well as every retained branch navigator.
class DesktopNavigationIntent extends Intent {
  final int destination;

  const DesktopNavigationIntent(this.destination);
}

class DesktopImportIntent extends Intent {
  const DesktopImportIntent();
}

bool get desktopPopupHasFocus {
  final context = FocusManager.instance.primaryFocus?.context;
  return context != null && ModalRoute.of(context) is PopupRoute;
}

class DesktopShortcuts extends StatelessWidget {
  final List<DesktopAction> actions;
  final Widget child;

  const DesktopShortcuts({super.key, required this.actions, required this.child});

  @override
  Widget build(BuildContext context) {
    if (!platformIsDesktop || actions.isEmpty) return child;
    return CallbackShortcuts(
      bindings: {
        for (final action in actions)
          if (action.invoke != null)
            action.activator: () {
              // Ignore retained screens underneath a modal or pushed route.
              final route = ModalRoute.of(context);
              final focusedContext = FocusManager.instance.primaryFocus?.context;
              final focusedRoute = focusedContext == null ? null : ModalRoute.of(focusedContext);
              // App-level shortcuts also surround dialog navigators. Let a popup
              // own its input, while keeping shortcuts declared inside it active.
              if (focusedRoute is PopupRoute && focusedRoute != route) return;
              if (route?.isCurrent != false) action.invoke!();
            },
      },
      child: Focus(autofocus: true, child: child),
    );
  }
}

class DesktopActionsMenu extends StatelessWidget {
  final List<DesktopAction> actions;
  final PopupMenuButton<String>? overflowMenu;

  const DesktopActionsMenu({super.key, required this.actions, this.overflowMenu});

  Widget _label(BuildContext context, DesktopAction action) => Row(
    spacing: 16,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Flexible(child: Text(action.label)),
      Text(action.hint, style: Theme.of(context).textTheme.labelSmall),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final linkedActions = {
      for (final action in actions)
        if (action.menuValue != null) action.menuValue: action,
    };
    return PopupMenuButton<Object>(
      menuPadding: const .symmetric(vertical: 4),
      onSelected: (value) {
        if (value is DesktopAction) {
          value.invoke?.call();
        } else if (value is String) {
          overflowMenu?.onSelected?.call(value);
        }
      },
      itemBuilder: (context) => [
        for (final action in actions)
          if (action.menuValue == null)
            PopupMenuItem<Object>(
              height: 32,
              padding: const .symmetric(horizontal: 12),
              value: action,
              enabled: action.invoke != null,
              child: _label(context, action),
            ),
        if (overflowMenu != null && actions.any((action) => action.menuValue == null)) const PopupMenuDivider(height: 8),
        for (final entry in overflowMenu?.itemBuilder(context) ?? <PopupMenuEntry<String>>[])
          if (entry is PopupMenuItem<String>)
            PopupMenuItem<Object>(
              key: entry.key,
              height: 32,
              padding: const .symmetric(horizontal: 12),
              value: entry.value,
              onTap: entry.onTap,
              enabled: entry.enabled,
              textStyle: entry.textStyle,
              labelTextStyle: entry.labelTextStyle,
              mouseCursor: entry.mouseCursor,
              child: linkedActions.containsKey(entry.value) ? _label(context, linkedActions[entry.value]!) : entry.child,
            )
          else
            entry,
      ],
    );
  }
}
