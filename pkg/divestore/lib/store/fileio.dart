import 'dart:io';

import 'package:protobuf/protobuf.dart';

Future<void> atomicWriteProto(String name, GeneratedMessage object) async {
  atomicWrite(name, object.writeToBuffer());
}

Future<void> atomicWrite(String name, List<int> bytes) async {
  await File(name).parent.create(recursive: true);
  await File("$name.new").writeAsBytes(bytes);
  await File("$name.new").rename(name);
}
