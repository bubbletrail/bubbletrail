import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:libdivecomputer/libdivecomputer.dart';
import 'package:libdivecomputer/libdivecomputer_bindings_generated.dart' as bindings;
import 'package:test/test.dart';

void main() {
  group('Dive parser', () {
    test('parses Shearwater Perdix dive data', () {
      // Load the dive data
      final testFile = File('test/shearwater-perdix-dive.bin');
      expect(testFile.existsSync(), isTrue, reason: 'Test file not found');
      final diveData = testFile.readAsBytesSync();

      // Create context
      final context = calloc<ffi.Pointer<bindings.dc_context_t>>();
      var status = bindings.dc_context_new(context);
      expect(status, bindings.dc_status_t.DC_STATUS_SUCCESS, reason: 'Failed to create context');

      ffi.Pointer<bindings.dc_descriptor_t>? descriptor;

      try {
        // Find the Shearwater Perdix descriptor
        descriptor = _findDescriptor(context.value, 'Shearwater', 'Perdix');
        expect(descriptor, isNotNull, reason: 'Shearwater Perdix descriptor not found');

        // Create parser using dc_parser_new2
        final parser = calloc<ffi.Pointer<bindings.dc_parser_t>>();
        final dataPtr = calloc<ffi.UnsignedChar>(diveData.length);
        for (var i = 0; i < diveData.length; i++) {
          dataPtr[i] = diveData[i];
        }

        try {
          status = bindings.dc_parser_new2(parser, context.value, descriptor!, dataPtr, diveData.length);
          expect(status, bindings.dc_status_t.DC_STATUS_SUCCESS, reason: 'Failed to create parser: $status');

          // Parse the dive
          final dive = parseDiveFromParser(parser.value, diveNumber: 1);

          // --- Verify basic info ---
          expect(dive.number, 1);
          expect(dive.dateTime, DateTime(2025, 11, 22, 13, 54, 17));
          expect(dive.diveTime, const Duration(minutes: 87, seconds: 48));

          // --- Verify depth ---
          expect(dive.maxDepth, closeTo(22.6, 0.1));

          // --- Verify environment ---
          expect(dive.salinity, isNotNull);
          expect(dive.salinity!.type, WaterType.salt);
          expect(dive.salinity!.density, closeTo(1020, 1));
          expect(dive.atmosphericPressure, closeTo(1.008, 0.001));

          // --- Verify dive mode and deco model ---
          expect(dive.diveMode, DiveMode.openCircuit);
          expect(dive.decoModel, isNotNull);
          expect(dive.decoModel!.type, DecoModelType.buhlmann);
          expect(dive.decoModel!.gfLow, 45);
          expect(dive.decoModel!.gfHigh, 85);

          // --- Verify gas mixes ---
          expect(dive.gasMixes.length, 1);
          expect(dive.gasMixes[0].isAir, isTrue);
          expect(dive.gasMixes[0].o2Percent, 21);
          expect(dive.gasMixes[0].hePercent, 0);

          // --- Verify tanks ---
          expect(dive.tanks.length, 1);
          expect(dive.tanks[0].beginPressure, closeTo(206, 1));
          expect(dive.tanks[0].endPressure, closeTo(89, 1));

          // --- Verify samples ---
          expect(dive.samples.length, 2787);

          // First sample (at surface, starting descent)
          final firstSample = dive.samples[0];
          expect(firstSample.time.inSeconds, 2);
          expect(firstSample.depth, closeTo(1.3, 0.1));
          expect(firstSample.temperature, closeTo(8.0, 0.1));
          expect(firstSample.pressures.length, 1);
          expect(firstSample.pressures[0].tankIndex, 0);
          expect(firstSample.pressures[0].pressure, closeTo(206, 1));

          // Sample from middle of dive (around max depth area, ~sample 500)
          // At 1000s into the dive (sample index ~500)
          final midSample = dive.samples[500];
          expect(midSample.time.inSeconds, 1002);
          expect(midSample.depth, isNotNull);
          expect(midSample.depth!, greaterThan(15)); // Should be at depth
          expect(midSample.temperature, isNotNull);

          // Sample near the deepest point
          // Find the sample with max depth
          final deepestSample = dive.samples.reduce((a, b) => (a.depth ?? 0) > (b.depth ?? 0) ? a : b);
          expect(deepestSample.depth, closeTo(22.6, 0.1));

          // Last sample (at surface)
          final lastSample = dive.samples.last;
          expect(lastSample.time.inSeconds, 5574);
          expect(lastSample.depth, closeTo(0.0, 0.1));
          expect(lastSample.deco, isNotNull);
          expect(lastSample.deco!.type, DecoStopType.ndl);
        } finally {
          if (parser.value != ffi.nullptr) {
            bindings.dc_parser_destroy(parser.value);
          }
          calloc.free(parser);
          calloc.free(dataPtr);
        }
      } finally {
        if (descriptor != null) {
          bindings.dc_descriptor_free(descriptor);
        }
        bindings.dc_context_free(context.value);
        calloc.free(context);
      }
    });
  });
}

/// Finds a descriptor by vendor and product name.
ffi.Pointer<bindings.dc_descriptor_t>? _findDescriptor(ffi.Pointer<bindings.dc_context_t> context, String vendor, String product) {
  final iterator = calloc<ffi.Pointer<bindings.dc_iterator_t>>();
  final status = bindings.dc_descriptor_iterator_new(iterator, context);
  if (status != bindings.dc_status_t.DC_STATUS_SUCCESS) {
    calloc.free(iterator);
    return null;
  }

  final desc = calloc<ffi.Pointer<bindings.dc_descriptor_t>>();
  ffi.Pointer<bindings.dc_descriptor_t>? result;

  while (bindings.dc_iterator_next(iterator.value, desc.cast()) == bindings.dc_status_t.DC_STATUS_SUCCESS) {
    final descVendor = bindings.dc_descriptor_get_vendor(desc.value).cast<Utf8>().toDartString();
    final descProduct = bindings.dc_descriptor_get_product(desc.value).cast<Utf8>().toDartString();

    if (descVendor == vendor && descProduct == product) {
      // Found it - keep this descriptor
      result = desc.value;
      break;
    }

    bindings.dc_descriptor_free(desc.value);
  }

  bindings.dc_iterator_free(iterator.value);
  calloc.free(iterator);
  calloc.free(desc);

  return result;
}
