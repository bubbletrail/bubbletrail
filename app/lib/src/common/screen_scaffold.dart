import 'package:flutter/material.dart';

import '../app_metadata.dart';

class ScreenScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool transparent;

  const ScreenScaffold({super.key, required this.title, required this.body, this.actions, this.floatingActionButton, this.transparent = false});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final inner = platformIsMobile
        ? transparent
              ? body
              : DecoratedBox(
                  decoration: BoxDecoration(color: t.canvasColor),
                  child: body,
                )
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
                child: body,
              ),
            ),
          );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: title, backgroundColor: Colors.transparent, actions: actions, actionsPadding: .only(right: 16)),
        body: Padding(
          padding: platformIsMobile ? const .all(0) : const .only(right: 4.0, bottom: 4.0),
          child: Row(
            crossAxisAlignment: .stretch,
            children: [Expanded(child: inner)],
          ),
        ),
        floatingActionButton: floatingActionButton,
      ),
    );
  }
}
