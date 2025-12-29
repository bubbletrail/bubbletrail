import 'dart:convert';
import 'dart:io';

Future<void> atomicWriteJSON(String name, Object? object) async {
  if (object == null) return;
  final str = JsonEncoder.withIndent('  ').convert(object);
  await File("$name.new").writeAsString(str);
  await File("$name.new").rename(name);
}

Future<void> atomicWrite(String name, List<int> bytes) async {
  await File("$name.new").writeAsBytes(bytes);
  await File("$name.new").rename(name);
}
