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
