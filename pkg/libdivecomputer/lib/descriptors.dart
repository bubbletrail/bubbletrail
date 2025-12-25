import 'dart:async';
import 'dart:ffi' as ffi;
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';

import 'libdivecomputer_bindings_generated.dart' as bindings;
import 'libdivecomputer.dart';

class ComputerDescriptor {
  final int handle;
  final String vendor;
  final String model;

  const ComputerDescriptor(this.handle, this.vendor, this.model);

  @override
  String toString() => "$vendor $model";
}

Future<List<ComputerDescriptor>> dcDescriptorIterate({String? filterForName}) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final request = IterateDescriptorsRequest(filterForName);
  final completer = Completer<List<ComputerDescriptor>>();
  _requests[request.id] = completer;
  helperIsolateSendPort.send(request);
  return completer.future;
}

Future<void> dcStartDownload(DownloadRequest request) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  // final completer = Completer<List<ComputerDescriptor>>();
  // _requests[request.id] = completer;
  helperIsolateSendPort.send(request);
  // return completer.future;
}

List<ComputerDescriptor> _dcDescriptorIterate(String? filterForName) {
  final filter = filterForName?.toNativeUtf8();
  final descs = <ComputerDescriptor>[];

  for (final (handle, desc) in _descriptorCache.indexed) {
    if (filter != null) {
      if (bindings.dc_descriptor_filter(desc, bindings.dc_transport_t.DC_TRANSPORT_BLE, filter.cast()) == 0) {
        bindings.dc_descriptor_free(desc);
        continue;
      }
    }

    final vendor = bindings.dc_descriptor_get_vendor(desc).cast<Utf8>().toDartString();
    final model = bindings.dc_descriptor_get_product(desc).cast<Utf8>().toDartString();
    descs.add(ComputerDescriptor(handle, vendor, model));
    bindings.dc_descriptor_free(desc);
  }

  return descs;
}

class RequestBase {
  static int _nextRequestId = 0;
  late final int id;

  RequestBase() {
    id = _nextRequestId;
    _nextRequestId++;
  }
}

class IterateDescriptorsRequest extends RequestBase {
  final String? filterForName;
  IterateDescriptorsRequest(this.filterForName);
}

class Response {
  final int id;
  final Object? result;

  const Response(this.id, this.result);
}

final Map<int, Completer<Object?>> _requests = <int, Completer<Object?>>{};

final _context = calloc<ffi.Pointer<bindings.dc_context_t>>();
final _descriptorCache = <ffi.Pointer<bindings.dc_descriptor_t>>[];

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is Response) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<Object?> completer = _requests[data.id]!;
        _requests.remove(data.id);
        completer.complete(data.result);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic req) {
        if (req is IterateDescriptorsRequest) {
          final result = _dcDescriptorIterate(req.filterForName);
          sendPort.send(Response(req.id, result));
          return;
        }
        if (req is DownloadRequest) {
          _downloadIsolateEntry(req);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${req.runtimeType}');
      });

    bindings.dc_context_new(_context);
    _initDescriptorCache();

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();

void _initDescriptorCache() {
  final it = calloc<ffi.Pointer<bindings.dc_iterator_t>>();
  bindings.dc_descriptor_iterator_new(it, _context.value);
  final desc = calloc<ffi.Pointer<bindings.dc_descriptor_t>>();
  while (bindings.dc_iterator_next(it.value, desc.cast()) == bindings.dc_status_t.DC_STATUS_SUCCESS) {
    _descriptorCache.add(desc.value);
  }
  bindings.dc_iterator_free(it.value);
}

/// Message sent to the download isolate to start the download.
class DownloadRequest extends RequestBase {
  final String readFifoPath;
  final String writeFifoPath;
  final int descriptorIndex;
  final SendPort sendPort;

  DownloadRequest({required this.readFifoPath, required this.writeFifoPath, required this.descriptorIndex, required this.sendPort});
}

/// Entry point for the download isolate.
void _downloadIsolateEntry(DownloadRequest request) {
  final sendPort = request.sendPort;

  // Set log level to see what's happening
  bindings.dc_context_set_loglevel(_context.value, bindings.dc_loglevel_t.DC_LOGLEVEL_ALL);

  if (request.descriptorIndex >= _descriptorCache.length) {
    sendPort.send(DownloadError('Invalid descriptor index'));
    return;
  }

  final descriptor = _descriptorCache[request.descriptorIndex];
  final model = bindings.dc_descriptor_get_product(descriptor).cast<Utf8>().toDartString();
  print('Got descriptor for $model');

  // Open FIFOs
  final iostream = calloc<ffi.Pointer<bindings.dc_iostream_t>>();
  final readPathNative = request.readFifoPath.toNativeUtf8().cast<ffi.Char>();
  final writePathNative = request.writeFifoPath.toNativeUtf8().cast<ffi.Char>();

  print('Download isolate: Opening FIFOs...');

  final openStatus = bindings.dc_fifos_open(iostream, _context.value, readPathNative, writePathNative);

  calloc.free(readPathNative);
  calloc.free(writePathNative);

  if (openStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
    sendPort.send(DownloadError('Failed to open FIFOs: $openStatus'));
    calloc.free(iostream);
    bindings.dc_context_free(_context.value);
    calloc.free(_context);
    return;
  }

  print('Download isolate: FIFOs opened, opening device...');

  // Open device
  final device = calloc<ffi.Pointer<bindings.dc_device_t>>();
  final deviceStatus = bindings.dc_device_open(device, _context.value, descriptor, iostream.value);

  if (deviceStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
    sendPort.send(DownloadError('Failed to open device: $deviceStatus'));
    bindings.dc_iostream_close(iostream.value);
    calloc.free(iostream);
    calloc.free(device);
    bindings.dc_context_free(_context.value);
    calloc.free(_context);
    return;
  }

  print('Download isolate: Device opened, setting up callbacks...');

  // Set up event callback using NativeCallable
  int diveCount = 0;

  final eventCallback = ffi.NativeCallable<bindings.dc_event_callback_tFunction>.listener((
    ffi.Pointer<bindings.dc_device_t> dev,
    int eventType,
    ffi.Pointer<ffi.Void> data,
    ffi.Pointer<ffi.Void> userdata,
  ) {
    if (eventType == bindings.dc_event_type_t.DC_EVENT_PROGRESS.value) {
      final progress = data.cast<bindings.dc_event_progress_t>().ref;
      sendPort.send(DownloadProgressEvent(DownloadProgress(progress.current, progress.maximum)));
    } else if (eventType == bindings.dc_event_type_t.DC_EVENT_DEVINFO.value) {
      final devinfo = data.cast<bindings.dc_event_devinfo_t>().ref;
      sendPort.send(DownloadDeviceInfo(DeviceInfo(model: devinfo.model, firmware: devinfo.firmware, serial: devinfo.serial)));
    }
  });

  final eventsStatus = bindings.dc_device_set_events(
    device.value,
    bindings.dc_event_type_t.DC_EVENT_PROGRESS.value | bindings.dc_event_type_t.DC_EVENT_DEVINFO.value,
    eventCallback.nativeFunction,
    ffi.nullptr,
  );

  if (eventsStatus != bindings.dc_status_t.DC_STATUS_SUCCESS) {
    print('Warning: Failed to set event callback: $eventsStatus');
  }

  // Set up dive callback using NativeCallable.isolateLocal (supports non-void return)
  // The exceptionalReturn value (0) is returned if the callback throws an exception
  final diveCallback = ffi.NativeCallable<bindings.dc_dive_callback_tFunction>.isolateLocal(
    (ffi.Pointer<ffi.UnsignedChar> data, int size, ffi.Pointer<ffi.UnsignedChar> fingerprint, int fsize, ffi.Pointer<ffi.Void> userdata) {
      diveCount++;
      print('Download isolate: Received dive #$diveCount, size=$size bytes');

      // Parse basic dive info
      final parser = calloc<ffi.Pointer<bindings.dc_parser_t>>();
      final parserStatus = bindings.dc_parser_new(parser, device.value, data, size);

      if (parserStatus == bindings.dc_status_t.DC_STATUS_SUCCESS) {
        // Get datetime
        final datetime = calloc<bindings.dc_datetime_t>();
        DateTime? diveDateTime;
        if (bindings.dc_parser_get_datetime(parser.value, datetime) == bindings.dc_status_t.DC_STATUS_SUCCESS) {
          diveDateTime = DateTime(datetime.ref.year, datetime.ref.month, datetime.ref.day, datetime.ref.hour, datetime.ref.minute, datetime.ref.second);
        }
        calloc.free(datetime);

        // Get dive time
        final diveTimePtr = calloc<ffi.UnsignedInt>();
        Duration? diveTime;
        if (bindings.dc_parser_get_field(parser.value, bindings.dc_field_type_t.DC_FIELD_DIVETIME, 0, diveTimePtr.cast()) ==
            bindings.dc_status_t.DC_STATUS_SUCCESS) {
          diveTime = Duration(seconds: diveTimePtr.value);
        }
        calloc.free(diveTimePtr);

        // Get max depth
        final maxDepthPtr = calloc<ffi.Double>();
        double? maxDepth;
        if (bindings.dc_parser_get_field(parser.value, bindings.dc_field_type_t.DC_FIELD_MAXDEPTH, 0, maxDepthPtr.cast()) ==
            bindings.dc_status_t.DC_STATUS_SUCCESS) {
          maxDepth = maxDepthPtr.value;
        }
        calloc.free(maxDepthPtr);

        final diveInfo = DiveInfo(number: diveCount, dateTime: diveDateTime, diveTime: diveTime, maxDepth: maxDepth);

        print('Download isolate: $diveInfo');
        sendPort.send(DownloadDiveReceived(diveInfo));

        bindings.dc_parser_destroy(parser.value);
      } else {
        print('Download isolate: Failed to parse dive: $parserStatus');
        sendPort.send(DownloadDiveReceived(DiveInfo(number: diveCount)));
      }

      calloc.free(parser);

      // Return 1 to continue, 0 to abort
      return 1;
    },
    exceptionalReturn: 0, // Return 0 (abort) if exception is thrown
  );

  print('Download isolate: Starting dive download...');

  // Download dives
  final foreachStatus = bindings.dc_device_foreach(device.value, diveCallback.nativeFunction, ffi.nullptr);

  print('Download isolate: Download finished with status: $foreachStatus');

  // Cleanup
  // eventCallback.close();
  diveCallback.close();

  bindings.dc_device_close(device.value);
  calloc.free(device);

  bindings.dc_iostream_close(iostream.value);
  calloc.free(iostream);

  if (foreachStatus == bindings.dc_status_t.DC_STATUS_SUCCESS) {
    sendPort.send(DownloadCompleted(diveCount));
  } else {
    sendPort.send(DownloadError('Download failed: $foreachStatus'));
  }
}
