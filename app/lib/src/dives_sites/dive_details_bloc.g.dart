// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dive_details_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DiveDetailsLoadedCWProxy {
  DiveDetailsLoaded dive(Dive dive);

  DiveDetailsLoaded site(Site? site);

  DiveDetailsLoaded nextDive(Dive? nextDive);

  DiveDetailsLoaded prevDive(Dive? prevDive);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DiveDetailsLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DiveDetailsLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  DiveDetailsLoaded call({Dive dive, Site? site, Dive? nextDive, Dive? prevDive});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDiveDetailsLoaded.copyWith(...)` or call `instanceOfDiveDetailsLoaded.copyWith.fieldName(value)` for a single field.
class _$DiveDetailsLoadedCWProxyImpl implements _$DiveDetailsLoadedCWProxy {
  const _$DiveDetailsLoadedCWProxyImpl(this._value);

  final DiveDetailsLoaded _value;

  @override
  DiveDetailsLoaded dive(Dive dive) => call(dive: dive);

  @override
  DiveDetailsLoaded site(Site? site) => call(site: site);

  @override
  DiveDetailsLoaded nextDive(Dive? nextDive) => call(nextDive: nextDive);

  @override
  DiveDetailsLoaded prevDive(Dive? prevDive) => call(prevDive: prevDive);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DiveDetailsLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DiveDetailsLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  DiveDetailsLoaded call({
    Object? dive = const $CopyWithPlaceholder(),
    Object? site = const $CopyWithPlaceholder(),
    Object? nextDive = const $CopyWithPlaceholder(),
    Object? prevDive = const $CopyWithPlaceholder(),
  }) {
    return DiveDetailsLoaded(
      dive == const $CopyWithPlaceholder() || dive == null
          ? _value.dive
          // ignore: cast_nullable_to_non_nullable
          : dive as Dive,
      site: site == const $CopyWithPlaceholder()
          ? _value.site
          // ignore: cast_nullable_to_non_nullable
          : site as Site?,
      nextDive: nextDive == const $CopyWithPlaceholder()
          ? _value.nextDive
          // ignore: cast_nullable_to_non_nullable
          : nextDive as Dive?,
      prevDive: prevDive == const $CopyWithPlaceholder()
          ? _value.prevDive
          // ignore: cast_nullable_to_non_nullable
          : prevDive as Dive?,
    );
  }
}

extension $DiveDetailsLoadedCopyWith on DiveDetailsLoaded {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDiveDetailsLoaded.copyWith(...)` or `instanceOfDiveDetailsLoaded.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DiveDetailsLoadedCWProxy get copyWith => _$DiveDetailsLoadedCWProxyImpl(this);
}
