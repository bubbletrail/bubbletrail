import 'dart:io';

import 'package:flutter/material.dart';

Widget infoCard(BuildContext context, String title, List<Widget> children) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const Divider(),
          ...children,
        ],
      ),
    ),
  );
}

Widget infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class ScreenScaffold extends StatelessWidget {
  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const ScreenScaffold({super.key, required this.title, required this.body, this.actions, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: title, backgroundColor: Colors.transparent, actions: actions),
      body: Padding(
        padding: Platform.isIOS ? const EdgeInsets.all(0) : const EdgeInsets.only(right: 4.0, bottom: 4.0),
        child: Row(
          children: [
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  border: BoxBorder.all(color: t.colorScheme.onTertiaryContainer),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(14),
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
                      bottomRight: Radius.circular(14),
                    ),
                    child: body,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
