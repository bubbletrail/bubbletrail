import 'package:flutter/material.dart';

class LabeledChip extends StatelessWidget {
  const LabeledChip({super.key, required this.label, this.backgroundColor, required this.child});

  final String? label;
  final Color? backgroundColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inner = (label == null)
        ? child
        : Row(
            mainAxisSize: .min,
            spacing: 8,
            children: [
              Opacity(opacity: 0.7, child: Text(label!, style: Theme.of(context).textTheme.labelSmall)),
              child,
            ],
          );

    return Chip(
      visualDensity: .compact,
      materialTapTargetSize: .shrinkWrap,
      padding: .zero,
      labelPadding: const .symmetric(horizontal: 8),
      label: inner,
      backgroundColor: backgroundColor,
    );
  }
}
