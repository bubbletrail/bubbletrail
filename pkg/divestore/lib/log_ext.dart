import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

import 'gen/gen.dart';

extension LogExtensions on Log {
  void setUniqueID() {
    if (this.hasUniqueID()) return;
    // Calculate a unique yet repeatable dive ID, if we have all the
    // information required. Any given dive computer identified by model &
    // serial should only have one dive starting at a given point in time.
    if (this.hasModel() && this.hasSerial() && this.hasDateTime()) {
      final unique = 'DC${this.model}/${this.serial}@${this.dateTime.seconds}';
      final hash = sha256.convert(utf8.encode(unique)).bytes;
      // Compress to a 128 bit hash by xor:ing the two halves
      final trunc = Uint8List(16);
      for (var i = 0; i < 16; i++) {
        trunc[i] = hash[i] ^ hash[i + 16];
      }
      this.uniqueID = hex.encode(trunc);
    }
  }
}
