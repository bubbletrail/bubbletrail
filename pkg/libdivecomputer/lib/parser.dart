import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:btmodels/btmodels.dart';
import 'package:ffi/ffi.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';

import 'libdivecomputer_bindings_generated.dart' as dc;

// --- Parser Functions ---

/// Parses a dive from raw data using libdivecomputer.
///
/// This function must be called from an isolate where FFI is available.
/// The [parser] must be a valid dc_parser_t pointer created via dc_parser_new.
Log parseDiveFromParser(ffi.Pointer<dc.dc_parser_t> parser, {Uint8List? fingerprint, String? model, String? serial}) {
  final log = Log();
  if (fingerprint != null) {
    log.ldcFingerprint = fingerprint;
  }
  if (model != null) {
    log.model = model;
  }
  if (serial != null) {
    log.serial = serial;
  }

  // --- DateTime ---
  final datetime = calloc<dc.dc_datetime_t>();
  if (dc.dc_parser_get_datetime(parser, datetime) == dc.dc_status_t.DC_STATUS_SUCCESS) {
    final dt = DateTime(datetime.ref.year, datetime.ref.month, datetime.ref.day, datetime.ref.hour, datetime.ref.minute, datetime.ref.second);
    log.dateTime = Timestamp.fromDateTime(dt);
  }
  calloc.free(datetime);

  // --- Dive Time ---
  final diveTimePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVETIME, diveTimePtr.cast())) {
    log.diveTime = diveTimePtr.value;
  }
  calloc.free(diveTimePtr);

  // --- Max Depth ---
  final maxDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_MAXDEPTH, maxDepthPtr.cast())) {
    log.maxDepth = maxDepthPtr.value;
  }
  calloc.free(maxDepthPtr);

  // --- Avg Depth ---
  final avgDepthPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_AVGDEPTH, avgDepthPtr.cast())) {
    log.avgDepth = avgDepthPtr.value;
  }
  calloc.free(avgDepthPtr);

  // --- Surface Temperature ---
  final surfaceTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_SURFACE, surfaceTempPtr.cast())) {
    log.surfaceTemperature = surfaceTempPtr.value;
  }
  calloc.free(surfaceTempPtr);

  // --- Min Temperature ---
  final minTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MINIMUM, minTempPtr.cast())) {
    log.minTemperature = minTempPtr.value;
  }
  calloc.free(minTempPtr);

  // --- Max Temperature ---
  final maxTempPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_TEMPERATURE_MAXIMUM, maxTempPtr.cast())) {
    log.maxTemperature = maxTempPtr.value;
  }
  calloc.free(maxTempPtr);

  // --- Atmospheric Pressure ---
  final atmosphericPtr = calloc<ffi.Double>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_ATMOSPHERIC, atmosphericPtr.cast())) {
    log.atmosphericPressure = atmosphericPtr.value;
  }
  calloc.free(atmosphericPtr);

  // --- Salinity ---
  final salinityPtr = calloc<dc.dc_salinity_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_SALINITY, salinityPtr.cast())) {
    final waterType = _convertWaterType(salinityPtr.ref.type);
    if (waterType != null) {
      log.salinity = Salinity(type: waterType, density: salinityPtr.ref.density);
    }
  }
  calloc.free(salinityPtr);

  // --- Dive Mode ---
  final diveModePtr = calloc<ffi.UnsignedInt>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DIVEMODE, diveModePtr.cast())) {
    final mode = _convertDiveMode(diveModePtr.value);
    if (mode != null) {
      log.diveMode = mode;
    }
  }
  calloc.free(diveModePtr);

  // --- Deco Model ---
  final decoModelPtr = calloc<dc.dc_decomodel_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_DECOMODEL, decoModelPtr.cast())) {
    final type = _convertDecoModelType(decoModelPtr.ref.type);
    int? gfLow, gfHigh;
    if (type == DecoModelType.DECO_MODEL_TYPE_BUHLMANN) {
      gfLow = decoModelPtr.ref.params.gf.low;
      gfHigh = decoModelPtr.ref.params.gf.high;
    }
    log.decoModel = DecoModel(type: type, conservatism: decoModelPtr.ref.conservatism, gfLow: gfLow, gfHigh: gfHigh);
  }
  calloc.free(decoModelPtr);

  // --- Location ---
  final locationPtr = calloc<dc.dc_location_t>();
  if (_getField(parser, dc.dc_field_type_t.DC_FIELD_LOCATION, locationPtr.cast())) {
    log.position = Position(
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
        log.gasMixes.add(
          GasMix(oxygen: gasMixPtr.ref.oxygen, helium: gasMixPtr.ref.helium, nitrogen: gasMixPtr.ref.nitrogen, usage: _convertGasUsage(gasMixPtr.ref.usage)),
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
        log.tanks.add(
          Tank(
            gasMixIndex: gasMixIndex,
            volumeType: _convertTankVolumeType(tankPtr.ref.type),
            volume: tankPtr.ref.volume,
            workPressure: tankPtr.ref.workpressure > 0 ? tankPtr.ref.workpressure : null,
            beginPressure: tankPtr.ref.beginpressure > 0 ? tankPtr.ref.beginpressure : null,
            endPressure: tankPtr.ref.endpressure > 0 ? tankPtr.ref.endpressure : null,
            usage: _convertGasUsage(tankPtr.ref.usage),
          ),
        );
      }
    }
    calloc.free(tankPtr);
  }
  calloc.free(tankCountPtr);

  // --- Samples ---
  _parseSamples(parser, log);

  return log;
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
Log? _currentDive;
LogSample? _currentSample;

/// Parse samples from the parser.
void _parseSamples(ffi.Pointer<dc.dc_parser_t> parser, Log dive) {
  _currentDive = dive;
  _currentSample = null;

  final callback = ffi.NativeCallable<dc.dc_sample_callback_tFunction>.isolateLocal(_sampleCallback);

  dc.dc_parser_samples_foreach(parser, callback.nativeFunction, ffi.nullptr);

  callback.close();

  // Add the last sample if it has data
  if (_currentSample != null) {
    dive.samples.add(_currentSample!);
  }

  _currentDive = null;
  _currentSample = null;
}

/// Sample callback for dc_parser_samples_foreach.
void _sampleCallback(int typeValue, ffi.Pointer<dc.dc_sample_value_t> value, ffi.Pointer<ffi.Void> userdata) {
  final dive = _currentDive!;
  final type = dc.dc_sample_type_t.fromValue(typeValue);

  switch (type) {
    case dc.dc_sample_type_t.DC_SAMPLE_TIME:
      // New sample starts with TIME - save previous sample if exists
      if (_currentSample != null) {
        dive.samples.add(_currentSample!);
      }
      _currentSample = LogSample(time: value.ref.time / 1000);

    case dc.dc_sample_type_t.DC_SAMPLE_DEPTH:
      _currentSample?.depth = value.ref.depth;

    case dc.dc_sample_type_t.DC_SAMPLE_PRESSURE:
      _currentSample?.pressures.add(TankPressure(tankIndex: value.ref.pressure.tank, pressure: value.ref.pressure.value));

    case dc.dc_sample_type_t.DC_SAMPLE_TEMPERATURE:
      _currentSample?.temperature = value.ref.temperature;

    case dc.dc_sample_type_t.DC_SAMPLE_EVENT:
      _currentSample?.events.add(
        SampleEvent(
          type: _convertSampleEventType(value.ref.event.type),
          time: value.ref.event.time,
          flags: value.ref.event.flags,
          value: value.ref.event.value,
        ),
      );

    case dc.dc_sample_type_t.DC_SAMPLE_RBT:
      _currentSample?.rbt = value.ref.rbt;

    case dc.dc_sample_type_t.DC_SAMPLE_HEARTBEAT:
      _currentSample?.heartbeat = value.ref.heartbeat;

    case dc.dc_sample_type_t.DC_SAMPLE_BEARING:
      _currentSample?.bearing = value.ref.bearing;

    case dc.dc_sample_type_t.DC_SAMPLE_VENDOR:
      final vendorData = value.ref.vendor;
      if (vendorData.size > 0 && vendorData.data != ffi.nullptr) {
        final bytes = Uint8List(vendorData.size);
        final dataPtr = vendorData.data.cast<ffi.Uint8>();
        for (var i = 0; i < vendorData.size; i++) {
          bytes[i] = dataPtr[i];
        }
        _currentSample?.vendorData.add(VendorData(type: vendorData.type, data: bytes));
      }

    case dc.dc_sample_type_t.DC_SAMPLE_SETPOINT:
      _currentSample?.setpoint = value.ref.setpoint;

    case dc.dc_sample_type_t.DC_SAMPLE_PPO2:
      _currentSample?.ppo2.add(Ppo2Reading(sensorIndex: value.ref.ppo2.sensor, value: value.ref.ppo2.value));

    case dc.dc_sample_type_t.DC_SAMPLE_CNS:
      _currentSample?.cns = value.ref.cns;

    case dc.dc_sample_type_t.DC_SAMPLE_DECO:
      _currentSample?.deco = DecoStatus(
        type: _convertDecoStopType(value.ref.deco.type),
        time: value.ref.deco.time,
        depth: value.ref.deco.depth,
        tts: value.ref.deco.tts,
      );

    case dc.dc_sample_type_t.DC_SAMPLE_GASMIX:
      _currentSample?.gasMixIndex = value.ref.gasmix;
  }
}

// --- Enum Conversion Functions ---

/// Convert libdivecomputer water type to protobuf WaterType.
WaterType? _convertWaterType(int dcValue) {
  return switch (dcValue) {
    0 => WaterType.WATER_TYPE_FRESH,
    1 => WaterType.WATER_TYPE_SALT,
    _ => null,
  };
}

/// Convert libdivecomputer dive mode to protobuf DiveMode.
DiveMode? _convertDiveMode(int dcValue) {
  return switch (dcValue) {
    0 => DiveMode.DIVE_MODE_FREEDIVE,
    1 => DiveMode.DIVE_MODE_GAUGE,
    2 => DiveMode.DIVE_MODE_OPENCIRCUIT,
    3 => DiveMode.DIVE_MODE_CLOSED_CIRCUIT_REBREATHER,
    4 => DiveMode.DIVE_MODE_SEMI_CLOSED_REBREATHER,
    _ => null,
  };
}

/// Convert libdivecomputer gas usage to protobuf GasUsage.
GasUsage? _convertGasUsage(int dcValue) {
  return switch (dcValue) {
    0 => GasUsage.GAS_USAGE_NONE,
    1 => GasUsage.GAS_USAGE_OXYGEN,
    2 => GasUsage.GAS_USAGE_DILUENT,
    3 => GasUsage.GAS_USAGE_SIDEMOUNT,
    _ => null,
  };
}

/// Convert libdivecomputer tank volume type to protobuf TankVolumeType.
TankVolumeType? _convertTankVolumeType(int dcValue) {
  return switch (dcValue) {
    0 => TankVolumeType.TANK_VOLUME_TYPE_NONE,
    1 => TankVolumeType.TANK_VOLUME_TYPE_METRIC,
    2 => TankVolumeType.TANK_VOLUME_TYPE_IMPERIAL,
    _ => null,
  };
}

/// Convert libdivecomputer deco model type to protobuf DecoModelType.
DecoModelType? _convertDecoModelType(int dcValue) {
  return switch (dcValue) {
    0 => DecoModelType.DECO_MODEL_TYPE_NONE,
    1 => DecoModelType.DECO_MODEL_TYPE_BUHLMANN,
    2 => DecoModelType.DECO_MODEL_TYPE_VPM,
    3 => DecoModelType.DECO_MODEL_TYPE_RGBM,
    4 => DecoModelType.DECO_MODEL_TYPE_DCIEM,
    _ => null,
  };
}

/// Convert libdivecomputer deco stop type to protobuf DecoStopType.
DecoStopType? _convertDecoStopType(int dcValue) {
  return switch (dcValue) {
    0 => DecoStopType.DECO_STOP_TYPE_NDL,
    1 => DecoStopType.DECO_STOP_TYPE_SAFETY_STOP,
    2 => DecoStopType.DECO_STOP_TYPE_DECO_STOP,
    3 => DecoStopType.DECO_STOP_TYPE_DEEP_STOP,
    _ => null,
  };
}

/// Convert libdivecomputer sample event type to protobuf SampleEventType.
SampleEventType _convertSampleEventType(int dcValue) {
  return switch (dcValue) {
    0 => SampleEventType.SAMPLE_EVENT_TYPE_NONE,
    1 => SampleEventType.SAMPLE_EVENT_TYPE_DECO_STOP,
    2 => SampleEventType.SAMPLE_EVENT_TYPE_RBT,
    3 => SampleEventType.SAMPLE_EVENT_TYPE_ASCENT,
    4 => SampleEventType.SAMPLE_EVENT_TYPE_CEILING,
    5 => SampleEventType.SAMPLE_EVENT_TYPE_WORKLOAD,
    6 => SampleEventType.SAMPLE_EVENT_TYPE_TRANSMITTER,
    7 => SampleEventType.SAMPLE_EVENT_TYPE_VIOLATION,
    8 => SampleEventType.SAMPLE_EVENT_TYPE_BOOKMARK,
    9 => SampleEventType.SAMPLE_EVENT_TYPE_SURFACE,
    10 => SampleEventType.SAMPLE_EVENT_TYPE_SAFETY_STOP,
    11 => SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE,
    12 => SampleEventType.SAMPLE_EVENT_TYPE_SAFETY_STOP_VOLUNTARY,
    13 => SampleEventType.SAMPLE_EVENT_TYPE_SAFETY_STOP_MANDATORY,
    14 => SampleEventType.SAMPLE_EVENT_TYPE_DEEP_STOP,
    15 => SampleEventType.SAMPLE_EVENT_TYPE_CEILING_SAFETY_STOP,
    16 => SampleEventType.SAMPLE_EVENT_TYPE_FLOOR,
    17 => SampleEventType.SAMPLE_EVENT_TYPE_DIVE_TIME,
    18 => SampleEventType.SAMPLE_EVENT_TYPE_MAX_DEPTH,
    19 => SampleEventType.SAMPLE_EVENT_TYPE_OLF,
    20 => SampleEventType.SAMPLE_EVENT_TYPE_PO2,
    21 => SampleEventType.SAMPLE_EVENT_TYPE_AIR_TIME,
    22 => SampleEventType.SAMPLE_EVENT_TYPE_RGBM,
    23 => SampleEventType.SAMPLE_EVENT_TYPE_HEADING,
    24 => SampleEventType.SAMPLE_EVENT_TYPE_TISSUE_LEVEL,
    25 => SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE_2,
    _ => SampleEventType.SAMPLE_EVENT_TYPE_NONE,
  };
}
