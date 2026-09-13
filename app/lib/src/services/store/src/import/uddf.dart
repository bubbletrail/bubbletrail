import 'package:btproto/btproto.dart';
import 'package:collection/collection.dart';
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';

import '../ext/ext.dart';
import 'container.dart';

const double _kelvinOffset = 273.15;
const double _pascalToBar = 1e-5;
const double _barToPascal = 1e5;
const double _cubicMeterToLiter = 1000.0;
const double _literToCubicMeter = 0.001;

double? _kelvinToCelsius(double? k) => k != null ? k - _kelvinOffset : null;
double? _pascalToBarConvert(double? pa) => pa != null ? pa * _pascalToBar : null;
double? _celsiusToKelvin(double? c) => c != null ? c + _kelvinOffset : null;
double? _barToPascalConvert(double? bar) => bar != null ? bar * _barToPascal : null;
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
        final site = _UddfSite.fromXml(siteElem);
        sites.add(site);
        sitesById[site.id] = site;
      }
    }

    // Parse dives
    final dives = <Dive>[];
    final profileData = elem.getElement('profiledata');
    if (profileData != null) {
      for (final repGroup in profileData.findElements('repetitiongroup')) {
        for (final diveElem in repGroup.findElements('dive')) {
          final dive = _UddfDive.fromXml(diveElem, gasMixes, buddies, sitesById);
          dives.add(dive);
        }
      }
    }

    return Container(dives: dives, sites: sites);
  }

  // Serialise the container to a UDDF 3.2.1 document string.
  //
  // This is the inverse of [fromXml]: all data with a UDDF representation
  // survives an export followed by a re-import. Data without one (dive
  // computer model/serial, cylinder descriptions, SAC/OTU/CNS, etc.) is
  // left out. The [version], when given, is recorded as the generating
  // application's version.
  String toUddfString({String? version}) {
    // Collect the shared definitions referenced by the dives: buddies by
    // name, gas mixes by composition. The ids only need to be unique within
    // the document.
    final buddies = <String, String>{};
    for (final dive in dives) {
      for (final name in dive.buddies) {
        final trimmed = name.trim();
        if (trimmed.isNotEmpty) buddies.putIfAbsent(trimmed, () => 'buddy-${buddies.length + 1}');
      }
    }
    final mixes = <(double, double), String>{};
    for (final dive in dives) {
      for (final cyl in dive.cylinders) {
        if (cyl.hasOxygen() || cyl.hasHelium()) {
          mixes.putIfAbsent((cyl.oxygen, cyl.helium), () => 'mix-${mixes.length + 1}');
        }
      }
    }
    String? mixIdFor(DiveCylinder cyl) {
      if (!cyl.hasOxygen() && !cyl.hasHelium()) return null;
      return mixes[(cyl.oxygen, cyl.helium)];
    }

    final siteIds = sites.map((s) => s.id).toSet();
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

        if (buddies.isNotEmpty) {
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
                _writeSite(builder, site);
              }
            },
          );
        }

        if (mixes.isNotEmpty) {
          builder.element(
            'gasdefinitions',
            nest: () {
              for (final entry in mixes.entries) {
                final (o2, he) = entry.key;
                final n2 = 1.0 - o2 - he;
                builder.element(
                  'mix',
                  attributes: {'id': entry.value},
                  nest: () {
                    builder.element('name', nest: () => builder.text(_mixName(o2, he)));
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
                  attributes: {'id': 'rg-${dive.id}'},
                  nest: () {
                    _writeDive(builder, dive, siteIds, buddies, mixIdFor);
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

void _writeSite(XmlBuilder builder, Site site) {
  builder.element(
    'site',
    attributes: {'id': site.id},
    nest: () {
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

void _writeDive(XmlBuilder builder, Dive dive, Set<String> siteIds, Map<String, String> buddies, String? Function(DiveCylinder) mixIdFor) {
  final log = dive.logs.firstOrNull;

  builder.element(
    'dive',
    attributes: {'id': dive.id},
    nest: () {
      builder.element(
        'informationbeforedive',
        nest: () {
          if (dive.hasSiteId() && siteIds.contains(dive.siteId)) {
            builder.element('link', attributes: {'ref': dive.siteId});
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
          builder.element('datetime', nest: () => builder.text(_formatDateTime(start)));
          final airTemp = _celsiusToKelvin(log != null && log.hasSurfaceTemperature() ? log.surfaceTemperature : null);
          if (airTemp != null) {
            builder.element('airtemperature', nest: () => builder.text(_fmt(airTemp)));
          }
        },
      );

      if (log != null && log.samples.isNotEmpty) {
        builder.element(
          'samples',
          nest: () {
            // Gas switches on downloaded dives live on the dive itself rather
            // than on the samples; index them by time so they land on the
            // matching waypoint.
            final switchByTime = <int, int>{
              for (final event in dive.events)
                if (event.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE) event.time: event.value,
            };
            for (final sample in log.samples) {
              _writeWaypoint(builder, dive, sample, mixIdFor, switchByTime);
            }
          },
        );
      }

      for (final cyl in dive.cylinders) {
        builder.element(
          'tankdata',
          nest: () {
            final mixId = mixIdFor(cyl);
            if (mixId != null) {
              builder.element('link', attributes: {'ref': mixId});
            }
            final volume = _litersToCubicMeters(cyl.hasCylinder() && cyl.cylinder.hasVolumeL() ? cyl.cylinder.volumeL : null);
            if (volume != null) {
              builder.element('tankvolume', nest: () => builder.text(_fmt(volume)));
            }
            final begin = _barToPascalConvert(cyl.hasBeginPressure() ? cyl.beginPressure : null);
            if (begin != null) {
              builder.element('tankpressurebegin', nest: () => builder.text(_fmt(begin)));
            }
            final end = _barToPascalConvert(cyl.hasEndPressure() ? cyl.endPressure : null);
            if (end != null) {
              builder.element('tankpressureend', nest: () => builder.text(_fmt(end)));
            }
          },
        );
      }

      builder.element(
        'informationafterdive',
        nest: () {
          final lowestTemp = _celsiusToKelvin(log != null && log.hasMinTemperature() ? log.minTemperature : (dive.hasMinTemp() ? dive.minTemp : null));
          if (lowestTemp != null) {
            builder.element('lowesttemperature', nest: () => builder.text(_fmt(lowestTemp)));
          }
          final greatestDepth = dive.hasMaxDepth() ? dive.maxDepth : (log != null && log.hasMaxDepth() ? log.maxDepth : 0.0);
          builder.element('greatestdepth', nest: () => builder.text(_fmt(greatestDepth)));

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
            builder.element('averagedepth', nest: () => builder.text(_fmt(dive.meanDepth)));
          }
        },
      );
    },
  );
}

void _writeWaypoint(XmlBuilder builder, Dive dive, LogSample sample, String? Function(DiveCylinder) mixIdFor, Map<int, int> switchByTime) {
  builder.element(
    'waypoint',
    nest: () {
      if (sample.hasDepth()) {
        builder.element('depth', nest: () => builder.text(_fmt(sample.depth)));
      }
      builder.element('divetime', nest: () => builder.text(_fmt(sample.time)));

      // The gas in use changes either via an event on the sample itself
      // (imported dives) or via a dive level event at this time (downloaded
      // dives).
      final cylIdx =
          sample.events.firstWhereOrNull((e) => e.type == SampleEventType.SAMPLE_EVENT_TYPE_GAS_CHANGE)?.value ?? switchByTime.remove(sample.time.toInt());
      if (cylIdx != null && cylIdx >= 0 && cylIdx < dive.cylinders.length) {
        final mixId = mixIdFor(dive.cylinders[cylIdx]);
        if (mixId != null) {
          builder.element('switchmix', attributes: {'ref': mixId});
        }
      }

      final reading = sample.pressures.firstWhereOrNull((p) => p.tankIndex == 0) ?? sample.pressures.firstOrNull;
      final tankPressure = _barToPascalConvert(reading != null && reading.hasPressure() ? reading.pressure : null);
      if (tankPressure != null) {
        builder.element('tankpressure', nest: () => builder.text(_fmt(tankPressure)));
      }

      final temperature = _celsiusToKelvin(sample.hasTemperature() ? sample.temperature : null);
      if (temperature != null) {
        builder.element('temperature', nest: () => builder.text(_fmt(temperature)));
      }
    },
  );
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

// Format a number with up to six decimals, trailing zeros trimmed.
String _fmt(double value) {
  var s = value.toStringAsFixed(6);
  if (s.contains('.')) {
    s = s.replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }
  return s.isEmpty || s == '-' ? '0' : s;
}

// Format a timestamp as an xs:dateTime string, in local time with the
// UTC offset included so the instant survives re-import in any timezone.
String _formatDateTime(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = dt.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final offsetText = '$sign${two(offset.inHours.abs())}:${two(offset.inMinutes.abs() % 60)}';
  return '${dt.year.toString().padLeft(4, '0')}-${two(dt.month)}-${two(dt.day)}T${two(dt.hour)}:${two(dt.minute)}:${two(dt.second)}$offsetText';
}

extension _UddfSite on Site {
  static Site fromXml(XmlElement elem) {
    final id = elem.getAttribute('id') ?? const Uuid().v7();
    final name = _getElementText(elem, 'name') ?? '';

    final geography = elem.getElement('geography');
    Position? position;
    String? country;
    String? location;

    if (geography != null) {
      final lat = double.tryParse(_getElementText(geography, 'latitude') ?? '');
      final lon = double.tryParse(_getElementText(geography, 'longitude') ?? '');
      if (lat != null && lon != null) {
        position = Position(latitude: lat, longitude: lon);
      }

      final address = geography.getElement('address');
      if (address != null) {
        country = _getElementText(address, 'country');
      }
      location = _getElementText(geography, 'location');
    }

    // Parse notes - may have <para> wrapper or plain text
    final notesElem = elem.getElement('notes');
    String? rawNotes;
    if (notesElem != null) {
      final para = notesElem.getElement('para');
      if (para != null) {
        rawNotes = para.innerText.trim();
      } else {
        rawNotes = notesElem.innerText.trim();
      }
      if (rawNotes.isEmpty) rawNotes = null;
    }

    // Extract tags from notes (last line as #hashtags)
    final extracted = _extractTagsFromNotes(rawNotes);

    final site = Site(id: id, name: name, position: position, country: country, location: location, notes: extracted.notes);
    site.tags.addAll(extracted.tags);
    return site;
  }
}

extension _UddfDive on Dive {
  static Dive fromXml(XmlElement elem, Map<String, _GasMix> gasMixes, Map<String, _Buddy> buddies, Map<String, Site> sitesById) {
    final diveId = elem.getAttribute('id') ?? const Uuid().v7();

    final infoBefore = elem.getElement('informationbeforedive');
    final infoAfter = elem.getElement('informationafterdive');

    // Parse datetime
    DateTime? dateTime;
    final dateTimeStr = _getElementText(infoBefore, 'datetime');
    if (dateTimeStr != null) {
      dateTime = DateTime.tryParse(dateTimeStr);
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
            siteId = ref;
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

    // Parse notes - may have <para> wrapper or plain text
    final notesElem = infoAfter?.getElement('notes');
    String? rawNotes;
    if (notesElem != null) {
      final para = notesElem.getElement('para');
      if (para != null) {
        rawNotes = para.innerText.trim();
      } else {
        rawNotes = notesElem.innerText.trim();
      }
      if (rawNotes.isEmpty) rawNotes = null;
    }

    // Extract tags from notes (last line as #hashtags)
    final extractedNotes = _extractTagsFromNotes(rawNotes);

    // Parse tank data and build gas mix ID to cylinder index mapping
    final cylinders = <DiveCylinder>[];
    final gasMixIdToCylinderIdx = <String, int>{};
    for (final tankData in elem.findElements('tankdata')) {
      final result = _parseTankData(tankData, gasMixes);
      if (result != null) {
        if (result.gasMixId != null) {
          gasMixIdToCylinderIdx[result.gasMixId!] = cylinders.length;
        }
        cylinders.add(result.cylinder);
      }
    }

    // Parse samples
    final samples = <LogSample>[];
    final samplesElem = elem.getElement('samples');
    if (samplesElem != null) {
      for (final waypoint in samplesElem.findElements('waypoint')) {
        final sample = _parseWaypoint(waypoint, gasMixIdToCylinderIdx);
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
      log.dateTime = Timestamp.fromDateTime(dateTime);
    }

    log.setUniqueID();

    // Create dive
    final dive = Dive(
      id: diveId,
      number: diveNumber,
      start: dateTime != null ? Timestamp.fromDateTime(dateTime) : null,
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

_TankDataResult? _parseTankData(XmlElement tankData, Map<String, _GasMix> gasMixes) {
  // Get gas mix from link
  double oxygen = 0.21;
  double helium = 0.0;
  String? gasMixId;

  for (final link in tankData.findElements('link')) {
    final ref = link.getAttribute('ref');
    if (ref != null && gasMixes.containsKey(ref)) {
      final mix = gasMixes[ref]!;
      oxygen = mix.oxygen;
      helium = mix.helium;
      gasMixId = ref;
      break;
    }
  }

  // Parse tank volume (may be m³ or liters depending on exporter)
  final tankVolume = _tankVolumeToLiters(double.tryParse(_getElementText(tankData, 'tankvolume') ?? ''));

  // Parse pressures (Pa -> bar)
  final beginPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressurebegin') ?? ''));
  final endPressure = _pascalToBarConvert(double.tryParse(_getElementText(tankData, 'tankpressureend') ?? ''));

  return _TankDataResult(
    cylinder: DiveCylinder(
      cylinder: tankVolume != null ? Cylinder(volumeL: tankVolume) : null,
      oxygen: oxygen,
      helium: helium,
      beginPressure: beginPressure,
      endPressure: endPressure,
    ),
    gasMixId: gasMixId,
  );
}

LogSample? _parseWaypoint(XmlElement waypoint, Map<String, int> gasMixIdToCylinderIdx) {
  final depth = double.tryParse(_getElementText(waypoint, 'depth') ?? '');
  final diveTime = double.tryParse(_getElementText(waypoint, 'divetime') ?? '');

  if (diveTime == null) return null;

  // Temperature (K -> °C)
  final temp = _kelvinToCelsius(double.tryParse(_getElementText(waypoint, 'temperature') ?? ''));

  // Tank pressure (Pa -> bar)
  final tankPressure = _pascalToBarConvert(double.tryParse(_getElementText(waypoint, 'tankpressure') ?? ''));

  final sample = LogSample(time: diveTime, depth: depth, temperature: temp);

  if (tankPressure != null) {
    sample.pressures.add(TankPressure(tankIndex: 0, pressure: tankPressure));
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
