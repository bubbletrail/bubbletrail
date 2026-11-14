import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../app_metadata.dart';
import 'desktop_shortcuts.dart';

class ScreenScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool transparent;
  final List<DesktopAction> shortcuts;
  final PopupMenuButton<String>? overflowMenu;

  const ScreenScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.transparent = false,
    this.shortcuts = const [],
    this.overflowMenu,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final availableShortcuts = [
      ...shortcuts,
      if (context.canPop()) DesktopAction(LogicalKeyboardKey.bracketLeft, MaterialLocalizations.of(context).backButtonTooltip, () => context.pop()),
    ];

    final inner = platformIsMobile
        ? transparent
              ? body
              : Material(color: t.canvasColor, child: body)
        : DecoratedBox(
            decoration: BoxDecoration(
              border: .all(color: t.colorScheme.onTertiaryContainer),
              borderRadius: .only(topLeft: .circular(8), topRight: .circular(8), bottomLeft: .circular(8), bottomRight: .circular(8)),
              color: t.canvasColor,
            ),
            child: Padding(
              padding: const .all(1.0), // the border
              child: ClipRRect(
                borderRadius: .only(topLeft: .circular(8), topRight: .circular(8), bottomLeft: .circular(8), bottomRight: .circular(8)),
                child: Material(color: t.canvasColor, child: body),
              ),
            ),
          );

    return DesktopShortcuts(
      actions: availableShortcuts,
      child: Builder(
        builder: (context) => GestureDetector(
          onTap: () {
            if (platformIsDesktop && availableShortcuts.isNotEmpty) {
              Focus.of(context).requestFocus();
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: title,
              backgroundColor: Colors.transparent,
              actions: [
                ...?actions,
                if (platformIsDesktop && (availableShortcuts.isNotEmpty || overflowMenu != null))
                  DesktopActionsMenu(actions: availableShortcuts, overflowMenu: overflowMenu)
                else
                  ?overflowMenu,
              ],
              actionsPadding: .only(right: 16),
            ),
            body: Padding(
              padding: platformIsMobile ? const .all(0) : const .only(right: 4.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: .stretch,
                children: [Expanded(child: inner)],
              ),
            ),
            floatingActionButton: floatingActionButton,
          ),
        ),
      ),
    );
  }
}
