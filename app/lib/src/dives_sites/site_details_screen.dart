import 'package:btcountries/btcountries.dart';
import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../app_routes.dart';
import '../common/common.dart';
import 'dive_list_bloc.dart';
import 'dive_table.dart';
import 'site_details_bloc.dart';
import 'site_details_editor.dart';
import 'site_map.dart';
import 'site_position_editor.dart';

class SiteDetailsScreen extends StatelessWidget {
  const SiteDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final diveListState = context.select<DiveListBloc, DiveListState>((b) => b.state);
    if (diveListState is! DiveListLoaded) {
      // Can't happen
      return Placeholder();
    }

    return BlocConsumer<SiteDetailsBloc, SiteDetailsState>(
      listener: (context, state) {
        if (state is SiteDetailsClosed) {
          // Pop when the bloc considers us done
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is! SiteDetailsLoaded) {
          // Can't happen
          return Placeholder();
        }
        final site = state.site;
        final dives = diveListState.dives.where((s) => s.siteId == site.id).toList();
        return ScreenScaffold(
          title: Text(site.name.isNotEmpty ? site.name : 'New dive site'),
          actions: [_popupMenuActions(context, site)],
          body: SingleChildScrollView(
            child: Padding(
              padding: const .all(8.0),
              child: Wrap(
                alignment: .start,
                crossAxisAlignment: .start,
                spacing: 8,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: .start,
                    spacing: 8,
                    children: [
                      _MapCard(site: site),
                      _tagsSection(context, site, diveListState),
                    ],
                  ),
                  _detailsCard(context, site),
                  _notesCard(context, site),
                  if (dives.isNotEmpty)
                    AspectRatio(
                      aspectRatio: 2,
                      child: DiveTable(dives: dives, sitesByUuid: diveListState.sitesByUuid, showSiteColumn: false),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Dispatches a save of the current site with [update] applied.
  void _save(BuildContext context, Site site, void Function(Site) update) {
    context.read<SiteDetailsBloc>().add(SiteDetailsEvent.save(site.rebuild(update)));
  }

  Widget _detailsCard(BuildContext context, Site site) {
    final rows = <Widget>[
      ColumnRow(
        label: 'Name',
        child: Text(site.name.isNotEmpty ? site.name : 'Not set', style: site.name.isEmpty ? TextStyle(color: Theme.of(context).hintColor) : null),
      ),
      if (site.country.isNotEmpty) ColumnRow(label: 'Country', child: Text(countryDisplayName(site.country))),
      if (site.location.isNotEmpty) ColumnRow(label: 'Location', child: Text(site.location)),
      if (site.bodyOfWater.isNotEmpty) ColumnRow(label: 'Body of Water', child: Text(site.bodyOfWater)),
      if (site.difficulty.isNotEmpty) ColumnRow(label: 'Difficulty', child: Text(site.difficulty)),
    ];
    return Card(
      child: InkWell(
        onTap: () => _editDetails(context, site),
        borderRadius: .circular(12),
        child: Padding(
          padding: const .all(16.0),
          child: DataCardColumn(children: rows),
        ),
      ),
    );
  }

  Future<void> _editDetails(BuildContext context, Site site) async {
    final result = await showSiteDetailsEditor(
      context: context,
      initial: SiteDetails(name: site.name, country: site.country, location: site.location, bodyOfWater: site.bodyOfWater, difficulty: site.difficulty),
    );
    if (result == null || !context.mounted) return;
    if (result.name == site.name &&
        result.country == site.country &&
        result.location == site.location &&
        result.bodyOfWater == site.bodyOfWater &&
        result.difficulty == site.difficulty) {
      return;
    }

    _save(context, site, (s) {
      s.name = result.name;
      s.country = result.country;
      s.location = result.location;
      s.bodyOfWater = result.bodyOfWater;
      s.difficulty = result.difficulty;
    });
  }

  Widget _tagsSection(BuildContext context, Site site, DiveListLoaded listState) {
    final child = site.tags.isEmpty
        ? Chip(avatar: const Icon(Icons.add, size: 18), label: const Text('Add tags'), visualDensity: .compact, materialTapTargetSize: .shrinkWrap)
        : TagsList(tags: site.tags, prefix: '#');
    return InkWell(onTap: () => _editTags(context, site, listState), borderRadius: .circular(8), child: child);
  }

  Future<void> _editTags(BuildContext context, Site site, DiveListLoaded listState) async {
    final result = await showTagsEditor(context: context, selectedTags: site.tags, availableTags: listState.tags);
    if (result == null || !context.mounted) return;
    if (SetEquality<String>().equals(result.toSet(), site.tags.toSet())) return;

    _save(context, site, (s) {
      s.tags.clear();
      s.tags.addAll(result);
    });
  }

  Widget _notesCard(BuildContext context, Site site) {
    final hasNotes = site.notes.isNotEmpty;
    return ConstrainedBox(
      constraints: .loose(.fromWidth(600)),
      child: Card(
        child: InkWell(
          onTap: () => _editNotes(context, site),
          borderRadius: .circular(12),
          child: Padding(
            padding: const .all(16.0),
            child: hasNotes
                ? Text(site.notes)
                : Row(
                    spacing: 8,
                    children: [
                      Icon(Icons.notes_outlined, size: 18, color: Theme.of(context).hintColor),
                      Text('Add notes', style: TextStyle(color: Theme.of(context).hintColor)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _editNotes(BuildContext context, Site site) async {
    final result = await showTextEditor(context: context, title: 'Notes', initialValue: site.notes, maxLines: 6, textCapitalization: .sentences);
    if (result == null || !context.mounted || result == site.notes) return;

    _save(context, site, (s) => s.notes = result);
  }

  PopupMenuButton<String> _popupMenuActions(BuildContext context, Site site) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          final confirmed = await showConfirmationDialog(
            context: context,
            title: 'Delete site',
            message: 'Are you sure you want to delete the site ${site.name}? Dives using this site will be left without site. This cannot be undone.',
            confirmText: 'Delete',
            isDestructive: true,
          );
          if (confirmed && context.mounted) {
            context.read<SiteDetailsBloc>().add(SiteDetailsEvent.deleteAndClose(site.id));
          }
        }
      },
      itemBuilder: (context) => [const PopupMenuItem(value: 'delete', child: Text('Delete site'))],
    );
  }
}

// A tappable map card that opens the position editor. Shows an "add location"
// affordance when the site has no position yet.
class _MapCard extends StatelessWidget {
  final Site site;

  const _MapCard({required this.site});

  Future<void> _editPosition(BuildContext context) async {
    final result = await showSitePositionEditor(context: context, position: site.hasPosition() ? site.position : null);
    if (result.cancelled || !context.mounted) return;

    context.read<SiteDetailsBloc>().add(
      SiteDetailsEvent.save(
        site.rebuild((s) {
          if (result.value != null) {
            s.position = result.value!;
          } else {
            s.clearPosition();
          }
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!site.hasPosition()) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: () => _editPosition(context),
          borderRadius: .circular(12),
          child: Container(
            height: 300,
            alignment: .center,
            child: Row(
              mainAxisSize: .min,
              spacing: 8,
              children: [
                Icon(Icons.add_location_alt_outlined, size: 18, color: Theme.of(context).hintColor),
                Text('Add location', style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      clipBehavior: .antiAlias,
      child: SizedBox(
        height: 300,
        child: Stack(
          children: [
            IgnorePointer(child: SiteMap(sitePosition: LatLng(site.position.latitude, site.position.longitude))),
            Positioned.fill(
              child: Material(
                type: .transparency,
                child: InkWell(onTap: () => _editPosition(context)),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filled(
                icon: const Icon(Icons.fullscreen),
                onPressed: () => context.pushNamed(AppRouteName.sitesDetailsMap, pathParameters: {'siteID': site.id}),
                tooltip: 'View fullscreen',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
