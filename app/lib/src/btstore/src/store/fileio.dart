import 'dart:io';

import 'package:meta/meta.dart';
import 'package:protobuf/protobuf.dart';

@internal
Future<void> atomicWriteProto(String name, GeneratedMessage object) async {
  await atomicWrite(name, object.writeToBuffer());
}

@internal
Future<void> atomicWrite(String name, List<int> bytes) async {
  await File(name).parent.create(recursive: true);
  await File('$name.new').writeAsBytes(bytes);
  await File('$name.new').rename(name);
}
