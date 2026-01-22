import 'dart:developer';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:glob/glob.dart';
import 'package:glob/list_local_fs.dart';
import 'package:hooks/hooks.dart';
import 'package:logging/logging.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  final excludes = ['serial_win32.c', 'usbhid.c'];
  final libdir = await Glob('libdivecomputer-*').list().map((s) => s.path).first;
  final libsources = await Glob('$libdir/src/*.c').list().where((f) => !excludes.contains(f.basename)).map((s) => s.path).toList();
  libsources.sort();

  final localsources = await Glob('src/*.c').list().map((e) => e.path).toList();

  await build(args, (input, output) async {
    final packageName = input.packageName;
    final os = input.config.code.targetOS;
    final configH = File('config.h.$os');
    if (configH.existsSync()) configH.copySync('$libdir/config.h');
    final cbuilder = CBuilder.library(
      name: packageName,
      assetName: '${packageName}_bindings_generated.dart',
      includes: [libdir, '$libdir/include', '$libdir/src'],
      sources: localsources + libsources,
      libraries: ['m'],
      defines: {'HAVE_CONFIG_H': '1'},
    );
    await cbuilder.run(
      input: input,
      output: output,
      logger: Logger('')
        ..level = .ALL
        ..onRecord.listen((record) => print(record.message)),
    );
  });
}
