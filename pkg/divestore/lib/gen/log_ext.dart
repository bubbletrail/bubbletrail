import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';

import 'gen.dart';

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

  DecoStatus? get worstDecoStatus {
    DecoStatus? worst;
    for (final sample in samples) {
      if (!sample.hasDeco()) continue;
      if (worst == null) {
        if (sample.deco.type != DecoStopType.DECO_STOP_TYPE_NDL || sample.deco.time > 0) worst = sample.deco;
        continue;
      }
      if (worst.type.value < sample.deco.type.value) {
        worst = sample.deco;
        continue;
      }
      if (worst.type == sample.deco.type) {
        switch (worst.type) {
          case DecoStopType.DECO_STOP_TYPE_DECO_STOP:
          case DecoStopType.DECO_STOP_TYPE_DEEP_STOP:
          case DecoStopType.DECO_STOP_TYPE_SAFETY_STOP:
            if (sample.deco.time > worst.time) {
              worst = sample.deco;
              continue;
            }
          case DecoStopType.DECO_STOP_TYPE_NDL:
            if (sample.deco.time < worst.time) {
              worst = sample.deco;
              continue;
            }
        }
      }
    }
    return worst;
  }
}
