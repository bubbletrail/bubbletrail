// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SyncStateCWProxy {
  SyncState lastSynced(DateTime? lastSynced);

  SyncState syncing(bool syncing);

  SyncState error(String? error);

  SyncState lastSyncSuccess(bool? lastSyncSuccess);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SyncState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SyncState(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncState call({
    DateTime? lastSynced,
    bool syncing,
    String? error,
    bool? lastSyncSuccess,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSyncState.copyWith(...)` or call `instanceOfSyncState.copyWith.fieldName(value)` for a single field.
class _$SyncStateCWProxyImpl implements _$SyncStateCWProxy {
  const _$SyncStateCWProxyImpl(this._value);

  final SyncState _value;

  @override
  SyncState lastSynced(DateTime? lastSynced) => call(lastSynced: lastSynced);

  @override
  SyncState syncing(bool syncing) => call(syncing: syncing);

  @override
  SyncState error(String? error) => call(error: error);

  @override
  SyncState lastSyncSuccess(bool? lastSyncSuccess) =>
      call(lastSyncSuccess: lastSyncSuccess);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SyncState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SyncState(...).copyWith(id: 12, name: "My name")
  /// ```
  SyncState call({
    Object? lastSynced = const $CopyWithPlaceholder(),
    Object? syncing = const $CopyWithPlaceholder(),
    Object? error = const $CopyWithPlaceholder(),
    Object? lastSyncSuccess = const $CopyWithPlaceholder(),
  }) {
    return SyncState(
      lastSynced: lastSynced == const $CopyWithPlaceholder()
          ? _value.lastSynced
          // ignore: cast_nullable_to_non_nullable
          : lastSynced as DateTime?,
      syncing: syncing == const $CopyWithPlaceholder() || syncing == null
          ? _value.syncing
          // ignore: cast_nullable_to_non_nullable
          : syncing as bool,
      error: error == const $CopyWithPlaceholder()
          ? _value.error
          // ignore: cast_nullable_to_non_nullable
          : error as String?,
      lastSyncSuccess: lastSyncSuccess == const $CopyWithPlaceholder()
          ? _value.lastSyncSuccess
          // ignore: cast_nullable_to_non_nullable
          : lastSyncSuccess as bool?,
    );
  }
}

extension $SyncStateCopyWith on SyncState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSyncState.copyWith(...)` or `instanceOfSyncState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SyncStateCWProxy get copyWith => _$SyncStateCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// SyncState(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  SyncState copyWithNull({
    bool lastSynced = false,
    bool error = false,
    bool lastSyncSuccess = false,
  }) {
    return SyncState(
      lastSynced: lastSynced == true ? null : this.lastSynced,
      syncing: syncing,
      error: error == true ? null : this.error,
      lastSyncSuccess: lastSyncSuccess == true ? null : this.lastSyncSuccess,
    );
  }
}
