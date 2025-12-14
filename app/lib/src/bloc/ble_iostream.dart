import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:dive_computer/framework/custom_iostream.dart';
import 'package:dive_computer/framework/dive_computer_ffi_bindings_generated.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleIOStream extends CustomIOStream {
  BleIOStream({
    required this.rxCharacteristic,
    required this.txCharacteristic,
  });

  final BluetoothCharacteristic rxCharacteristic;
  final BluetoothCharacteristic txCharacteristic;

  final List<int> _readBuffer = [];
  int _timeout = -1;

  Future<void> setupNotifications() async {
    await rxCharacteristic.setNotifyValue(true);
    rxCharacteristic.onValueReceived.listen((data) {
      _readBuffer.addAll(data);
    });
  }

  @override
  int setTimeout(int timeout) {
    _timeout = timeout;
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int poll(int timeout) {
    if (_readBuffer.isNotEmpty) {
      return dc_status_t.DC_STATUS_SUCCESS;
    }

    final startTime = DateTime.now();
    while (_readBuffer.isEmpty) {
      if (timeout > 0) {
        final elapsed = DateTime.now().difference(startTime).inMilliseconds;
        if (elapsed >= timeout) {
          return dc_status_t.DC_STATUS_TIMEOUT;
        }
      } else if (timeout == 0) {
        return dc_status_t.DC_STATUS_TIMEOUT;
      }
      sleep(const Duration(milliseconds: 10));
    }

    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int read(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual) {
    if (_readBuffer.isEmpty) {
      final pollResult = poll(_timeout);
      if (pollResult != dc_status_t.DC_STATUS_SUCCESS) {
        actual.value = 0;
        return pollResult;
      }
    }

    final bytesToRead = _readBuffer.length < size ? _readBuffer.length : size;
    final buffer = data.cast<ffi.Uint8>();

    for (int i = 0; i < bytesToRead; i++) {
      buffer[i] = _readBuffer[i];
    }

    _readBuffer.removeRange(0, bytesToRead);
    actual.value = bytesToRead;
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int write(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual) {
    final buffer = data.cast<ffi.Uint8>().asTypedList(size);
    txCharacteristic.write(buffer.toList(), withoutResponse: false);
    actual.value = size;
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int flush() => dc_status_t.DC_STATUS_SUCCESS;

  @override
  int purge(int direction) {
    if (direction & dc_direction_t.DC_DIRECTION_INPUT != 0) {
      _readBuffer.clear();
    }
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int onClose() {
    _readBuffer.clear();
    rxCharacteristic.setNotifyValue(false);
    return dc_status_t.DC_STATUS_SUCCESS;
  }
}

class BleCharacteristicPair {
  final BluetoothCharacteristic rx;
  final BluetoothCharacteristic tx;

  BleCharacteristicPair({required this.rx, required this.tx});
}

BleCharacteristicPair? findBleCharacteristics(List<BluetoothService> services) {
  for (final service in services) {
    BluetoothCharacteristic? rxChar;
    BluetoothCharacteristic? txChar;

    for (final characteristic in service.characteristics) {
      if (characteristic.properties.notify || characteristic.properties.indicate) {
        rxChar ??= characteristic;
      }
      if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
        txChar ??= characteristic;
      }
    }

    if (rxChar != null && txChar != null) {
      return BleCharacteristicPair(rx: rxChar, tx: txChar);
    }
  }
  return null;
}
