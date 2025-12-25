// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'computerdive.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SampleEventFlags _$SampleEventFlagsFromJson(Map<String, dynamic> json) =>
    SampleEventFlags((json['value'] as num).toInt());

Map<String, dynamic> _$SampleEventFlagsToJson(SampleEventFlags instance) =>
    <String, dynamic>{'value': instance.value};

Salinity _$SalinityFromJson(Map<String, dynamic> json) => Salinity(
  type: $enumDecode(_$WaterTypeEnumMap, json['type']),
  density: (json['density'] as num).toDouble(),
);

Map<String, dynamic> _$SalinityToJson(Salinity instance) => <String, dynamic>{
  'type': _$WaterTypeEnumMap[instance.type]!,
  'density': instance.density,
};

const _$WaterTypeEnumMap = {WaterType.fresh: 'fresh', WaterType.salt: 'salt'};

GasMix _$GasMixFromJson(Map<String, dynamic> json) => GasMix(
  oxygen: (json['oxygen'] as num).toDouble(),
  helium: (json['helium'] as num).toDouble(),
  nitrogen: (json['nitrogen'] as num).toDouble(),
  usage: $enumDecodeNullable(_$GasUsageEnumMap, json['usage']) ?? GasUsage.none,
);

Map<String, dynamic> _$GasMixToJson(GasMix instance) => <String, dynamic>{
  'oxygen': instance.oxygen,
  'helium': instance.helium,
  'nitrogen': instance.nitrogen,
  'usage': _$GasUsageEnumMap[instance.usage]!,
};

const _$GasUsageEnumMap = {
  GasUsage.none: 'none',
  GasUsage.oxygen: 'oxygen',
  GasUsage.diluent: 'diluent',
  GasUsage.sidemount: 'sidemount',
};

Tank _$TankFromJson(Map<String, dynamic> json) => Tank(
  gasMixIndex: (json['gasMixIndex'] as num?)?.toInt(),
  volumeType:
      $enumDecodeNullable(_$TankVolumeTypeEnumMap, json['volumeType']) ??
      TankVolumeType.none,
  volume: (json['volume'] as num?)?.toDouble() ?? 0,
  workPressure: (json['workPressure'] as num?)?.toDouble(),
  beginPressure: (json['beginPressure'] as num?)?.toDouble(),
  endPressure: (json['endPressure'] as num?)?.toDouble(),
  usage: $enumDecodeNullable(_$GasUsageEnumMap, json['usage']) ?? GasUsage.none,
);

Map<String, dynamic> _$TankToJson(Tank instance) => <String, dynamic>{
  'gasMixIndex': ?instance.gasMixIndex,
  'volumeType': _$TankVolumeTypeEnumMap[instance.volumeType]!,
  'volume': instance.volume,
  'workPressure': ?instance.workPressure,
  'beginPressure': ?instance.beginPressure,
  'endPressure': ?instance.endPressure,
  'usage': _$GasUsageEnumMap[instance.usage]!,
};

const _$TankVolumeTypeEnumMap = {
  TankVolumeType.none: 'none',
  TankVolumeType.metric: 'metric',
  TankVolumeType.imperial: 'imperial',
};

DecoModel _$DecoModelFromJson(Map<String, dynamic> json) => DecoModel(
  type: $enumDecode(_$DecoModelTypeEnumMap, json['type']),
  conservatism: (json['conservatism'] as num?)?.toInt() ?? 0,
  gfLow: (json['gfLow'] as num?)?.toInt(),
  gfHigh: (json['gfHigh'] as num?)?.toInt(),
);

Map<String, dynamic> _$DecoModelToJson(DecoModel instance) => <String, dynamic>{
  'type': _$DecoModelTypeEnumMap[instance.type]!,
  'conservatism': instance.conservatism,
  'gfLow': ?instance.gfLow,
  'gfHigh': ?instance.gfHigh,
};

const _$DecoModelTypeEnumMap = {
  DecoModelType.none: 'none',
  DecoModelType.buhlmann: 'buhlmann',
  DecoModelType.vpm: 'vpm',
  DecoModelType.rgbm: 'rgbm',
  DecoModelType.dciem: 'dciem',
};

Location _$LocationFromJson(Map<String, dynamic> json) => Location(
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  altitude: (json['altitude'] as num?)?.toDouble(),
);

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'altitude': ?instance.altitude,
};

TankPressure _$TankPressureFromJson(Map<String, dynamic> json) => TankPressure(
  tankIndex: (json['tankIndex'] as num).toInt(),
  pressure: (json['pressure'] as num).toDouble(),
);

Map<String, dynamic> _$TankPressureToJson(TankPressure instance) =>
    <String, dynamic>{
      'tankIndex': instance.tankIndex,
      'pressure': instance.pressure,
    };

Ppo2Reading _$Ppo2ReadingFromJson(Map<String, dynamic> json) => Ppo2Reading(
  sensorIndex: (json['sensorIndex'] as num).toInt(),
  value: (json['value'] as num).toDouble(),
);

Map<String, dynamic> _$Ppo2ReadingToJson(Ppo2Reading instance) =>
    <String, dynamic>{
      'sensorIndex': instance.sensorIndex,
      'value': instance.value,
    };

DecoStatus _$DecoStatusFromJson(Map<String, dynamic> json) => DecoStatus(
  type: $enumDecode(_$DecoStopTypeEnumMap, json['type']),
  time: (json['time'] as num).toInt(),
  depth: (json['depth'] as num).toDouble(),
  tts: (json['tts'] as num).toInt(),
);

Map<String, dynamic> _$DecoStatusToJson(DecoStatus instance) =>
    <String, dynamic>{
      'type': _$DecoStopTypeEnumMap[instance.type]!,
      'time': instance.time,
      'depth': instance.depth,
      'tts': instance.tts,
    };

const _$DecoStopTypeEnumMap = {
  DecoStopType.ndl: 'ndl',
  DecoStopType.safetyStop: 'safetyStop',
  DecoStopType.decoStop: 'decoStop',
  DecoStopType.deepStop: 'deepStop',
};

SampleEvent _$SampleEventFromJson(Map<String, dynamic> json) => SampleEvent(
  type: $enumDecode(_$SampleEventTypeEnumMap, json['type']),
  time: (json['time'] as num).toInt(),
  flags: SampleEventFlags.fromJson(json['flags'] as Map<String, dynamic>),
  value: (json['value'] as num).toInt(),
);

Map<String, dynamic> _$SampleEventToJson(SampleEvent instance) =>
    <String, dynamic>{
      'type': _$SampleEventTypeEnumMap[instance.type]!,
      'time': instance.time,
      'flags': instance.flags,
      'value': instance.value,
    };

const _$SampleEventTypeEnumMap = {
  SampleEventType.none: 'none',
  SampleEventType.decoStop: 'decoStop',
  SampleEventType.rbt: 'rbt',
  SampleEventType.ascent: 'ascent',
  SampleEventType.ceiling: 'ceiling',
  SampleEventType.workload: 'workload',
  SampleEventType.transmitter: 'transmitter',
  SampleEventType.violation: 'violation',
  SampleEventType.bookmark: 'bookmark',
  SampleEventType.surface: 'surface',
  SampleEventType.safetyStop: 'safetyStop',
  SampleEventType.gasChange: 'gasChange',
  SampleEventType.safetyStopVoluntary: 'safetyStopVoluntary',
  SampleEventType.safetyStopMandatory: 'safetyStopMandatory',
  SampleEventType.deepStop: 'deepStop',
  SampleEventType.ceilingSafetyStop: 'ceilingSafetyStop',
  SampleEventType.floor: 'floor',
  SampleEventType.diveTime: 'diveTime',
  SampleEventType.maxDepth: 'maxDepth',
  SampleEventType.olf: 'olf',
  SampleEventType.po2: 'po2',
  SampleEventType.airTime: 'airTime',
  SampleEventType.rgbm: 'rgbm',
  SampleEventType.heading: 'heading',
  SampleEventType.tissueLevel: 'tissueLevel',
  SampleEventType.gasChange2: 'gasChange2',
};

VendorData _$VendorDataFromJson(Map<String, dynamic> json) => VendorData(
  type: (json['type'] as num).toInt(),
  data: json['data'] as String,
);

Map<String, dynamic> _$VendorDataToJson(VendorData instance) =>
    <String, dynamic>{'type': instance.type, 'data': instance.data};

ComputerSample _$ComputerSampleFromJson(Map<String, dynamic> json) =>
    ComputerSample(
      time: (json['time'] as num).toDouble(),
      depth: (json['depth'] as num?)?.toDouble(),
      temperature: (json['temperature'] as num?)?.toDouble(),
      pressures: (json['pressures'] as List<dynamic>?)
          ?.map((e) => TankPressure.fromJson(e as Map<String, dynamic>))
          .toList(),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => SampleEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      rbt: (json['rbt'] as num?)?.toInt(),
      heartbeat: (json['heartbeat'] as num?)?.toInt(),
      bearing: (json['bearing'] as num?)?.toInt(),
      setpoint: (json['setpoint'] as num?)?.toDouble(),
      ppo2: (json['ppo2'] as List<dynamic>?)
          ?.map((e) => Ppo2Reading.fromJson(e as Map<String, dynamic>))
          .toList(),
      cns: (json['cns'] as num?)?.toDouble(),
      deco: json['deco'] == null
          ? null
          : DecoStatus.fromJson(json['deco'] as Map<String, dynamic>),
      gasMixIndex: (json['gasMixIndex'] as num?)?.toInt(),
      vendorData: (json['vendorData'] as List<dynamic>?)
          ?.map((e) => VendorData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ComputerSampleToJson(ComputerSample instance) =>
    <String, dynamic>{
      'time': instance.time,
      'depth': ?instance.depth,
      'temperature': ?instance.temperature,
      'pressures': ?instance.pressures,
      'events': ?instance.events,
      'rbt': ?instance.rbt,
      'heartbeat': ?instance.heartbeat,
      'bearing': ?instance.bearing,
      'setpoint': ?instance.setpoint,
      'ppo2': ?instance.ppo2,
      'cns': ?instance.cns,
      'deco': ?instance.deco,
      'gasMixIndex': ?instance.gasMixIndex,
      'vendorData': ?instance.vendorData,
    };

ComputerDive _$ComputerDiveFromJson(Map<String, dynamic> json) => ComputerDive(
  dateTime: json['dateTime'] == null
      ? null
      : DateTime.parse(json['dateTime'] as String),
  diveTime: (json['diveTime'] as num?)?.toInt(),
  number: (json['number'] as num?)?.toInt(),
  maxDepth: (json['maxDepth'] as num?)?.toDouble(),
  avgDepth: (json['avgDepth'] as num?)?.toDouble(),
  surfaceTemperature: (json['surfaceTemperature'] as num?)?.toDouble(),
  minTemperature: (json['minTemperature'] as num?)?.toDouble(),
  maxTemperature: (json['maxTemperature'] as num?)?.toDouble(),
  salinity: json['salinity'] == null
      ? null
      : Salinity.fromJson(json['salinity'] as Map<String, dynamic>),
  atmosphericPressure: (json['atmosphericPressure'] as num?)?.toDouble(),
  diveMode: $enumDecodeNullable(_$DiveModeEnumMap, json['diveMode']),
  decoModel: json['decoModel'] == null
      ? null
      : DecoModel.fromJson(json['decoModel'] as Map<String, dynamic>),
  location: json['location'] == null
      ? null
      : Location.fromJson(json['location'] as Map<String, dynamic>),
  gasMixes:
      (json['gasMixes'] as List<dynamic>?)
          ?.map((e) => GasMix.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  tanks:
      (json['tanks'] as List<dynamic>?)
          ?.map((e) => Tank.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  samples:
      (json['samples'] as List<dynamic>?)
          ?.map((e) => ComputerSample.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  fingerprint: json['fingerprint'] as String?,
);

Map<String, dynamic> _$ComputerDiveToJson(ComputerDive instance) =>
    <String, dynamic>{
      'dateTime': ?instance.dateTime?.toIso8601String(),
      'diveTime': ?instance.diveTime,
      'number': ?instance.number,
      'maxDepth': ?instance.maxDepth,
      'avgDepth': ?instance.avgDepth,
      'surfaceTemperature': ?instance.surfaceTemperature,
      'minTemperature': ?instance.minTemperature,
      'maxTemperature': ?instance.maxTemperature,
      'salinity': ?instance.salinity,
      'atmosphericPressure': ?instance.atmosphericPressure,
      'diveMode': ?_$DiveModeEnumMap[instance.diveMode],
      'decoModel': ?instance.decoModel,
      'location': ?instance.location,
      'gasMixes': instance.gasMixes,
      'tanks': instance.tanks,
      'samples': instance.samples,
      'fingerprint': ?instance.fingerprint,
    };

const _$DiveModeEnumMap = {
  DiveMode.freedive: 'freedive',
  DiveMode.gauge: 'gauge',
  DiveMode.openCircuit: 'openCircuit',
  DiveMode.closedCircuitRebreather: 'closedCircuitRebreather',
  DiveMode.semiClosedRebreather: 'semiClosedRebreather',
};
