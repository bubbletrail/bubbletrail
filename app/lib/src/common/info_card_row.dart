import 'package:flutter/material.dart';

import 'tags_list.dart';

Widget infoCard(BuildContext context, String title, List<Widget> children) {
  return Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(12.0),
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
  return infoWidgetRow(label, Text(value));
}

Widget infoWidgetRow(String label, Widget value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 150,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(child: value),
      ],
    ),
  );
}

Widget tagsRow(BuildContext context, List<String> tags, {List<String>? secondaryTags, String? secondaryLabel}) {
  if (tags.isEmpty && (secondaryTags == null || secondaryTags.isEmpty)) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 150,
          child: Text('Tags:', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: TagsList(tags: tags, secondaryTags: secondaryTags),
        ),
      ],
    ),
  );
}
