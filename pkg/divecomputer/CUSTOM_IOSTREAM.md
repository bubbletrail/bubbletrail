# Custom IOStream Implementation

This document explains how to implement custom I/O streams for libdivecomputer from Dart, enabling support for BLE and other custom transport mechanisms.

## Overview

The `CustomIOStream` class allows you to implement a custom I/O stream in Dart that bridges to libdivecomputer's C API. This is particularly useful for:

- **BLE (Bluetooth Low Energy)** connections - The primary use case
- **Custom network protocols** - If you need specialized networking
- **Mock/test implementations** - For testing dive computer communication

## Quick Start

### 1. Extend CustomIOStream

Create a class that extends `CustomIOStream` and implements the required `read` and `write` methods:

```dart
import 'package:dive_computer/framework/custom_iostream.dart';
import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';

class BleIOStream extends CustomIOStream {
  BleIOStream({
    required this.bleDevice,
  });

  final YourBleDevice bleDevice;
  final List<int> _readBuffer = [];

  @override
  int read(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual) {
    // Read from your BLE device into the native buffer
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
    // Write to your BLE device
    final buffer = data.cast<ffi.Uint8>().asTypedList(size);

    // Send via BLE
    bleDevice.write(buffer);

    actual.value = size;
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  // Helper to add received BLE data to the buffer
  void onBleDataReceived(List<int> data) {
    _readBuffer.addAll(data);
  }
}
```

### 2. Open the Stream

Before using the stream with libdivecomputer, open it:

```dart
final bleStream = BleIOStream(bleDevice: myBleDevice);

final iostream = bleStream.open(
  DiveComputerFfi._bindings,  // Access the bindings
  DiveComputerFfi.context.value,  // Access the context
  dc_transport_t.DC_TRANSPORT_BLE,  // Transport type
);
```

### 3. Use with DiveComputerFfi

Pass the iostream to the download function:

```dart
DiveComputerFfi.download(
  computer,
  ComputerTransport.ble,
  customIOStream: iostream,
  lastFingerprint: lastFingerprint,
);
```

### 4. Clean Up

When done, close the stream:

```dart
bleStream.close(DiveComputerFfi._bindings);
```

## Method Reference

### Required Methods

These methods must be implemented:

#### `read(data, size, actual)`

Reads data from the stream into a native buffer.

- **Parameters:**
  - `data`: Pointer to the buffer to read into
  - `size`: Maximum number of bytes to read
  - `actual`: Pointer to store the actual number of bytes read
- **Returns:** `DC_STATUS_SUCCESS` on success, or an error code
- **Note:** Should respect the timeout set by `setTimeout()`

#### `write(data, size, actual)`

Writes data from a native buffer to the stream.

- **Parameters:**
  - `data`: Pointer to the buffer to write from
  - `size`: Number of bytes to write
  - `actual`: Pointer to store the actual number of bytes written
- **Returns:** `DC_STATUS_SUCCESS` on success, or an error code

### Optional Methods

These methods have default implementations but can be overridden:

#### `setTimeout(timeout)`

Sets the read timeout in milliseconds.

- `timeout < 0`: Blocking mode (wait forever)
- `timeout == 0`: Non-blocking mode (return immediately)
- `timeout > 0`: Wait up to timeout milliseconds

#### `poll(timeout)`

Polls for available data. Returns `DC_STATUS_SUCCESS` if data is available, `DC_STATUS_TIMEOUT` if not.

#### `flush()`

Flushes any pending output data.

#### `purge(direction)`

Clears internal buffers:
- `DC_DIRECTION_INPUT`: Clear input buffer
- `DC_DIRECTION_OUTPUT`: Clear output buffer
- `DC_DIRECTION_ALL`: Clear both

#### `onClose()`

Called when the stream is being closed. Use this to clean up resources.

### Serial Port Methods (Usually Not Needed for BLE)

These methods are for serial port operations and typically return `DC_STATUS_UNSUPPORTED` for BLE:

- `setBreak(value)`
- `setDtr(value)`
- `setRts(value)`
- `getLines(value)`
- `configure(baudrate, databits, parity, stopbits, flowcontrol)`

## Complete BLE Example

See `lib/framework/examples/ble_iostream_example.dart` for a complete example implementation.

Here's a simplified complete workflow:

```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:dive_computer/framework/custom_iostream.dart';

class MyBleIOStream extends CustomIOStream {
  MyBleIOStream(this.rxCharacteristic, this.txCharacteristic) {
    // Subscribe to notifications
    rxCharacteristic.setNotifyValue(true);
    rxCharacteristic.value.listen((data) {
      _readBuffer.addAll(data);
    });
  }

  final BluetoothCharacteristic rxCharacteristic;
  final BluetoothCharacteristic txCharacteristic;
  final List<int> _readBuffer = [];
  int _timeout = -1;

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
      if (timeout > 0 &&
          DateTime.now().difference(startTime).inMilliseconds >= timeout) {
        return dc_status_t.DC_STATUS_TIMEOUT;
      } else if (timeout == 0) {
        return dc_status_t.DC_STATUS_TIMEOUT;
      }
      // Small sleep to avoid busy-waiting
      sleep(Duration(milliseconds: 10));
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

// Usage
void downloadFromBle() async {
  // 1. Connect to BLE device
  final device = await FlutterBluePlus.connect(...);
  final services = await device.discoverServices();
  final rxChar = services.findCharacteristic(...);
  final txChar = services.findCharacteristic(...);

  // 2. Create iostream
  final bleStream = MyBleIOStream(rxChar, txChar);
  final iostream = bleStream.open(
    DiveComputerFfi._bindings,
    DiveComputerFfi.context.value,
    dc_transport_t.DC_TRANSPORT_BLE,
  );

  // 3. Download dives
  try {
    DiveComputerFfi.download(
      computer,
      ComputerTransport.ble,
      customIOStream: iostream,
    );
  } finally {
    // 4. Clean up
    bleStream.close(DiveComputerFfi._bindings);
    await device.disconnect();
  }
}
```

## Threading and Async Considerations

**Important:** libdivecomputer callbacks are synchronous and run on the same thread/isolate as the libdivecomputer operations. This means:

1. **Avoid async/await in callbacks** - The `read()` and `write()` methods cannot be async
2. **Use buffers** - Buffer incoming BLE data in a synchronous buffer that callbacks can read from
3. **Handle notifications separately** - Set up BLE notifications to populate your buffer outside of the callbacks

If you need to bridge async BLE operations with synchronous callbacks, use patterns like:
- Maintaining a synchronous buffer that BLE notifications populate
- Using `Completer` to wait for async operations in a blocking way (carefully)
- Pre-fetching data before the callback needs it

## Error Handling

Return appropriate status codes:

- `DC_STATUS_SUCCESS` (0) - Operation succeeded
- `DC_STATUS_TIMEOUT` - Operation timed out
- `DC_STATUS_IO` - I/O error occurred
- `DC_STATUS_UNSUPPORTED` - Operation not supported
- `DC_STATUS_NOMEMORY` - Out of memory
- `DC_STATUS_PROTOCOL` - Protocol error

These constants are available in the `dc_status_t` class in the generated bindings.

## Testing

You can create mock implementations for testing:

```dart
class MockIOStream extends CustomIOStream {
  final List<int> mockData;
  int readPosition = 0;

  MockIOStream(this.mockData);

  @override
  int read(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual) {
    final remaining = mockData.length - readPosition;
    final toRead = remaining < size ? remaining : size;

    final buffer = data.cast<ffi.Uint8>();
    for (int i = 0; i < toRead; i++) {
      buffer[i] = mockData[readPosition + i];
    }

    readPosition += toRead;
    actual.value = toRead;
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  @override
  int write(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual) {
    // Log or verify write operations
    actual.value = size;
    return dc_status_t.DC_STATUS_SUCCESS;
  }
}
```

## Troubleshooting

### "No data received"
- Ensure BLE notifications are properly set up
- Check that received data is being added to your read buffer
- Verify the timeout is set appropriately

### "Operation not supported"
- Check that you've implemented the required methods
- Ensure you're returning `DC_STATUS_UNSUPPORTED` for optional methods you don't implement

### "Memory errors"
- Always set the `actual` parameter in read/write methods
- Don't write beyond the buffer size provided in `size` parameter
- Ensure you're using `calloc.free()` for any allocated memory

### "Crashes in callbacks"
- Wrap callback code in try-catch blocks
- The default implementations do this, but check custom code
- Use the logger to debug issues

## Additional Resources

- See `lib/framework/custom_iostream.dart` for the base class implementation
- See `lib/framework/examples/ble_iostream_example.dart` for examples
- See libdivecomputer documentation for more details on the C API
