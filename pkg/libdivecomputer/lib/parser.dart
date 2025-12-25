import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:divestore/divestore.dart';
import 'package:ffi/ffi.dart';

import 'libdivecomputer_bindings_generated.dart' as dc;

// --- Parser Functions ---

/// Parses a dive from raw data using libdivecomputer.
///
/// This function must be called from an isolate where FFI is available.
/// The [parser] must be a valid dc_parser_t pointer created via dc_parser_new.
ComputerDive parseDiveFromParser(ffi.Pointer<dc.dc_parser_t> parser, {String? fingerprint}) {
  final builder = ComputerDiveBuilder()..fingerprint = fingerprint;

  // --- DateTime ---
  final datetime = calloc<dc.dc_datetime_t>();
  if (dc.dc_parser_get_datetime(parser, datetime) == dc.dc_status_t.DC_STATUS_SUCCESS) {
    builder.dateTime = DateTime(datetime.ref.year, datetime.ref.month, datetime.ref.day, datetime.ref.hour, datetime.ref.minute, datetime.ref.second);
  }
  calloc.free(datetime);

  // --- Dive Time ---
  final diveTimePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVETIME, diveTimePtr.cast())) {
    builder.diveTime = diveTimePtr.value;
  }
  calloc.free(diveTimePtr);

  // --- Max Depth ---
  final maxDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_MAXDEPTH, maxDepthPtr.cast())) {
    builder.maxDepth = maxDepthPtr.value;
  }
  calloc.free(maxDepthPtr);

  // --- Avg Depth ---
  final avgDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_AVGDEPTH, avgDepthPtr.cast())) {
    builder.avgDepth = avgDepthPtr.value;
  }
  calloc.free(avgDepthPtr);

  // --- Surface Temperature ---
  final surfaceTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_SURFACE, surfaceTempPtr.cast())) {
    builder.surfaceTemperature = surfaceTempPtr.value;
  }
  calloc.free(surfaceTempPtr);

  // --- Min Temperature ---
  final minTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MINIMUM, minTempPtr.cast())) {
    builder.minTemperature = minTempPtr.value;
  }
  calloc.free(minTempPtr);

  // --- Max Temperature ---
  final maxTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MAXIMUM, maxTempPtr.cast())) {
    builder.maxTemperature = maxTempPtr.value;
  }
  calloc.free(maxTempPtr);

  // --- Atmospheric Pressure ---
  final atmosphericPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_ATMOSPHERIC, atmosphericPtr.cast())) {
    builder.atmosphericPressure = atmosphericPtr.value;
  }
  calloc.free(atmosphericPtr);

  // --- Salinity ---
  final salinityPtr = calloc<dc.dc_salinity_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_SALINITY, salinityPtr.cast())) {
    final waterType = WaterType.fromDcValue(salinityPtr.ref.type);
    if (waterType != null) {
      builder.salinity = Salinity(type: waterType, density: salinityPtr.ref.density);
    }
  }
  calloc.free(salinityPtr);

  // --- Dive Mode ---
  final diveModePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVEMODE, diveModePtr.cast())) {
    builder.diveMode = DiveMode.fromDcValue(diveModePtr.value);
  }
  calloc.free(diveModePtr);

  // --- Deco Model ---
  final decoModelPtr = calloc<dc.dc_decomodel_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DECOMODEL, decoModelPtr.cast())) {
    final type = DecoModelType.fromDcValue(decoModelPtr.ref.type);
    int? gfLow, gfHigh;
    if (type == DecoModelType.buhlmann) {
      gfLow = decoModelPtr.ref.params.gf.low;
      gfHigh = decoModelPtr.ref.params.gf.high;
    }
    builder.decoModel = DecoModel(type: type, conservatism: decoModelPtr.ref.conservatism, gfLow: gfLow, gfHigh: gfHigh);
  }
  calloc.free(decoModelPtr);

  // --- Location ---
  final locationPtr = calloc<dc.dc_location_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_LOCATION, locationPtr.cast())) {
    builder.location = Location(
      latitude: locationPtr.ref.latitude,
      longitude: locationPtr.ref.longitude,
      altitude: locationPtr.ref.altitude != 0 ? locationPtr.ref.altitude : null,
    );
  }
  calloc.free(locationPtr);

  // --- Gas Mixes ---
  final gasMixCountPtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_GASMIX_COUNT, gasMixCountPtr.cast())) {
    final count = gasMixCountPtr.value;
    final gasMixPtr = calloc<dc.dc_gasmix_t>();
    for (var i = 0; i < count; i++) {
      if (_getFieldIndexed(parser, dc.dc_field_type_t.DC_FIELD_GASMIX, i, gasMixPtr.cast())) {
        builder.gasMixes.add(
          GasMix(
            oxygen: gasMixPtr.ref.oxygen,
            helium: gasMixPtr.ref.helium,
            nitrogen: gasMixPtr.ref.nitrogen,
            usage: GasUsage.fromDcValue(gasMixPtr.ref.usage),
          ),
        );
      }
    }
    calloc.free(gasMixPtr);
  }
  calloc.free(gasMixCountPtr);

  // --- Tanks ---
  final tankCountPtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TANK_COUNT, tankCountPtr.cast())) {
    final count = tankCountPtr.value;
    final tankPtr = calloc<dc.dc_tank_t>();
    for (var i = 0; i < count; i++) {
      if (_getFieldIndexed(parser, dc.dc_field_type_t.DC_FIELD_TANK, i, tankPtr.cast())) {
        // DC_GASMIX_UNKNOWN is 0xFFFFFFFF
        final gasMixIndex = tankPtr.ref.gasmix == 0xFFFFFFFF ? null : tankPtr.ref.gasmix;
        builder.tanks.add(
          Tank(
            gasMixIndex: gasMixIndex,
            volumeType: TankVolumeType.fromDcValue(tankPtr.ref.type),
            volume: tankPtr.ref.volume,
            workPressure: tankPtr.ref.workpressure > 0 ? tankPtr.ref.workpressure : null,
            beginPressure: tankPtr.ref.beginpressure > 0 ? tankPtr.ref.beginpressure : null,
            endPressure: tankPtr.ref.endpressure > 0 ? tankPtr.ref.endpressure : null,
            usage: GasUsage.fromDcValue(tankPtr.ref.usage),
          ),
        );
      }
    }
    calloc.free(tankPtr);
  }
  calloc.free(tankCountPtr);

  // --- Samples ---
  _parseSamples(parser, builder);

  return builder.build();
}

/// Helper to get a field from the parser.
bool _getField(ffi.Pointer<dc.dc_parser_t> parser, dc.dc_field_type_t type, ffi.Pointer<ffi.Void> value) {
  return dc.dc_parser_get_field(parser, type, 0, value) == dc.dc_status_t.DC_STATUS_SUCCESS;
}

/// Helper to get an indexed field from the parser.
bool _getFieldIndexed(ffi.Pointer<dc.dc_parser_t> parser, dc.dc_field_type_t type, int index, ffi.Pointer<ffi.Void> value) {
  return dc.dc_parser_get_field(parser, type, index, value) == dc.dc_status_t.DC_STATUS_SUCCESS;
}

/// Global state for sample callback (needed because NativeCallable can't capture closures).
ComputerDiveBuilder? _currentDiveBuilder;
ComputerSampleBuilder? _currentSampleBuilder;

/// Parse samples from the parser.
void _parseSamples(ffi.Pointer<dc.dc_parser_t> parser, ComputerDiveBuilder builder) {
  _currentDiveBuilder = builder;
  _currentSampleBuilder = ComputerSampleBuilder();

  final callback = ffi.NativeCallable<dc.dc_sample_callback_tFunction>.isolateLocal(_sampleCallback);

  dc.dc_parser_samples_foreach(parser, callback.nativeFunction, ffi.nullptr);

  callback.close();

  // Add the last sample if it has data
  if (_currentSampleBuilder!.time != null) {
    builder.samples.add(_currentSampleBuilder!.build());
  }

  _currentDiveBuilder = null;
  _currentSampleBuilder = null;
}

/// Sample callback for dc_parser_samples_foreach.
void _sampleCallback(int typeValue, ffi.Pointer<dc.dc_sample_value_t> value, ffi.Pointer<ffi.Void> userdata) {
  final builder = _currentSampleBuilder!;
  final diveBuilder = _currentDiveBuilder!;
  final type = dc.dc_sample_type_t.fromValue(typeValue);

  switch (type) {
    case dc.dc_sample_type_t.DC_SAMPLE_TIME:
      // New sample starts with TIME - save previous sample if exists
      if (builder.time != null) {
        diveBuilder.samples.add(builder.build());
        builder.reset();
      }
      builder.time = value.ref.time / 1000;

    case dc.dc_sample_type_t.DC_SAMPLE_DEPTH:
      builder.depth = value.ref.depth;

    case dc.dc_sample_type_t.DC_SAMPLE_PRESSURE:
      builder.pressures.add(TankPressure(tankIndex: value.ref.pressure.tank, pressure: value.ref.pressure.value));

    case dc.dc_sample_type_t.DC_SAMPLE_TEMPERATURE:
      builder.temperature = value.ref.temperature;

    case dc.dc_sample_type_t.DC_SAMPLE_EVENT:
      builder.events.add(
        SampleEvent(
          type: SampleEventType.fromDcValue(value.ref.event.type),
          time: value.ref.event.time,
          flags: SampleEventFlags(value.ref.event.flags),
          value: value.ref.event.value,
        ),
      );

    case dc.dc_sample_type_t.DC_SAMPLE_RBT:
      builder.rbt = value.ref.rbt;

    case dc.dc_sample_type_t.DC_SAMPLE_HEARTBEAT:
      builder.heartbeat = value.ref.heartbeat;

    case dc.dc_sample_type_t.DC_SAMPLE_BEARING:
      builder.bearing = value.ref.bearing;

    case dc.dc_sample_type_t.DC_SAMPLE_VENDOR:
      final vendorData = value.ref.vendor;
      if (vendorData.size > 0 && vendorData.data != ffi.nullptr) {
        final bytes = Uint8List(vendorData.size);
        final dataPtr = vendorData.data.cast<ffi.Uint8>();
        for (var i = 0; i < vendorData.size; i++) {
          bytes[i] = dataPtr[i];
        }
        builder.vendorData.add(VendorData(type: vendorData.type, data: bytes.toString()));
      }

    case dc.dc_sample_type_t.DC_SAMPLE_SETPOINT:
      builder.setpoint = value.ref.setpoint;

    case dc.dc_sample_type_t.DC_SAMPLE_PPO2:
      builder.ppo2.add(Ppo2Reading(sensorIndex: value.ref.ppo2.sensor, value: value.ref.ppo2.value));

    case dc.dc_sample_type_t.DC_SAMPLE_CNS:
      builder.cns = value.ref.cns;

    case dc.dc_sample_type_t.DC_SAMPLE_DECO:
      builder.deco = DecoStatus(
        type: DecoStopType.fromDcValue(value.ref.deco.type),
        time: value.ref.deco.time,
        depth: value.ref.deco.depth,
        tts: value.ref.deco.tts,
      );

    case dc.dc_sample_type_t.DC_SAMPLE_GASMIX:
      builder.gasMixIndex = value.ref.gasmix;
  }
}
