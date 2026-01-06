import 'package:flutter/material.dart';

class TagsList extends StatelessWidget {
  const TagsList({super.key, required this.tags, this.secondaryTags, this.prefix});

  final Iterable<String> tags;
  final Iterable<String>? secondaryTags;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...tags.map(
          (tag) => Chip(
            label: prefixedTag(tag),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        if (secondaryTags != null)
          ...secondaryTags!.map(
            (tag) => Chip(
              label: prefixedTag(tag),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: colorScheme.secondaryContainer,
              labelStyle: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
          ),
      ],
    );
  }

  Widget prefixedTag(String tag) {
    if (prefix == null) return Text(tag);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(opacity: 0.5, child: Text(prefix!)),
        Text(tag),
      ],
    );
  }
}
