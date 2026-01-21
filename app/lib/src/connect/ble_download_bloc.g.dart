// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ble_download_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$BleDownloadStateCWProxy {
  BleDownloadState connectedDevice(BluetoothDevice? connectedDevice);

  BleDownloadState connectionState(BluetoothConnectionState connectionState);

  BleDownloadState discoveredServices(List<BluetoothService> discoveredServices);

  BleDownloadState isDiscoveringServices(bool isDiscoveringServices);

  BleDownloadState isDownloading(bool isDownloading);

  BleDownloadState downloadProgress(DownloadProgress? downloadProgress);

  BleDownloadState downloadedDives(List<Dive> downloadedDives);

  BleDownloadState error(String? error);

  BleDownloadState lastLogDate(DateTime? lastLogDate);

  BleDownloadState autoStartDescriptor(ComputerDescriptor? autoStartDescriptor);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BleDownloadState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BleDownloadState(...).copyWith(id: 12, name: "My name")
  /// ```
  BleDownloadState call({
    BluetoothDevice? connectedDevice,
    BluetoothConnectionState connectionState,
    List<BluetoothService> discoveredServices,
    bool isDiscoveringServices,
    bool isDownloading,
    DownloadProgress? downloadProgress,
    List<Dive> downloadedDives,
    String? error,
    DateTime? lastLogDate,
    ComputerDescriptor? autoStartDescriptor,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfBleDownloadState.copyWith(...)` or call `instanceOfBleDownloadState.copyWith.fieldName(value)` for a single field.
class _$BleDownloadStateCWProxyImpl implements _$BleDownloadStateCWProxy {
  const _$BleDownloadStateCWProxyImpl(this._value);

  final BleDownloadState _value;

  @override
  BleDownloadState connectedDevice(BluetoothDevice? connectedDevice) => call(connectedDevice: connectedDevice);

  @override
  BleDownloadState connectionState(BluetoothConnectionState connectionState) => call(connectionState: connectionState);

  @override
  BleDownloadState discoveredServices(List<BluetoothService> discoveredServices) => call(discoveredServices: discoveredServices);

  @override
  BleDownloadState isDiscoveringServices(bool isDiscoveringServices) => call(isDiscoveringServices: isDiscoveringServices);

  @override
  BleDownloadState isDownloading(bool isDownloading) => call(isDownloading: isDownloading);

  @override
  BleDownloadState downloadProgress(DownloadProgress? downloadProgress) => call(downloadProgress: downloadProgress);

  @override
  BleDownloadState downloadedDives(List<Dive> downloadedDives) => call(downloadedDives: downloadedDives);

  @override
  BleDownloadState error(String? error) => call(error: error);

  @override
  BleDownloadState lastLogDate(DateTime? lastLogDate) => call(lastLogDate: lastLogDate);

  @override
  BleDownloadState autoStartDescriptor(ComputerDescriptor? autoStartDescriptor) => call(autoStartDescriptor: autoStartDescriptor);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `BleDownloadState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// BleDownloadState(...).copyWith(id: 12, name: "My name")
  /// ```
  BleDownloadState call({
    Object? connectedDevice = const $CopyWithPlaceholder(),
    Object? connectionState = const $CopyWithPlaceholder(),
    Object? discoveredServices = const $CopyWithPlaceholder(),
    Object? isDiscoveringServices = const $CopyWithPlaceholder(),
    Object? isDownloading = const $CopyWithPlaceholder(),
    Object? downloadProgress = const $CopyWithPlaceholder(),
    Object? downloadedDives = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? lastLogDate = const $CopyWithPlaceholder(),
    Object? autoStartDescriptor = const $CopyWithPlaceholder(),
  }) {
    return BleDownloadState(
      connectedDevice: connectedDevice == const $CopyWithPlaceholder()
          ? _value.connectedDevice
          // ignore: cast_nullable_to_non_nullable
          : connectedDevice as BluetoothDevice?,
      connectionState: connectionState == const $CopyWithPlaceholder() || connectionState == null
          ? _value.connectionState
          // ignore: cast_nullable_to_non_nullable
          : connectionState as BluetoothConnectionState,
      discoveredServices: discoveredServices == const $CopyWithPlaceholder() || discoveredServices == null
          ? _value.discoveredServices
          // ignore: cast_nullable_to_non_nullable
          : discoveredServices as List<BluetoothService>,
      isDiscoveringServices: isDiscoveringServices == const $CopyWithPlaceholder() || isDiscoveringServices == null
          ? _value.isDiscoveringServices
          // ignore: cast_nullable_to_non_nullable
          : isDiscoveringServices as bool,
      isDownloading: isDownloading == const $CopyWithPlaceholder() || isDownloading == null
          ? _value.isDownloading
          // ignore: cast_nullable_to_non_nullable
          : isDownloading as bool,
      downloadProgress: downloadProgress == const $CopyWithPlaceholder()
          ? _value.downloadProgress
          // ignore: cast_nullable_to_non_nullable
          : downloadProgress as DownloadProgress?,
      downloadedDives: downloadedDives == const $CopyWithPlaceholder() || downloadedDives == null
          ? _value.downloadedDives
          // ignore: cast_nullable_to_non_nullable
          : downloadedDives as List<Dive>,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      lastLogDate: lastLogDate == const $CopyWithPlaceholder()
          ? _value.lastLogDate
          // ignore: cast_nullable_to_non_nullable
          : lastLogDate as DateTime?,
      autoStartDescriptor: autoStartDescriptor == const $CopyWithPlaceholder()
          ? _value.autoStartDescriptor
          // ignore: cast_nullable_to_non_nullable
          : autoStartDescriptor as ComputerDescriptor?,
    );
  }
}

extension $BleDownloadStateCopyWith on BleDownloadState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfBleDownloadState.copyWith(...)` or `instanceOfBleDownloadState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$BleDownloadStateCWProxy get copyWith => _$BleDownloadStateCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// BleDownloadState(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  BleDownloadState copyWithNull({
    bool connectedDevice = false,
    bool downloadProgress = false,
    bool error = false,
    bool lastLogDate = false,
    bool autoStartDescriptor = false,
  }) {
    return BleDownloadState(
      connectedDevice: connectedDevice == true ? null : this.connectedDevice,
      connectionState: connectionState,
      discoveredServices: discoveredServices,
      isDiscoveringServices: isDiscoveringServices,
      isDownloading: isDownloading,
      downloadProgress: downloadProgress == true ? null : this.downloadProgress,
      downloadedDives: downloadedDives,
      error: error == true ? null : this.error,
      lastLogDate: lastLogDate == true ? null : this.lastLogDate,
      autoStartDescriptor: autoStartDescriptor == true ? null : this.autoStartDescriptor,
    );
  }
}
