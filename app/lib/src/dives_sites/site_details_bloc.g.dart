// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_details_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SiteDetailsLoadedCWProxy {
  SiteDetailsLoaded site(Site site);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SiteDetailsLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SiteDetailsLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  SiteDetailsLoaded call({Site site});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSiteDetailsLoaded.copyWith(...)` or call `instanceOfSiteDetailsLoaded.copyWith.fieldName(value)` for a single field.
class _$SiteDetailsLoadedCWProxyImpl implements _$SiteDetailsLoadedCWProxy {
  const _$SiteDetailsLoadedCWProxyImpl(this._value);

  final SiteDetailsLoaded _value;

  @override
  SiteDetailsLoaded site(Site site) => call(site: site);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `SiteDetailsLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SiteDetailsLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  SiteDetailsLoaded call({Object? site = const $CopyWithPlaceholder()}) {
    return SiteDetailsLoaded(
      site == const $CopyWithPlaceholder() || site == null
          ? _value.site
          // ignore: cast_nullable_to_non_nullable
          : site as Site,
    );
  }
}

extension $SiteDetailsLoadedCopyWith on SiteDetailsLoaded {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSiteDetailsLoaded.copyWith(...)` or `instanceOfSiteDetailsLoaded.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SiteDetailsLoadedCWProxy get copyWith =>
      _$SiteDetailsLoadedCWProxyImpl(this);
}
