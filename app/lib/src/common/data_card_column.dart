import 'package:flutter/material.dart';

class DataCardColumn extends StatelessWidget {
  const DataCardColumn({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(child: Column(children: children));
  }
}

class ColumnRow extends StatelessWidget {
  const ColumnRow({super.key, required this.label, required this.child});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: .center,
      mainAxisAlignment: .spaceBetween,
      children: [
        Opacity(opacity: 0.5, child: Text(label ?? '', style: Theme.of(context).textTheme.labelSmall)),
        SizedBox(width: 16),
        child,
      ],
    );
  }
}
