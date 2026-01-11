import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:divestore/divestore.dart';
import 'package:ffi/ffi.dart';
import 'package:logging/logging.dart';

import 'libdivecomputer.dart';
import 'libdivecomputer_bindings_generated.dart' as bindings;

final _log = Logger('libdivecomputer.download');

/// Represents a BLE characteristic pair for communication.
class BleCharacteristics {
  final Stream<List<int>> read;
  final Future<void> Function(List<int> data) write;

  const BleCharacteristics({required this.read, required this.write});
}

/// Progress information during download.
class DownloadProgress {
  final int current;
  final int maximum;

  const DownloadProgress(this.current, this.maximum);

  double get fraction => maximum > 0 ? current / maximum : 0;

  @override
  String toString() => '$current / $maximum';
}

/// Device information received during download.
class DeviceInfo {
  final int model;
  final int firmware;
  final String serial;

  const DeviceInfo({required this.model, required this.firmware, required this.serial});

  @override
  String toString() => 'Model: $model, FW: $firmware, Serial: $serial';
}

/// Events emitted during download.
sealed class DownloadEvent {}

class DownloadStarted extends DownloadEvent {}

/// Indicates the device is waiting for user action (e.g., activating transfer mode).
class DownloadWaiting extends DownloadEvent {}

class DownloadProgressEvent extends DownloadEvent {
  final DownloadProgress progress;
  DownloadProgressEvent(this.progress);
}

class DownloadDeviceInfo extends DownloadEvent {
  final DeviceInfo info;
  DownloadDeviceInfo(this.info);
}

class DownloadDiveReceived extends DownloadEvent {
  final Log dive;
  DownloadDiveReceived(this.dive);
}

class DownloadCompleted extends DownloadEvent {
  DownloadCompleted();
}

class DownloadError extends DownloadEvent {
  final String message;
  DownloadError(this.message);
}

/// Starts a dive log download from a BLE dive computer.
///
/// Returns a stream of [DownloadEvent]s indicating progress and results.
Stream<DownloadEvent> startDownload({
  required BleCharacteristics ble,
  required ComputerDescriptor computer,
  required String fifoDirectory,
  List<int>? ldcFingerprint,
  DateTime? lastLogDate,
}) async* {
  yield DownloadStarted();

  // Create FIFOs
  final readPathPtr = calloc<ffi.Pointer<ffi.Char>>();
  final writePathPtr = calloc<ffi.Pointer<ffi.Char>>();

  final context = calloc<ffi.Pointer<bindings.dc_context_t>>();
  bindings.dc_context_new(context);

  String? readPath;
  String? writePath;
  RandomAccessFile? toDeviceFifo;
  RandomAccessFile? fromDeviceFifo;
  ReceivePort? receivePort;

  try {
    final directoryNative = fifoDirectory.toNativeUtf8().cast<ffi.Char>();
    try {
      final status = bindings.dc_fifos_create(context.value, directoryNative, readPathPtr, writePathPtr);
      if (status != bindings.dc_status_t.DC_STATUS_SUCCESS) {
        yield DownloadError('Failed to create FIFOs: $status');
        return;
      }
    } finally {
      calloc.free(directoryNative);
    }

    readPath = readPathPtr.value.cast<Utf8>().toDartString();
    writePath = writePathPtr.value.cast<Utf8>().toDartString();

    // Set up receive port for messages from download isolate
    receivePort = ReceivePort();
    final eventController = StreamController<DownloadEvent>();

    receivePort.listen((message) {
      if (message is DownloadEvent) {
        eventController.add(message);
      }
    });

    // Start opening FIFOs from Dart side FIRST (they block waiting for C side)
    // We write to the "read" FIFO (what libdivecomputer reads)
    // We read from the "write" FIFO (what libdivecomputer writes)
    final fifoOpenFuture = Future.wait([File(readPath).open(mode: FileMode.writeOnly), File(writePath).open(mode: FileMode.read)]);

    // Spawn the download isolate - when it starts, it will open C side and unblock our opens
    final request = DownloadRequest(
      readFifoPath: readPath,
      writeFifoPath: writePath,
      descriptorIndex: computer.handle,
      sendPort: receivePort.sendPort,
      ldcFingerprint: ldcFingerprint,
      lastLogDate: lastLogDate,
    );
    await dcStartDownload(request);

    // Now wait for FIFO opens to complete
    final files = await fifoOpenFuture;
    toDeviceFifo = files[0];
    fromDeviceFifo = files[1];

    // Start BLE -> FIFO bridge (in background)
    bool running = true;
    unawaited(
      Future.microtask(() async {
        await for (final packet in ble.read) {
          try {
            await toDeviceFifo?.writeFrom(packet);
          } catch (e) {
            if (running) {
              _log.warning('failed to write BLE data to FIFO', e);
            }
            break;
          }
        }
      }),
    );

    // Start FIFO -> BLE bridge (in background)
    unawaited(
      Future.microtask(() async {
        final buffer = Uint8List(512);
        while (running) {
          try {
            final bytesRead = (await fromDeviceFifo?.readInto(buffer)) ?? 0;
            if (bytesRead > 0) {
              await ble.write(buffer.sublist(0, bytesRead));
            }
          } catch (e) {
            if (running) {
              _log.warning('failed to read from FIFO', e);
            }
            break;
          }
        }
      }),
    );

    // Yield events from the download isolate
    await for (final event in eventController.stream) {
      yield event;
      if (event is DownloadCompleted || event is DownloadError) {
        running = false;
        break;
      }
    }
  } finally {
    try {
      toDeviceFifo?.closeSync();
    } catch (_) {}

    try {
      fromDeviceFifo?.closeSync();
    } catch (_) {}

    receivePort?.close();

    // Delete FIFOs
    if (readPath != null) {
      try {
        await File(readPath).delete();
      } catch (_) {}
    }
    if (writePath != null) {
      try {
        await File(writePath).delete();
      } catch (_) {}
    }

    // Free native memory
    if (readPathPtr.value != ffi.nullptr) {
      calloc.free(readPathPtr.value);
    }
    if (writePathPtr.value != ffi.nullptr) {
      calloc.free(writePathPtr.value);
    }
    calloc.free(readPathPtr);
    calloc.free(writePathPtr);

    bindings.dc_context_free(context.value);
    calloc.free(context);
  }
}
