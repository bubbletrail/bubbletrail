// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_scan_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BleScanStateCWProxy {
  BleScanState adapterState(BluetoothAdapterState adapterState);

  BleScanState supportedComputers(List<ComputerDescriptor> supportedComputers);

  BleScanState rememberedComputers(List<Computer> rememberedComputers);

  BleScanState scannedComputers(
    List<(ScanResult, List<ComputerDescriptor>)> scannedComputers,
  );

  BleScanState scannedOther(List<ScanResult> scannedOther);

  BleScanState isScanning(bool isScanning);

  BleScanState showAllDevices(bool showAllDevices);

  BleScanState error(String? error);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BleScanState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BleScanState(...).copyWith(id: 12, name: "My name")
  /// ```
  BleScanState call({
    BluetoothAdapterState adapterState,
    List<ComputerDescriptor> supportedComputers,
    List<Computer> rememberedComputers,
    List<(ScanResult, List<ComputerDescriptor>)> scannedComputers,
    List<ScanResult> scannedOther,
    bool isScanning,
    bool showAllDevices,
    String? error,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBleScanState.copyWith(...)` or call `instanceOfBleScanState.copyWith.fieldName(value)` for a single field.
class _$BleScanStateCWProxyImpl implements _$BleScanStateCWProxy {
  const _$BleScanStateCWProxyImpl(this._value);

  final BleScanState _value;

  @override
  BleScanState adapterState(BluetoothAdapterState adapterState) =>
      call(adapterState: adapterState);

  @override
  BleScanState supportedComputers(
    List<ComputerDescriptor> supportedComputers,
  ) => call(supportedComputers: supportedComputers);

  @override
  BleScanState rememberedComputers(List<Computer> rememberedComputers) =>
      call(rememberedComputers: rememberedComputers);

  @override
  BleScanState scannedComputers(
    List<(ScanResult, List<ComputerDescriptor>)> scannedComputers,
  ) => call(scannedComputers: scannedComputers);

  @override
  BleScanState scannedOther(List<ScanResult> scannedOther) =>
      call(scannedOther: scannedOther);

  @override
  BleScanState isScanning(bool isScanning) => call(isScanning: isScanning);

  @override
  BleScanState showAllDevices(bool showAllDevices) =>
      call(showAllDevices: showAllDevices);

  @override
  BleScanState error(String? error) => call(error: error);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BleScanState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BleScanState(...).copyWith(id: 12, name: "My name")
  /// ```
  BleScanState call({
    Object? adapterState = const $CopyWithPlaceholder(),
    Object? supportedComputers = const $CopyWithPlaceholder(),
    Object? rememberedComputers = const $CopyWithPlaceholder(),
    Object? scannedComputers = const $CopyWithPlaceholder(),
    Object? scannedOther = const $CopyWithPlaceholder(),
    Object? isScanning = const $CopyWithPlaceholder(),
    Object? showAllDevices = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
  }) {
    return BleScanState(
      adapterState:
          adapterState == const $CopyWithPlaceholder() || adapterState == null
          ? _value.adapterState
          // ignore: cast_nullable_to_non_nullable
          : adapterState as BluetoothAdapterState,
      supportedComputers:
          supportedComputers == const $CopyWithPlaceholder() ||
              supportedComputers == null
          ? _value.supportedComputers
          // ignore: cast_nullable_to_non_nullable
          : supportedComputers as List<ComputerDescriptor>,
      rememberedComputers:
          rememberedComputers == const $CopyWithPlaceholder() ||
              rememberedComputers == null
          ? _value.rememberedComputers
          // ignore: cast_nullable_to_non_nullable
          : rememberedComputers as List<Computer>,
      scannedComputers:
          scannedComputers == const $CopyWithPlaceholder() ||
              scannedComputers == null
          ? _value.scannedComputers
          // ignore: cast_nullable_to_non_nullable
          : scannedComputers as List<(ScanResult, List<ComputerDescriptor>)>,
      scannedOther:
          scannedOther == const $CopyWithPlaceholder() || scannedOther == null
          ? _value.scannedOther
          // ignore: cast_nullable_to_non_nullable
          : scannedOther as List<ScanResult>,
      isScanning:
          isScanning == const $CopyWithPlaceholder() || isScanning == null
          ? _value.isScanning
          // ignore: cast_nullable_to_non_nullable
          : isScanning as bool,
      showAllDevices:
          showAllDevices == const $CopyWithPlaceholder() ||
              showAllDevices == null
          ? _value.showAllDevices
          // ignore: cast_nullable_to_non_nullable
          : showAllDevices as bool,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
    );
  }
}

extension $BleScanStateCopyWith on BleScanState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBleScanState.copyWith(...)` or `instanceOfBleScanState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BleScanStateCWProxy get copyWith => _$BleScanStateCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// BleScanState(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  BleScanState copyWithNull({bool error = false}) {
    return BleScanState(
      adapterState: adapterState,
      supportedComputers: supportedComputers,
      rememberedComputers: rememberedComputers,
      scannedComputers: scannedComputers,
      scannedOther: scannedOther,
      isScanning: isScanning,
      showAllDevices: showAllDevices,
      error: error == true ? null : this.error,
    );
  }
}
