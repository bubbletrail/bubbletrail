import 'package:flutter/material.dart';

class TextBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const TextBadge({super.key, required this.label, required this.backgroundColor, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: .circular(4)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: textColor)),
    );
  }
}
