// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_list_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SiteListStateCWProxy {
  SiteListState showAsMap(bool showAsMap);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SiteListState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SiteListState(...).copyWith(id: 12, name: "My name")
  /// ```
  SiteListState call({bool showAsMap});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSiteListState.copyWith(...)` or call `instanceOfSiteListState.copyWith.fieldName(value)` for a single field.
class _$SiteListStateCWProxyImpl implements _$SiteListStateCWProxy {
  const _$SiteListStateCWProxyImpl(this._value);

  final SiteListState _value;

  @override
  SiteListState showAsMap(bool showAsMap) => call(showAsMap: showAsMap);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SiteListState(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SiteListState(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  SiteListState call({Object? showAsMap = const $CopyWithPlaceholder()}) {
    return SiteListState(
      showAsMap: showAsMap == const $CopyWithPlaceholder() || showAsMap == null
          ? _value.showAsMap
          // ignore: cast_nullable_to_non_nullable
          : showAsMap as bool,
    );
  }
}

extension $SiteListStateCopyWith on SiteListState {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSiteListState.copyWith(...)` or `instanceOfSiteListState.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SiteListStateCWProxy get copyWith => _$SiteListStateCWProxyImpl(this);
}
