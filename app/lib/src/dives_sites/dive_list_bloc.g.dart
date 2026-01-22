// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dive_list_bloc.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$DiveListLoadedCWProxy {
  DiveListLoaded dives(List<Dive> dives);

  DiveListLoaded sites(List<Site> sites);

  DiveListLoaded tags(Set<String> tags);

  DiveListLoaded buddies(Set<String> buddies);

  DiveListLoaded selectedDive(Dive? selectedDive);

  DiveListLoaded selectedDiveSite(Site? selectedDiveSite);

  DiveListLoaded selectedSite(Site? selectedSite);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DiveListLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DiveListLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  DiveListLoaded call({
    List<Dive> dives,
    List<Site> sites,
    Set<String> tags,
    Set<String> buddies,
    Dive? selectedDive,
    Site? selectedDiveSite,
    Site? selectedSite,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfDiveListLoaded.copyWith(...)` or call `instanceOfDiveListLoaded.copyWith.fieldName(value)` for a single field.
class _$DiveListLoadedCWProxyImpl implements _$DiveListLoadedCWProxy {
  const _$DiveListLoadedCWProxyImpl(this._value);

  final DiveListLoaded _value;

  @override
  DiveListLoaded dives(List<Dive> dives) => call(dives: dives);

  @override
  DiveListLoaded sites(List<Site> sites) => call(sites: sites);

  @override
  DiveListLoaded tags(Set<String> tags) => call(tags: tags);

  @override
  DiveListLoaded buddies(Set<String> buddies) => call(buddies: buddies);

  @override
  DiveListLoaded selectedDive(Dive? selectedDive) =>
      call(selectedDive: selectedDive);

  @override
  DiveListLoaded selectedDiveSite(Site? selectedDiveSite) =>
      call(selectedDiveSite: selectedDiveSite);

  @override
  DiveListLoaded selectedSite(Site? selectedSite) =>
      call(selectedSite: selectedSite);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `DiveListLoaded(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// DiveListLoaded(...).copyWith(id: 12, name: "My name")
  /// ```
  DiveListLoaded call({
    Object? dives = const $CopyWithPlaceholder(),
    Object? sites = const $CopyWithPlaceholder(),
    Object? tags = const $CopyWithPlaceholder(),
    Object? buddies = const $CopyWithPlaceholder(),
    Object? selectedDive = const $CopyWithPlaceholder(),
    Object? selectedDiveSite = const $CopyWithPlaceholder(),
    Object? selectedSite = const $CopyWithPlaceholder(),
  }) {
    return DiveListLoaded(
      dives == const $CopyWithPlaceholder() || dives == null
          ? _value.dives
          // ignore: cast_nullable_to_non_nullable
          : dives as List<Dive>,
      sites == const $CopyWithPlaceholder() || sites == null
          ? _value.sites
          // ignore: cast_nullable_to_non_nullable
          : sites as List<Site>,
      tags == const $CopyWithPlaceholder() || tags == null
          ? _value.tags
          // ignore: cast_nullable_to_non_nullable
          : tags as Set<String>,
      buddies == const $CopyWithPlaceholder() || buddies == null
          ? _value.buddies
          // ignore: cast_nullable_to_non_nullable
          : buddies as Set<String>,
      selectedDive: selectedDive == const $CopyWithPlaceholder()
          ? _value.selectedDive
          // ignore: cast_nullable_to_non_nullable
          : selectedDive as Dive?,
      selectedDiveSite: selectedDiveSite == const $CopyWithPlaceholder()
          ? _value.selectedDiveSite
          // ignore: cast_nullable_to_non_nullable
          : selectedDiveSite as Site?,
      selectedSite: selectedSite == const $CopyWithPlaceholder()
          ? _value.selectedSite
          // ignore: cast_nullable_to_non_nullable
          : selectedSite as Site?,
    );
  }
}

extension $DiveListLoadedCopyWith on DiveListLoaded {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfDiveListLoaded.copyWith(...)` or `instanceOfDiveListLoaded.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$DiveListLoadedCWProxy get copyWith => _$DiveListLoadedCWProxyImpl(this);

  /// Returns a copy of the object with the selected fields set to `null`.
  /// A flag set to `false` leaves the field unchanged. Prefer `copyWith(field: null)` or `copyWith.fieldName(null)` for single-field updates.
  ///
  /// Example:
  /// ```dart
  /// DiveListLoaded(...).copyWithNull(firstField: true, secondField: true)
  /// ```
  DiveListLoaded copyWithNull({
    bool selectedDive = false,
    bool selectedDiveSite = false,
    bool selectedSite = false,
  }) {
    return DiveListLoaded(
      dives,
      sites,
      tags,
      buddies,
      selectedDive: selectedDive == true ? null : this.selectedDive,
      selectedDiveSite: selectedDiveSite == true ? null : this.selectedDiveSite,
      selectedSite: selectedSite == true ? null : this.selectedSite,
    );
  }
}
