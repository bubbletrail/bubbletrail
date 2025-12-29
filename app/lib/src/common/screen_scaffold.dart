import 'dart:io' as io;

import 'package:flutter/material.dart';

class ScreenScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ScreenScaffold({super.key, required this.title, required this.body, this.actions, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    final inner = io.Platform.isIOS
        ? DecoratedBox(
            decoration: BoxDecoration(color: t.canvasColor),
            child: body,
          )
        : DecoratedBox(
            decoration: BoxDecoration(
              border: BoxBorder.all(color: t.colorScheme.onTertiaryContainer),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              color: t.canvasColor,
            ),
            child: Padding(
              padding: const EdgeInsets.all(1.0), // the border
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                child: body,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: title, backgroundColor: Colors.transparent, actions: actions, actionsPadding: EdgeInsets.only(right: 16)),
      body: Padding(
        padding: io.Platform.isIOS ? const EdgeInsets.all(0) : const EdgeInsets.only(right: 4.0, bottom: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: inner)],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
