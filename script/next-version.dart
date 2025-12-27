#!/usr/bin/env dart

import 'dart:io';

void main() async {
  // Get the latest "publish-1.22.3" or plain "1.22.3" style tag
  final latestTagResult = await cmd('git', [
    'describe',
    '--all',
    '--abbrev=0',
    '--match',
    'publish-?.*',
    '--match',
    '[0-9].*',
  ]);
  if (latestTagResult == null) {
    exit(1);
  }
  final latest = parseVersion(latestTagResult);

  // Get the commit logs since that tag
  final logsSinceLatest = await cmd('git', [
    'log',
    '--pretty=format:%s',
    '$latestTagResult..HEAD',
  ]);
  if (logsSinceLatest == null) {
    exit(1);
  }

  // Check if the next version should be a feature or a patch release
  var nextIsFeature = false;
  for (final line in logsSinceLatest.split('\n')) {
    if (line.startsWith('feat')) {
      nextIsFeature = true;
      break;
    }
  }

  if (nextIsFeature) {
    latest[1]++;
    latest[2] = 0;
  } else {
    latest[2]++;
  }

  print(latest.join('.'));
}

Future<String?> cmd(String executable, List<String> arguments) async {
  final result = await Process.run(executable, arguments);
  if (result.exitCode != 0) {
    stderr.writeln(result.stderr);
    return null;
  }
  return (result.stdout as String).trim();
}

List<int> parseVersion(String s) {
  final start = s.split('').indexWhere((c) => '0123456789'.contains(c));
  if (start < 0) {
    return [0, 0, 0];
  }
  s = s.substring(start);
  final parts = s.split('.');
  final v = <int>[];
  for (final p in parts) {
    v.add(int.tryParse(p) ?? 0);
  }
  while (v.length < 3) {
    v.add(0);
  }
  return v;
}
