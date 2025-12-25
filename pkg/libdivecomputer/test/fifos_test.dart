import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:libdivecomputer/libdivecomputer_bindings_generated.dart' as bindings;
import 'package:test/test.dart';

const _timeout = Duration(seconds: 5);

void main() {
  group('FIFO bridging', () {
    test('dc_fifos_create creates FIFO files', () {
      final context = calloc<ffi.Pointer<bindings.dc_context_t>>();
      bindings.dc_context_new(context);

      final readPathPtr = calloc<ffi.Pointer<ffi.Char>>();
      final writePathPtr = calloc<ffi.Pointer<ffi.Char>>();
      final directory = '/tmp'.toNativeUtf8().cast<ffi.Char>();

      try {
        final status = bindings.dc_fifos_create(
          context.value,
          directory,
          readPathPtr,
          writePathPtr,
        );

        expect(status, bindings.dc_status_t.DC_STATUS_SUCCESS);

        final readPath = readPathPtr.value.cast<Utf8>().toDartString();
        final writePath = writePathPtr.value.cast<Utf8>().toDartString();

        expect(readPath, startsWith('/tmp/'));
        expect(writePath, startsWith('/tmp/'));
        expect(readPath, contains('_r'));
        expect(writePath, contains('_w'));

        // Verify files exist and are FIFOs
        expect(FileStat.statSync(readPath).type, FileSystemEntityType.pipe);
        expect(FileStat.statSync(writePath).type, FileSystemEntityType.pipe);

        // Cleanup
        File(readPath).deleteSync();
        File(writePath).deleteSync();
      } finally {
        _freeIfNotNull(readPathPtr);
        _freeIfNotNull(writePathPtr);
        calloc.free(directory);
        bindings.dc_context_free(context.value);
        calloc.free(context);
      }
    });

    test('data flows from Dart to iostream', () async {
      final testData = Uint8List.fromList([0x01, 0x02, 0x03, 0x04, 0x05]);

      final result = await _runWithFifos<_IoResult>(
        isolateEntry: _iostreamReaderIsolate,
        makeRequest: (paths, sendPort) => _IoRequest(
          paths: paths,
          sendPort: sendPort,
          expectedReadSize: testData.length,
        ),
        dartWork: (dartWriter, dartReader) async {
          await dartWriter.writeFrom(testData);
          await dartWriter.close();
          await dartReader.close();
        },
      );

      expect(result.success, isTrue, reason: result.error ?? '');
      expect(result.data, equals(testData));
    });

    test('data flows from iostream to Dart', () async {
      final testData = Uint8List.fromList([0xAA, 0xBB, 0xCC, 0xDD, 0xEE]);

      final result = await _runWithFifos<_IoResult>(
        isolateEntry: _iostreamWriterIsolate,
        makeRequest: (paths, sendPort) => _IoRequest(
          paths: paths,
          sendPort: sendPort,
          dataToWrite: testData,
        ),
        dartWork: (dartWriter, dartReader) async {
          final buffer = Uint8List(testData.length);
          final bytesRead = await _readWithTimeout(dartReader, buffer, _timeout);
          await dartReader.close();
          await dartWriter.close();
          expect(bytesRead, equals(testData.length));
          expect(buffer, equals(testData));
        },
      );

      expect(result.success, isTrue, reason: result.error ?? '');
    });

    test('bidirectional data flow', () async {
      final dartToIostream = Uint8List.fromList([0x11, 0x22, 0x33]);
      final iostreamToDart = Uint8List.fromList([0x44, 0x55, 0x66]);

      final result = await _runWithFifos<_IoResult>(
        isolateEntry: _iostreamEchoIsolate,
        makeRequest: (paths, sendPort) => _IoRequest(
          paths: paths,
          sendPort: sendPort,
          expectedReadSize: dartToIostream.length,
          dataToWrite: iostreamToDart,
        ),
        dartWork: (dartWriter, dartReader) async {
          await dartWriter.writeFrom(dartToIostream);
          await dartWriter.close();

          final buffer = Uint8List(iostreamToDart.length);
          await _readWithTimeout(dartReader, buffer, _timeout);
          await dartReader.close();

          expect(buffer, equals(iostreamToDart));
        },
      );

      expect(result.success, isTrue, reason: result.error ?? '');
      expect(result.data, equals(dartToIostream));
    });
  });
}

// --- Test Infrastructure ---

class _FifoPaths {
  final String read;
  final String write;
  const _FifoPaths(this.read, this.write);
}

/// Runs a test with FIFO setup, isolate spawning, and cleanup.
Future<T> _runWithFifos<T>({
  required void Function(_IoRequest) isolateEntry,
  required _IoRequest Function(_FifoPaths paths, SendPort sendPort) makeRequest,
  required Future<void> Function(RandomAccessFile dartWriter, RandomAccessFile dartReader) dartWork,
}) async {
  final cleanup = _FifoCleanup();

  try {
    final paths = cleanup.createFifos();
    final receivePort = ReceivePort();
    cleanup.receivePort = receivePort;

    // Start opening FIFOs from Dart side FIRST (they block waiting for C side)
    final openFutures = Future.wait([
      File(paths.read).open(mode: FileMode.writeOnly),
      File(paths.write).open(mode: FileMode.read),
    ]);

    // Spawn isolate - when it starts, it will open C side and unblock our opens
    cleanup.isolate = await Isolate.spawn(
      isolateEntry,
      makeRequest(paths, receivePort.sendPort),
    ).timeout(_timeout, onTimeout: () => throw TimeoutException('Isolate spawn timed out'));

    // Wait for FIFO opens to complete
    final files = await openFutures
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Opening FIFOs timed out'));

    // Do the test-specific work
    await dartWork(files[0], files[1]);

    // Get result from isolate
    return await receivePort.first
        .timeout(_timeout, onTimeout: () => throw TimeoutException('Waiting for isolate result timed out')) as T;
  } finally {
    cleanup.dispose();
  }
}

/// Read with timeout - wraps synchronous read with a timer.
Future<int> _readWithTimeout(RandomAccessFile file, Uint8List buffer, Duration timeout) async {
  final completer = Completer<int>();
  final timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.completeError(TimeoutException('Read timed out'));
    }
  });

  unawaited(Future(() {
    try {
      final bytesRead = file.readIntoSync(buffer);
      if (!completer.isCompleted) completer.complete(bytesRead);
    } catch (e) {
      if (!completer.isCompleted) completer.completeError(e);
    }
  }));

  try {
    return await completer.future;
  } finally {
    timer.cancel();
  }
}

void _freeIfNotNull(ffi.Pointer<ffi.Pointer<ffi.Char>> ptr) {
  if (ptr.value != ffi.nullptr) calloc.free(ptr.value);
  calloc.free(ptr);
}

/// Manages FIFO cleanup.
class _FifoCleanup {
  ffi.Pointer<ffi.Pointer<bindings.dc_context_t>>? _context;
  ffi.Pointer<ffi.Pointer<ffi.Char>>? _readPathPtr;
  ffi.Pointer<ffi.Pointer<ffi.Char>>? _writePathPtr;
  ffi.Pointer<ffi.Char>? _directory;
  String? _readPath;
  String? _writePath;
  Isolate? isolate;
  ReceivePort? receivePort;

  _FifoPaths createFifos() {
    _context = calloc<ffi.Pointer<bindings.dc_context_t>>();
    bindings.dc_context_new(_context!);

    _readPathPtr = calloc<ffi.Pointer<ffi.Char>>();
    _writePathPtr = calloc<ffi.Pointer<ffi.Char>>();
    _directory = '/tmp'.toNativeUtf8().cast<ffi.Char>();

    final status = bindings.dc_fifos_create(
      _context!.value,
      _directory!,
      _readPathPtr!,
      _writePathPtr!,
    );

    if (status != bindings.dc_status_t.DC_STATUS_SUCCESS) {
      throw Exception('Failed to create FIFOs: $status');
    }

    _readPath = _readPathPtr!.value.cast<Utf8>().toDartString();
    _writePath = _writePathPtr!.value.cast<Utf8>().toDartString();

    return _FifoPaths(_readPath!, _writePath!);
  }

  void dispose() {
    isolate?.kill(priority: Isolate.immediate);
    receivePort?.close();

    for (final path in [_readPath, _writePath]) {
      if (path != null) {
        try {
          File(path).deleteSync();
        } catch (_) {}
      }
    }

    if (_readPathPtr != null) _freeIfNotNull(_readPathPtr!);
    if (_writePathPtr != null) _freeIfNotNull(_writePathPtr!);
    if (_directory != null) calloc.free(_directory!);
    if (_context != null) {
      bindings.dc_context_free(_context!.value);
      calloc.free(_context!);
    }
  }
}

// --- Isolate Communication ---

class _IoRequest {
  final _FifoPaths paths;
  final SendPort sendPort;
  final int? expectedReadSize;
  final Uint8List? dataToWrite;

  const _IoRequest({
    required this.paths,
    required this.sendPort,
    this.expectedReadSize,
    this.dataToWrite,
  });
}

class _IoResult {
  final bool success;
  final Uint8List? data;
  final String? error;

  const _IoResult({required this.success, this.data, this.error});
  const _IoResult.ok([this.data]) : success = true, error = null;
  const _IoResult.fail(this.error) : success = false, data = null;
}

// --- Isolate Entry Points ---

/// Opens iostream, optionally reads, optionally writes, returns result.
void _runIsolateWork(
  _IoRequest request, {
  bool doRead = false,
  bool doWrite = false,
}) {
  final context = calloc<ffi.Pointer<bindings.dc_context_t>>();
  bindings.dc_context_new(context);

  final iostream = calloc<ffi.Pointer<bindings.dc_iostream_t>>();
  final readPathNative = request.paths.read.toNativeUtf8().cast<ffi.Char>();
  final writePathNative = request.paths.write.toNativeUtf8().cast<ffi.Char>();

  try {
    final openStatus = bindings.dc_fifos_open(
      iostream,
      context.value,
      readPathNative,
      writePathNative,
    );

    if (openStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
      request.sendPort.send(_IoResult.fail('Failed to open FIFOs: $openStatus'));
      return;
    }

    Uint8List? readData;

    // Read if requested
    if (doRead && request.expectedReadSize != null) {
      final buffer = calloc<ffi.UnsignedChar>(256);
      final actual = calloc<ffi.Size>();

      final readStatus = bindings.dc_iostream_read(
        iostream.value,
        buffer.cast<ffi.Void>(),
        request.expectedReadSize!,
        actual,
      );

      if (readStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
        calloc.free(buffer);
        calloc.free(actual);
        bindings.dc_iostream_close(iostream.value);
        request.sendPort.send(_IoResult.fail('Failed to read: $readStatus'));
        return;
      }

      readData = Uint8List(actual.value);
      for (var i = 0; i < actual.value; i++) {
        readData[i] = buffer[i];
      }
      calloc.free(buffer);
      calloc.free(actual);
    }

    // Write if requested
    if (doWrite && request.dataToWrite != null) {
      final data = request.dataToWrite!;
      final buffer = calloc<ffi.UnsignedChar>(data.length);
      for (var i = 0; i < data.length; i++) {
        buffer[i] = data[i];
      }
      final actual = calloc<ffi.Size>();

      final writeStatus = bindings.dc_iostream_write(
        iostream.value,
        buffer.cast<ffi.Void>(),
        data.length,
        actual,
      );

      calloc.free(buffer);
      calloc.free(actual);

      if (writeStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
        bindings.dc_iostream_close(iostream.value);
        request.sendPort.send(_IoResult.fail('Failed to write: $writeStatus'));
        return;
      }
    }

    bindings.dc_iostream_close(iostream.value);
    request.sendPort.send(_IoResult.ok(readData));
  } finally {
    calloc.free(readPathNative);
    calloc.free(writePathNative);
    calloc.free(iostream);
    bindings.dc_context_free(context.value);
    calloc.free(context);
  }
}

void _iostreamReaderIsolate(_IoRequest request) {
  _runIsolateWork(request, doRead: true);
}

void _iostreamWriterIsolate(_IoRequest request) {
  _runIsolateWork(request, doWrite: true);
}

void _iostreamEchoIsolate(_IoRequest request) {
  _runIsolateWork(request, doRead: true, doWrite: true);
}
