import 'dart:ffi' as ffi;
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart' as logging;

import 'dive_computer_ffi_bindings_generated.dart';
import 'utils/utils.dart';

final log = logging.Logger('CustomIOStream');

/// Abstract class that allows implementing a custom iostream from Dart.
///
/// This is useful for implementing BLE or other custom transport mechanisms
/// that are implemented in Dart but need to be used with libdivecomputer.
///
/// To use this class:
/// 1. Extend this class and implement the required methods
/// 2. Call [open] to create the native iostream
/// 3. Use the returned pointer with libdivecomputer device operations
/// 4. The iostream will be automatically cleaned up when closed
///
/// Example:
/// ```dart
/// class BleIOStream extends CustomIOStream {
///   @override
///   Future<int> read(Uint8List buffer, int size) async {
///     // Read from BLE characteristic
///     return bytesRead;
///   }
///
///   @override
///   Future<int> write(Uint8List data) async {
///     // Write to BLE characteristic
///     return data.length;
///   }
/// }
/// ```
abstract class CustomIOStream {
  ffi.Pointer<dc_custom_cbs_t>? _callbacks;
  ffi.Pointer<dc_iostream_t>? _iostream;
  bool _isOpen = false;

  /// Opens the custom iostream with the given context and transport.
  ///
  /// [bindings] The FFI bindings to libdivecomputer
  /// [context] The libdivecomputer context
  /// [transport] The transport type (e.g., DC_TRANSPORT_BLE)
  ///
  /// Returns a pointer to the created iostream.
  ffi.Pointer<dc_iostream_t> open(
    DiveComputerFfiBindings bindings,
    ffi.Pointer<dc_context_t> context,
    int transport,
  ) {
    if (_isOpen) {
      throw StateError('IOStream is already open');
    }

    // Allocate callbacks structure
    _callbacks = calloc<dc_custom_cbs_t>();

    // Set up callback pointers - using ffi.Pointer.fromFunction for each
    _callbacks!.ref.set_timeout = ffi.Pointer.fromFunction(_setTimeoutCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.set_break = ffi.Pointer.fromFunction(_setBreakCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.set_dtr = ffi.Pointer.fromFunction(_setDtrCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.set_rts = ffi.Pointer.fromFunction(_setRtsCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.get_lines = ffi.Pointer.fromFunction(_getLinesCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.get_available = ffi.Pointer.fromFunction(_getAvailableCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.configure = ffi.Pointer.fromFunction(_configureCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.poll = ffi.Pointer.fromFunction(_pollCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.read = ffi.Pointer.fromFunction(_readCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.write = ffi.Pointer.fromFunction(_writeCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.ioctl = ffi.Pointer.fromFunction(_ioctlCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.flush = ffi.Pointer.fromFunction(_flushCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.purge = ffi.Pointer.fromFunction(_purgeCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.sleep = ffi.Pointer.fromFunction(_sleepCallback, dc_status_t.DC_STATUS_UNSUPPORTED);
    _callbacks!.ref.close = ffi.Pointer.fromFunction(_closeCallback, dc_status_t.DC_STATUS_UNSUPPORTED);

    // Store this instance in a global map so callbacks can find it
    _registerInstance(this);

    // Create the iostream
    final iostreamPtr = calloc<ffi.Pointer<dc_iostream_t>>();
    handleResult(
      bindings.dc_custom_open(
        iostreamPtr,
        context,
        transport,
        _callbacks!,
        ffi.Pointer.fromAddress(identityHashCode(this)),
      ),
      'custom iostream open',
    );

    _iostream = iostreamPtr.value;
    _isOpen = true;

    return _iostream!;
  }

  /// Closes the iostream and frees resources.
  void close(DiveComputerFfiBindings bindings) {
    if (!_isOpen) {
      return;
    }

    if (_iostream != null) {
      bindings.dc_iostream_close(_iostream!);
      _iostream = null;
    }

    if (_callbacks != null) {
      calloc.free(_callbacks!);
      _callbacks = null;
    }

    _unregisterInstance(this);
    _isOpen = false;
  }

  // Methods to override in subclasses

  /// Sets the read timeout in milliseconds.
  /// Return DC_STATUS_SUCCESS if successful.
  int setTimeout(int timeout) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Sets the break condition.
  /// Return DC_STATUS_SUCCESS if successful.
  int setBreak(int value) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Sets the DTR line state.
  /// Return DC_STATUS_SUCCESS if successful.
  int setDtr(int value) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Sets the RTS line state.
  /// Return DC_STATUS_SUCCESS if successful.
  int setRts(int value) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Gets the line signals.
  /// Return DC_STATUS_SUCCESS if successful and set [value].
  int getLines(ffi.Pointer<ffi.UnsignedInt> value) =>
      dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Gets the number of available bytes in the input buffer.
  /// Return DC_STATUS_SUCCESS if successful and set [value].
  int getAvailable(ffi.Pointer<ffi.Size> value) =>
      dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Configures the line settings.
  /// Return DC_STATUS_SUCCESS if successful.
  int configure(
    int baudrate,
    int databits,
    int parity,
    int stopbits,
    int flowcontrol,
  ) =>
      dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Polls for available data with the given timeout.
  /// Return DC_STATUS_SUCCESS if data is available, DC_STATUS_TIMEOUT on timeout.
  int poll(int timeout) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Reads data into the buffer.
  ///
  /// [data] Pointer to the buffer to read into
  /// [size] Maximum number of bytes to read
  /// [actual] Pointer to store the actual number of bytes read
  ///
  /// Return DC_STATUS_SUCCESS if successful.
  int read(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual);

  /// Writes data from the buffer.
  ///
  /// [data] Pointer to the buffer to write from
  /// [size] Number of bytes to write
  /// [actual] Pointer to store the actual number of bytes written
  ///
  /// Return DC_STATUS_SUCCESS if successful.
  int write(ffi.Pointer<ffi.Void> data, int size, ffi.Pointer<ffi.Size> actual);

  /// Performs an ioctl operation.
  /// Return DC_STATUS_SUCCESS if successful.
  int ioctl(int request, ffi.Pointer<ffi.Void> data, int size) =>
      dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Flushes the output buffer.
  /// Return DC_STATUS_SUCCESS if successful.
  int flush() => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Purges the buffers in the given direction.
  /// Return DC_STATUS_SUCCESS if successful.
  int purge(int direction) => dc_status_t.DC_STATUS_UNSUPPORTED;

  /// Sleeps for the given number of milliseconds.
  /// Return DC_STATUS_SUCCESS if successful.
  int sleep(int milliseconds) {
    // Default implementation uses Dart's sleep
    return dc_status_t.DC_STATUS_SUCCESS;
  }

  /// Called when the iostream is being closed from the native side.
  /// Return DC_STATUS_SUCCESS if successful.
  int onClose() => dc_status_t.DC_STATUS_SUCCESS;

  // Static callback functions that route to instance methods

  static final Map<int, CustomIOStream> _instances = {};

  static void _registerInstance(CustomIOStream instance) {
    _instances[identityHashCode(instance)] = instance;
  }

  static void _unregisterInstance(CustomIOStream instance) {
    _instances.remove(identityHashCode(instance));
  }

  static CustomIOStream? _getInstance(ffi.Pointer<ffi.Void> userdata) {
    final hashCode = userdata.address;
    return _instances[hashCode];
  }

  static int _setTimeoutCallback(ffi.Pointer<ffi.Void> userdata, int timeout) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.setTimeout(timeout);
    } catch (e) {
      log.severe('Error in setTimeout callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _setBreakCallback(ffi.Pointer<ffi.Void> userdata, int value) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.setBreak(value);
    } catch (e) {
      log.severe('Error in setBreak callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _setDtrCallback(ffi.Pointer<ffi.Void> userdata, int value) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.setDtr(value);
    } catch (e) {
      log.severe('Error in setDtr callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _setRtsCallback(ffi.Pointer<ffi.Void> userdata, int value) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.setRts(value);
    } catch (e) {
      log.severe('Error in setRts callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _getLinesCallback(
      ffi.Pointer<ffi.Void> userdata, ffi.Pointer<ffi.UnsignedInt> value) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.getLines(value);
    } catch (e) {
      log.severe('Error in getLines callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _getAvailableCallback(
      ffi.Pointer<ffi.Void> userdata, ffi.Pointer<ffi.Size> value) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.getAvailable(value);
    } catch (e) {
      log.severe('Error in getAvailable callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _configureCallback(
    ffi.Pointer<ffi.Void> userdata,
    int baudrate,
    int databits,
    int parity,
    int stopbits,
    int flowcontrol,
  ) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.configure(baudrate, databits, parity, stopbits, flowcontrol);
    } catch (e) {
      log.severe('Error in configure callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _pollCallback(ffi.Pointer<ffi.Void> userdata, int timeout) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.poll(timeout);
    } catch (e) {
      log.severe('Error in poll callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _readCallback(
    ffi.Pointer<ffi.Void> userdata,
    ffi.Pointer<ffi.Void> data,
    int size,
    ffi.Pointer<ffi.Size> actual,
  ) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.read(data, size, actual);
    } catch (e) {
      log.severe('Error in read callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _writeCallback(
    ffi.Pointer<ffi.Void> userdata,
    ffi.Pointer<ffi.Void> data,
    int size,
    ffi.Pointer<ffi.Size> actual,
  ) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.write(data, size, actual);
    } catch (e) {
      log.severe('Error in write callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _ioctlCallback(
    ffi.Pointer<ffi.Void> userdata,
    int request,
    ffi.Pointer<ffi.Void> data,
    int size,
  ) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.ioctl(request, data, size);
    } catch (e) {
      log.severe('Error in ioctl callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _flushCallback(ffi.Pointer<ffi.Void> userdata) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.flush();
    } catch (e) {
      log.severe('Error in flush callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _purgeCallback(ffi.Pointer<ffi.Void> userdata, int direction) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.purge(direction);
    } catch (e) {
      log.severe('Error in purge callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _sleepCallback(ffi.Pointer<ffi.Void> userdata, int milliseconds) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.sleep(milliseconds);
    } catch (e) {
      log.severe('Error in sleep callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }

  static int _closeCallback(ffi.Pointer<ffi.Void> userdata) {
    try {
      final instance = _getInstance(userdata);
      if (instance == null) return dc_status_t.DC_STATUS_UNSUPPORTED;
      return instance.onClose();
    } catch (e) {
      log.severe('Error in close callback: $e');
      return dc_status_t.DC_STATUS_IO;
    }
  }
}
