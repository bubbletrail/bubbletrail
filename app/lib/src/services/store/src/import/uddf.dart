import 'dart:convert';

import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../ext/ext.dart';
import 'container.dart';

const double _kelvinOffset = 273.15;
const double _barToPascal = 1e5;
const double _cubicMeterToLiter = 1000.0;
const double _literToCubicMeter = 0.001;

double? _kelvinToCelsius(double? k) => k != null ? k - _kelvinOffset : null;
double? _pascalToBarConvert(double? pa) => pa != null && pa != 0 ? pa / _barToPascal : null;
String _formatTemperature(double celsius) => ((celsius * 100).round() / 100 + _kelvinOffset).toStringAsFixed(2);
// Round to 0.01 bar (1 kPa) and return whole pascals.
int _roundPressureToPascals(double bar) => (bar * 100).round() * 1000;
double? _litersToCubicMeters(double? liters) => liters != null ? liters * _literToCubicMeter : null;

// Extract hashtags from the last line of notes and return (cleanedNotes, tags).
// Tags are expected on the last line in #hashtag format.
({String? notes, List<String> tags}) _extractTagsFromNotes(String? notes) {
  if (notes == null || notes.isEmpty) {
    return (notes: null, tags: []);
  }

  final lines = notes.split('\n');
  if (lines.isEmpty) {
    return (notes: null, tags: []);
  }

  final lastLine = lines.last;
  final tagPattern = RegExp(r'#(\w+)');
  final matches = tagPattern.allMatches(lastLine);

  if (matches.isEmpty) {
    return (notes: notes, tags: []);
  }

  // Check if the last line is primarily hashtags (allow spaces between them)
  final withoutTags = lastLine.replaceAll(tagPattern, '').trim();
  if (withoutTags.isNotEmpty) {
    // Last line has non-tag content, don't extract
    return (notes: notes, tags: []);
  }

  // Extract tags and remove the last line from notes
  final tags = matches.map((m) => m.group(1)!).toList();
  final cleanedLines = lines.sublist(0, lines.length - 1);

  // Trim trailing empty lines
  while (cleanedLines.isNotEmpty && cleanedLines.last.trim().isEmpty) {
    cleanedLines.removeLast();
  }

  final cleanedNotes = cleanedLines.isEmpty ? null : cleanedLines.join('\n');
  return (notes: cleanedNotes, tags: tags);
}

// Convert tank volume to liters.
// UDDF spec says m³ (SI), but some programs (e.g., Subsurface) export in liters.
// Heuristic: if value < 1, assume m³ and convert; otherwise assume liters.
double? _tankVolumeToLiters(double? vol) {
  if (vol == null) return null;
  if (vol < 1) {
    return vol * _cubicMeterToLiter;
  }
  return vol;
}

// Helper class for gas mix definitions
class _GasMix {
  final String id;
  final String name;
  final double oxygen;
  final double helium;

  _GasMix({required this.id, required this.name, required this.oxygen, required this.helium});
}

// Helper class for buddy info
class _Buddy {
  final String id;
  final String firstName;
  final String lastName;

  _Buddy({required this.id, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName'.trim();
}

extension UddfXml on Container {
  // Parse UDDF XML and return an Ssrf container with dives and sites.
  static Container fromXml(XmlElement elem) {
    final ownExport = _getElementText(elem.getElement('generator'), 'name') == 'Bubbletrail';
    final tanks = <String, XmlElement>{
      for (final tank in elem.getElement('diver')?.findAllElements('tank') ?? <XmlElement>[])
        if (tank.getAttribute('id') case final String id) id: tank,
    };
    // Parse gas definitions (referenced by dives)
    final gasMixes = <String, _GasMix>{};
    final gasDefs = elem.getElement('gasdefinitions');
    if (gasDefs != null) {
      for (final mix in gasDefs.findElements('mix')) {
        final id = mix.getAttribute('id');
        if (id != null) {
          gasMixes[id] = _GasMix(
            id: id,
            name: _getElementText(mix, 'name') ?? '',
            oxygen: double.tryParse(_getElementText(mix, 'o2') ?? '') ?? 0.21,
            helium: double.tryParse(_getElementText(mix, 'he') ?? '') ?? 0.0,
          );
        }
      }
    }

    // Parse buddies (referenced by dives)
    final buddies = <String, _Buddy>{};
    final diverElem = elem.getElement('diver');
    if (diverElem != null) {
      for (final buddy in diverElem.findElements('buddy')) {
        final id = buddy.getAttribute('id');
        if (id != null) {
          final personal = buddy.getElement('personal');
          buddies[id] = _Buddy(id: id, firstName: _getElementText(personal, 'firstname') ?? '', lastName: _getElementText(personal, 'lastname') ?? '');
        }
      }
    }

    // Parse sites
    final sites = <Site>[];
    final sitesById = <String, Site>{};
    final divesiteElem = elem.getElement('divesite');
    if (divesiteElem != null) {
      for (final siteElem in divesiteElem.findElements('site')) {
        final site = _UddfSite.fromXml(siteElem, ownExport);
        sites.add(site);
        sitesById[siteElem.getAttribute('id') ?? site.id] = site;
      }
    }

    // Parse dives
    final dives = <Dive>[];
    final profileData = elem.getElement('profiledata');
    if (profileData != null) {
      for (final repGroup in profileData.findElements('repetitiongroup')) {
        for (final diveElem in repGroup.findElements('dive')) {
          final dive = _UddfDive.fromXml(diveElem, gasMixes, buddies, sitesById, tanks, ownExport);
          dives.add(dive);
        }
      }
    }

    return Container(dives: dives, sites: sites, preserveDiveSummary: true);
  }

  // Serialise the container to a UDDF 3.2.1 document string.
  //
  // This is the inverse of [fromXml]: all data with a UDDF representation
  // survives an export followed by a re-import. Data without one (dive
  // computer model/serial, cylinder descriptions, SAC/OTU/CNS, etc.) is
  // left out. The [version], when given, is recorded as the generating
  // application's version.
  String toUddfString({String? version}) {
    // Share gas definitions across dives, giving same-mix tanks within a dive
    // distinct references so a switch identifies the cylinder.
    final usedIds = <String>{};
    final buddies = <String, String>{};
    for (final dive in dives) {
      for (final name in dive.buddies) {
        final trimmed = name.trim();
        if (trimmed.isNotEmpty) buddies.putIfAbsent(trimmed, () => _namedId('buddy', trimmed, usedIds));
      }
    }
    final mixes = <String, (String, double, double)>{};
    final sharedMixIds = <(double, double, int), String>{};
    final sharedTankIds = <String, String>{};
    final tankDefinitions = <String, Cylinder>{};
    final savedCylinders = <String, Cylinder>{
      for (final dive in dives)
        for (final cylinder in dive.cylinders)
          if (cylinder.hasCylinder() && _cylinderId(cylinder).isNotEmpty) _cylinderId(cylinder): cylinder.cylinder,
    };
    final tankIdsByDive = <String, List<String>>{};
    final mixIdsByDive = <String, Map<int, String>>{};
    for (final dive in dives) {
      final tankOccurrences = <String, int>{};
      final mixOccurrences = <(double, double), int>{};
      final tankIds = tankIdsByDive[dive.id] = [];
      final mixIds = mixIdsByDive[dive.id] = {};
      for (final (index, cyl) in dive.cylinders.indexed) {
        final cylinderId = _cylinderId(cyl);
        final cylinder = savedCylinders[cylinderId] ?? cyl.cylinder;
        final tankKey = cylinderId.isEmpty
            ? '${_xmlId('dive-tank', dive.id)}-$index'
            : '${_xmlId('tank', cylinderId)}-${tankOccurrences.update(cylinderId, (count) => count + 1, ifAbsent: () => 0)}';
        final tankId = sharedTankIds.putIfAbsent(tankKey, () => _namedId('tank', cylinder.description, usedIds));
        tankIds.add(tankId);
        tankDefinitions.putIfAbsent(tankId, () => cylinder);
        if (!cyl.hasOxygen() && !cyl.hasHelium()) continue;
        final composition = (cyl.hasOxygen() ? cyl.oxygen : 0.21, cyl.helium);
        final occurrence = mixOccurrences.update(composition, (count) => count + 1, ifAbsent: () => 0);
        final id = sharedMixIds.putIfAbsent((composition.$1, composition.$2, occurrence), () {
          final (o2, he) = composition;
          final name = _mixName(o2, he);
          final id = _namedId('mix', name, usedIds);
          mixes[id] = (name, o2, he);
          return id;
        });
        mixIds[index] = id;
      }
    }

    final siteIds = {for (final site in sites) site.id: _namedId('site', site.name, usedIds)};
    int startSeconds(Dive d) => d.hasStart() ? d.start.seconds.toInt() : 0;
    final orderedDives = [...dives]..sort((a, b) => startSeconds(a).compareTo(startSeconds(b)));

    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element(
      'uddf',
      nest: () {
        builder.namespace('http://www.streit.cc/uddf/3.2/');
        builder.attribute('version', '3.2.1');

        builder.element(
          'generator',
          nest: () {
            builder.element('name', nest: () => builder.text('Bubbletrail'));
            builder.element('type', nest: () => builder.text('logbook'));
            if (version != null && version.isNotEmpty) {
              builder.element('version', nest: () => builder.text(version));
            }
            builder.element('datetime', nest: () => builder.text(_formatDateTime(DateTime.now().toUtc())));
          },
        );

        if (buddies.isNotEmpty || tankDefinitions.isNotEmpty) {
          builder.element(
            'diver',
            nest: () {
              // An owner is mandatory, but we have no user profile to fill in.
              builder.element(
                'owner',
                attributes: {'id': 'owner'},
                nest: () {
                  builder.element(
                    'personal',
                    nest: () {
                      builder.element('firstname');
                      builder.element('lastname');
                    },
                  );
                  if (tankDefinitions.isNotEmpty) {
                    builder.element(
                      'equipment',
                      nest: () {
                        for (final entry in tankDefinitions.entries) {
                          final cylinder = entry.value;
                          builder.element(
                            'tank',
                            attributes: {'id': entry.key},
                            nest: () {
                              builder.element('name', nest: () => builder.text(cylinder.description));
                              if (cylinder.hasVolumeL()) {
                                builder.element('tankvolume', nest: () => builder.text(_fmt(cylinder.volumeL * _literToCubicMeter)));
                              }
                            },
                          );
                        }
                      },
                    );
                  }
                },
              );
              for (final name in buddies.keys) {
                final (first, last) = _splitName(name);
                builder.element(
                  'buddy',
                  attributes: {'id': buddies[name]!},
                  nest: () {
                    builder.element(
                      'personal',
                      nest: () {
                        builder.element('firstname', nest: () => builder.text(first));
                        builder.element('lastname', nest: () => builder.text(last));
                      },
                    );
                  },
                );
              }
            },
          );
        }

        if (sites.isNotEmpty) {
          builder.element(
            'divesite',
            nest: () {
              for (final site in sites) {
                _writeSite(builder, site, siteIds[site.id]!);
              }
            },
          );
        }

        if (mixes.isNotEmpty) {
          builder.element(
            'gasdefinitions',
            nest: () {
              for (final entry in mixes.entries) {
                final (name, o2, he) = entry.value;
                final n2 = 1.0 - o2 - he;
                builder.element(
                  'mix',
                  attributes: {'id': entry.key},
                  nest: () {
                    builder.element('name', nest: () => builder.text(name));
                    builder.element('o2', nest: () => builder.text(_fmt(o2)));
                    builder.element('n2', nest: () => builder.text(_fmt(n2 < 0 ? 0 : n2)));
                    builder.element('he', nest: () => builder.text(_fmt(he)));
                  },
                );
              }
            },
          );
        }

        if (orderedDives.isNotEmpty) {
          builder.element(
            'profiledata',
            nest: () {
              for (final dive in orderedDives) {
                builder.element(
                  'repetitiongroup',
                  attributes: {'id': _xmlId('group', dive.id)},
                  nest: () {
                    _writeDive(builder, dive, siteIds, buddies, tankIdsByDive[dive.id]!, mixIdsByDive[dive.id]!);
                  },
                );
              }
            },
          );
        }
      },
    );

    // Pretty print, but keep the whitespace inside notes intact: the pretty
    // writer collapses newlines, which would corrupt multi-line notes and
    // the hashtag line carrying the tags.
    return builder.buildDocument().toXmlString(
      pretty: true,
      preserveWhitespace: (node) => node is XmlElement && (node.name.local == 'notes' || node.name.local == 'para'),
    );
  }
}

void _writeSite(XmlBuilder builder, Site site, String id) {
  builder.element(
    'site',
    attributes: {'id': id},
    nest: () {
      // Keep the store ID available for Bubbletrail re-imports. Other readers
      // can use the document's site ID and ignore this processing instruction.
      if (id != site.id) builder.processing('bubbletrail-site-id', _xmlId('site', site.id));
      builder.element('name', nest: () => builder.text(site.name));

      if (site.hasPosition() || site.hasCountry() || site.hasLocation()) {
        builder.element(
          'geography',
          nest: () {
            builder.element('location', nest: () => builder.text(site.hasLocation() ? site.location : ''));
            if (site.hasCountry()) {
              builder.element(
                'address',
                nest: () {
                  builder.element('country', nest: () => builder.text(site.country));
                },
              );
            }
            if (site.hasPosition()) {
              builder.element('latitude', nest: () => builder.text(_fmt(site.position.latitude)));
              builder.element('longitude', nest: () => builder.text(_fmt(site.position.longitude)));
              if (site.position.hasAltitude()) builder.element('altitude', nest: () => builder.text(_fmt(site.position.altitude)));
            }
          },
        );
      }

      final notes = _notesWithTags(site.hasNotes() ? site.notes : null, site.tags);
      if (notes != null && notes.isNotEmpty) {
        builder.element(
          'notes',
          nest: () {
            builder.element('para', nest: () => builder.text(notes));
          },
        );
      }
    },
  );
}

void _writeDive(XmlBuilder builder, Dive dive, Map<String, String> siteIds, Map<String, String> buddies, List<String> tankIds, Map<int, String> mixIds) {
  final log = dive.logs.firstOrNull;

  builder.element(
    'dive',
    attributes: {'id': _xmlId('dive', dive.id)},
    nest: () {
      builder.element(
        'informationbeforedive',
        nest: () {
          if (siteIds[dive.siteId] case final String siteId when dive.hasSiteId()) {
            builder.element('link', attributes: {'ref': siteId});
          }
          for (final name in dive.buddies) {
            final id = buddies[name.trim()];
            if (id != null) {
              builder.element('link', attributes: {'ref': id});
            }
          }
          if (dive.number > 0) {
            builder.element('divenumber', nest: () => builder.text(dive.number.toString()));
          }
          final start = dive.hasStart() ? dive.start.toDateTime() : DateTime.fromMillisecondsSinceEpoch(0);
          builder.element('datetime', nest: () => builder.text(_formatDateTime(start, nanos: dive.start.nanos)));
          final airTemp = log != null && log.hasSurfaceTemperature() ? log.surfaceTemperature : null;
          if (airTemp != null) {
            builder.element('airtemperature', nest: () => builder.text(_formatTemperature(airTemp)));
          }
        },
      );

      if (log != null && log.samples.isNotEmpty) {
        builder.element(
          'samples',
          nest: () {
            final sampleSwitchTimes = <(int, int), double>{
              for (final sample in log.samples)
                for (final event in sample.events)
                  if (event.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE && event.time == sample.time.toInt()) (event.time, event.value): sample.time,
            };
            final switches = <double, int>{
              for (final event in dive.events)
                if (event.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE && event.value >= 0 && event.value < dive.cylinders.length)
                  (sampleSwitchTimes[(event.time, event.value)] ?? event.time.toDouble()): event.value,
            };
            final samples = <double, LogSample>{};
            for (final sample in log.samples) {
              final previous = samples[sample.time];
              if (previous == null) {
                samples[sample.time] = sample;
              } else {
                final merged = sample.deepCopy();
                if (!sample.hasTemperature() && previous.hasTemperature()) merged.temperature = previous.temperature;
                if (!sample.hasDepth() && previous.hasDepth()) merged.depth = previous.depth;
                merged.pressures.insertAll(0, previous.pressures);
                merged.events.insertAll(0, previous.events);
                samples[sample.time] = merged;
              }
            }
            final recorded = samples.keys.sorted((a, b) => a.compareTo(b));
            for (final time in switches.keys) {
              if (samples.containsKey(time)) continue;
              final next = recorded.firstWhereOrNull((t) => t > time);
              final previous = recorded.lastWhereOrNull((t) => t < time);
              final depth = previous == null || next == null
                  ? 0.0
                  : samples[previous]!.depth + (samples[next]!.depth - samples[previous]!.depth) * (time - previous) / (next - previous);
              samples[time] = LogSample(time: time, depth: depth);
            }
            samples.putIfAbsent(0, () => LogSample(time: 0, depth: 0));
            final last = samples.keys.max;
            if (samples[last]!.depth != 0) {
              final end = dive.duration > last ? dive.duration.toDouble() : last + 1;
              samples[end] = LogSample(time: end, depth: 0);
            }
            for (final time in samples.keys.sorted((a, b) => a.compareTo(b))) {
              final sample = samples[time]!;
              final sampleSwitch = sample.events.firstWhereOrNull((event) => event.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE);
              final index = switches[time] ?? sampleSwitch?.value ?? (time == 0 && dive.cylinders.isNotEmpty ? 0 : null);
              final mix = index == null ? null : mixIds[index];
              _writeWaypoint(builder, tankIds, sample, mix);
            }
          },
        );
      }

      for (final (index, cyl) in dive.cylinders.indexed) {
        builder.element(
          'tankdata',
          nest: () {
            final tankId = tankIds[index];
            builder.element('link', attributes: {'ref': tankId});
            final mixId = mixIds[index];
            if (mixId != null) {
              builder.element('link', attributes: {'ref': mixId});
            }
            final volume = _litersToCubicMeters(cyl.hasCylinder() && cyl.cylinder.hasVolumeL() ? cyl.cylinder.volumeL : null);
            if (volume != null) {
              builder.element('tankvolume', nest: () => builder.text(_fmt(volume)));
            }
            builder.element('tankpressurebegin', nest: () => builder.text(_roundPressureToPascals(cyl.beginPressure).toString()));
            final endPressure = _roundPressureToPascals(cyl.endPressure);
            if (endPressure != 0) {
              builder.element('tankpressureend', nest: () => builder.text(endPressure.toString()));
            }
          },
        );
      }

      builder.element(
        'informationafterdive',
        nest: () {
          final lowestTemp = dive.hasMinTemp() ? dive.minTemp : (log != null && log.hasMinTemperature() ? log.minTemperature : null);
          if (lowestTemp != null) {
            builder.element('lowesttemperature', nest: () => builder.text(_formatTemperature(lowestTemp)));
          }
          final greatestDepth = dive.hasMaxDepth() ? dive.maxDepth : (log != null && log.hasMaxDepth() ? log.maxDepth : 0.0);
          builder.element('greatestdepth', nest: () => builder.text(greatestDepth.toStringAsFixed(1)));

          final notes = _notesWithTags(dive.hasNotes() ? dive.notes : null, dive.tags);
          if (notes != null && notes.isNotEmpty) {
            builder.element(
              'notes',
              nest: () {
                builder.element('para', nest: () => builder.text(notes));
              },
            );
          }

          if (dive.hasRating() && dive.rating > 0) {
            builder.element(
              'rating',
              nest: () {
                builder.element('ratingvalue', nest: () => builder.text(dive.rating.toString()));
              },
            );
          }

          builder.element('diveduration', nest: () => builder.text(_fmt(dive.duration.toDouble())));

          // UDDF only has a single total lead weight; the per-weightsystem
          // breakdown cannot be represented.
          final lead = dive.weightsystems.fold(0.0, (sum, ws) => sum + (ws.hasWeight() ? ws.weight : 0.0));
          if (lead > 0) {
            builder.element(
              'equipmentused',
              nest: () {
                builder.element('leadquantity', nest: () => builder.text(_fmt(lead)));
              },
            );
          }

          if (dive.hasMeanDepth()) {
            builder.element('averagedepth', nest: () => builder.text(dive.meanDepth.toStringAsFixed(1)));
          }
        },
      );
    },
  );
}

void _writeWaypoint(XmlBuilder builder, List<String> tankIds, LogSample sample, String? mixId) {
  builder.element(
    'waypoint',
    nest: () {
      builder.element('depth', nest: () => builder.text(sample.depth.toStringAsFixed(1)));
      builder.element('divetime', nest: () => builder.text(_fmt(sample.time)));
      if (mixId != null) builder.element('switchmix', attributes: {'ref': mixId});
      for (final reading in sample.pressures) {
        final pressure = _roundPressureToPascals(reading.pressure);
        if (pressure == 0) continue;
        final index = reading.tankIndex;
        if (index < 0 || index >= tankIds.length) {
          if (index != 0 || tankIds.isNotEmpty) continue;
          builder.element('tankpressure', nest: () => builder.text(pressure.toString()));
          continue;
        }
        builder.element('tankpressure', attributes: {'ref': tankIds[index]}, nest: () => builder.text(pressure.toString()));
      }
      if (sample.hasTemperature()) {
        builder.element('temperature', nest: () => builder.text(_formatTemperature(sample.temperature)));
      }
    },
  );
}

String _xmlId(String kind, String id) => 'bt-$kind-${base64Url.encode(utf8.encode(id)).replaceAll('=', '')}';

String _cylinderId(DiveCylinder cylinder) => cylinder.cylinderId.isNotEmpty ? cylinder.cylinderId : cylinder.cylinder.id;

String _namedId(String kind, String name, Set<String> usedIds) {
  final slug = name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-+|-+$'), '');
  final base = slug.isEmpty ? kind : '$kind-$slug';
  var id = base;
  for (var suffix = 2; !usedIds.add(id); suffix++) {
    id = '$base-$suffix';
  }
  return id;
}

String _readId(String? id, String kind, bool ownExport) {
  if (id == null) return const Uuid().v7();
  final prefix = 'bt-$kind-';
  if (ownExport && id.startsWith(prefix)) {
    try {
      return utf8.decode(base64Url.decode(base64Url.normalize(id.substring(prefix.length))));
    } on FormatException {
      return id;
    }
  }
  return id;
}

// Split a buddy name into (firstname, lastname) at the first whitespace,
// matching how the import joins the two back into a full name.
(String, String) _splitName(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  return (parts.first, parts.skip(1).join(' '));
}

// A human readable name for a gas mix of the given composition.
String _mixName(double o2, double he) {
  final o2pct = (o2 * 100).round();
  final hepct = (he * 100).round();
  if (hepct > 0) return 'Tx$o2pct/$hepct';
  if (o2pct == 21) return 'Air';
  return 'EAN$o2pct';
}

// Append tags as a hashtag-only last line, mirroring how the import
// extracts tags from notes.
String? _notesWithTags(String? notes, List<String> tags) {
  if (tags.isEmpty) return notes;
  final tagLine = tags.map((t) => '#$t').join(' ');
  if (notes == null || notes.isEmpty) return tagLine;
  return '$notes\n\n$tagLine';
}

String _fmt(double value) => value.toString();

String _formatDateTime(DateTime dt, {int? nanos}) {
  final utc = dt.toUtc().toIso8601String();
  if (nanos == null) return utc;
  final seconds = utc.substring(0, utc.indexOf('.'));
  return nanos == 0 ? '${seconds}Z' : '$seconds.${nanos.toString().padLeft(9, '0')}Z';
}

extension _UddfSite on Site {
  static Site fromXml(XmlElement elem, bool ownExport) {
    final storedId = ownExport ? elem.children.whereType<XmlProcessing>().firstWhereOrNull((node) => node.target == 'bubbletrail-site-id')?.value : null;
    final id = _readId(storedId ?? elem.getAttribute('id'), 'site', ownExport);
    final name = _getElementText(elem, 'name') ?? '';

    final geography = elem.getElement('geography');
    Position? position;
    String? country;
    String? location;

    if (geography != null) {
      final lat = double.tryParse(_getElementText(geography, 'latitude') ?? '');
      final lon = double.tryParse(_getElementText(geography, 'longitude') ?? '');
      if (lat != null && lon != null) {
        position = Position(latitude: lat, longitude: lon, altitude: double.tryParse(_getElementText(geography, 'altitude') ?? ''));
      }

      final address = geography.getElement('address');
      if (address != null) {
        country = _getElementText(address, 'country');
      }
      location = _getElementText(geography, 'location');
    }

    final rawNotes = _readNotes(elem.getElement('notes'));

    // Extract tags from notes (last line as #hashtags)
    final extracted = _extractTagsFromNotes(rawNotes);

    final site = Site(id: id, name: name, position: position, country: country, location: location, notes: extracted.notes);
    site.tags.addAll(extracted.tags);
    return site;
  }
}

extension _UddfDive on Dive {
  static Dive fromXml(
    XmlElement elem,
    Map<String, _GasMix> gasMixes,
    Map<String, _Buddy> buddies,
    Map<String, Site> sitesById,
    Map<String, XmlElement> tanks,
    bool ownExport,
  ) {
    final diveId = _readId(elem.getAttribute('id'), 'dive', ownExport);

    final infoBefore = elem.getElement('informationbeforedive');
    final infoAfter = elem.getElement('informationafterdive');

    // Parse datetime
    Timestamp? dateTime;
    final dateTimeStr = _getElementText(infoBefore, 'datetime');
    if (dateTimeStr != null) {
      final parsed = DateTime.tryParse(dateTimeStr);
      if (parsed != null) {
        dateTime = Timestamp.fromDateTime(parsed);
        final fraction = RegExp(r'T[0-9:]+[.,]([0-9]+)').firstMatch(dateTimeStr)?.group(1);
        if (fraction != null) dateTime.nanos = int.parse(fraction.padRight(9, '0').substring(0, 9));
      }
    }

    // Parse dive number
    final diveNumber = int.tryParse(_getElementText(infoBefore, 'divenumber') ?? '') ?? 0;

    // Parse links to sites and buddies
    String? siteId;
    final buddyNames = <String>[];

    if (infoBefore != null) {
      for (final link in infoBefore.findElements('link')) {
        final ref = link.getAttribute('ref');
        if (ref != null) {
          if (sitesById.containsKey(ref)) {
            siteId = sitesById[ref]!.id;
          } else if (buddies.containsKey(ref)) {
            buddyNames.add(buddies[ref]!.fullName);
          }
        }
      }
    }

    // Parse air temperature from informationbeforedive (Subsurface style)
    final airTemp = _kelvinToCelsius(double.tryParse(_getElementText(infoBefore, 'airtemperature') ?? ''));

    // Parse lead weight from equipmentused. The XSD places it inside
    // informationafterdive, but Subsurface writes it in
    // informationbeforedive.
    final weightsystems = <Weightsystem>[];
    final equipUsed = infoAfter?.getElement('equipmentused') ?? infoBefore?.getElement('equipmentused');
    if (equipUsed != null) {
      final leadQty = double.tryParse(_getElementText(equipUsed, 'leadquantity') ?? '');
      if (leadQty != null && leadQty > 0) {
        weightsystems.add(Weightsystem(weight: leadQty, description: 'Lead'));
      }
    }

    // Parse after-dive info
    final greatestDepth = double.tryParse(_getElementText(infoAfter, 'greatestdepth') ?? '');
    final diveDuration = double.tryParse(_getElementText(infoAfter, 'diveduration') ?? '');
    final lowestTemp = _kelvinToCelsius(double.tryParse(_getElementText(infoAfter, 'lowesttemperature') ?? ''));
    final averageDepth = double.tryParse(_getElementText(infoAfter, 'averagedepth') ?? '');

    // Parse rating
    final ratingElem = infoAfter?.getElement('rating');
    final rating = int.tryParse(_getElementText(ratingElem, 'ratingvalue') ?? '');

    final rawNotes = _readNotes(infoAfter?.getElement('notes'));

    // Extract tags from notes (last line as #hashtags)
    final extractedNotes = _extractTagsFromNotes(rawNotes);

    // Parse tank data and build gas mix ID to cylinder index mapping
    final cylinders = <DiveCylinder>[];
    final gasMixIdToCylinderIdx = <String, int>{};
    final tankIndexes = <String, int>{};
    void addCylinder(XmlElement? data, String? tankId) {
      final index = tankIndexes[tankId] ?? cylinders.length;
      if (tankId != null) tankIndexes[tankId] = index;
      final result = _parseTankData(data, tanks[tankId], gasMixes);
      if (index == cylinders.length) {
        cylinders.add(result.cylinder);
      } else {
        cylinders[index] = result.cylinder;
      }
      if (result.gasMixId case final String mixId) gasMixIdToCylinderIdx[mixId] = index;
    }

    for (final link in infoBefore?.findElements('link') ?? <XmlElement>[]) {
      final ref = link.getAttribute('ref');
      if (tanks.containsKey(ref)) addCylinder(null, ref);
    }
    for (final tankData in elem.findElements('tankdata')) {
      final ref = tankData.findElements('link').map((link) => link.getAttribute('ref')).firstWhereOrNull(tanks.containsKey);
      addCylinder(tankData, ref);
    }

    // Parse samples
    final samples = <LogSample>[];
    final samplesElem = elem.getElement('samples');
    if (samplesElem != null) {
      for (final waypoint in samplesElem.findElements('waypoint')) {
        final sample = _parseWaypoint(waypoint, gasMixIdToCylinderIdx, tankIndexes);
        if (sample != null) {
          samples.add(sample);
        }
      }
    }

    // Create log from samples
    final log = Log(maxDepth: greatestDepth, minTemperature: lowestTemp, surfaceTemperature: airTemp);
    log.samples.addAll(samples);

    // Set log time
    if (dateTime != null) {
      log.dateTime = dateTime;
    }

    log.setUniqueID();

    // Create dive
    final dive = Dive(
      id: diveId,
      number: diveNumber,
      start: dateTime,
      duration: diveDuration?.toInt(),
      maxDepth: greatestDepth,
      meanDepth: averageDepth,
      minTemp: lowestTemp,
      rating: rating,
      siteId: siteId,
      notes: extractedNotes.notes,
    );

    dive.tags.addAll(extractedNotes.tags);
    dive.buddies.addAll(buddyNames);
    dive.cylinders.addAll(cylinders);
    dive.weightsystems.addAll(weightsystems);
    var activeCylinder = 0;
    for (final event in samples.expand((sample) => sample.events)) {
      if (event.value == activeCylinder) continue;
      dive.events.add(event.deepCopy());
      activeCylinder = event.value;
    }
    dive.logs.add(log);

    return dive;
  }
}

// Result of parsing tank data: the cylinder and optionally the gas mix ID it links to.
class _TankDataResult {
  final DiveCylinder cylinder;
  final String? gasMixId;

  _TankDataResult({required this.cylinder, this.gasMixId});
}

_TankDataResult _parseTankData(XmlElement? tankData, XmlElement? tank, Map<String, _GasMix> gasMixes) {
  final refs = [...?tankData?.findElements('link').map((link) => link.getAttribute('ref')), tank?.getElement('link')?.getAttribute('ref')];
  final gasMixId = refs.firstWhereOrNull(gasMixes.containsKey);
  final mix = gasMixes[gasMixId];

  // Parse tank volume (may be m³ or liters depending on exporter)
  final tankVolume = _tankVolumeToLiters(double.tryParse(_getElementText(tankData, 'tankvolume') ?? _getElementText(tank, 'tankvolume') ?? ''));

  // Parse pressures (Pa -> bar)
  final beginPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressurebegin') ?? ''));
  final endPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressureend') ?? ''));

  final description = _getElementText(tank, 'name');
  return _TankDataResult(
    cylinder: DiveCylinder(
      cylinder: tankVolume != null || description != null ? Cylinder(volumeL: tankVolume, description: description) : null,
      oxygen: mix?.oxygen ?? 0.21,
      helium: mix?.helium ?? 0,
      beginPressure: beginPressure,
      endPressure: endPressure,
    ),
    gasMixId: gasMixId,
  );
}

LogSample? _parseWaypoint(XmlElement waypoint, Map<String, int> gasMixIdToCylinderIdx, Map<String, int> tankIndexes) {
  final depth = double.tryParse(_getElementText(waypoint, 'depth') ?? '');
  final diveTime = double.tryParse(_getElementText(waypoint, 'divetime') ?? '');

  if (diveTime == null) return null;

  // Temperature (K -> °C)
  final temp = _kelvinToCelsius(double.tryParse(_getElementText(waypoint, 'temperature') ?? ''));

  final sample = LogSample(time: diveTime, depth: depth, temperature: temp);

  for (final reading in waypoint.findElements('tankpressure')) {
    final ref = reading.getAttribute('ref') ?? reading.getAttribute('tankref');
    final index = ref == null ? 0 : tankIndexes[ref];
    final pressure = _pascalToBarConvert(double.tryParse(reading.innerText.trim()));
    if (index != null && pressure != null) sample.pressures.add(TankPressure(tankIndex: index, pressure: pressure));
  }

  // Check for gas switch
  final switchMix = waypoint.getElement('switchmix');
  if (switchMix != null) {
    final ref = switchMix.getAttribute('ref');
    if (ref != null && gasMixIdToCylinderIdx.containsKey(ref)) {
      final cylinderIdx = gasMixIdToCylinderIdx[ref]!;
      sample.events.add(SampleEvent(type: SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE, time: diveTime.toInt(), value: cylinderIdx));
    }
  }

  return sample;
}

// Get text content of a child element.
String? _getElementText(XmlElement? parent, String name) {
  if (parent == null) return null;
  final elem = parent.getElement(name);
  if (elem == null) return null;
  final text = elem.innerText.trim();
  return text.isEmpty ? null : text;
}

String? _readNotes(XmlElement? notes) {
  if (notes == null) return null;
  final paragraphs = notes.findElements('para');
  final text = paragraphs.isEmpty ? notes.innerText.trim() : paragraphs.map((para) => para.innerText.trim()).join('\n\n').trim();
  return text.isEmpty ? null : text;
}
