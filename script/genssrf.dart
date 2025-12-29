import 'dart:io';
import 'dart:math';

final random = Random(42); // Fixed seed for reproducibility

// Dive sites pool
final sites = [
  ('Sweden / Blekinge / Järnavik', 56.179390, 15.070710),
  ('Thailand / Koh Tao / White Rock', 10.110830, 99.813260),
  ('Sweden / Kullen / Arild, Tussan', 56.277450, 12.571350),
  ('Norway / Oslofjorden / Kjøvangen brygge', 59.537140, 10.659110),
  ('Egypt / Sharm / Temple Reef', 27.847640, 34.309600),
  ('Seychelles / Mahé / Twin Barges', -4.616270, 55.406360),
  ('Egypt / Tiran Islands / Woodhouse', 28.000420, 34.466510),
  ('Thailand / Koh Tao / Japanese Garden', 10.119180, 99.816980),
  ('Egypt / Ras Mohammed / Dunraven', 27.696880, 34.130580),
  ('Thailand / Koh Tao / Chumponh Pinnacle', 10.151750, 99.755810),
  ('Egypt / Sharm / Ras Nasrani', 27.971890, 34.425820),
  ('Egypt / Ras Mohammed / Shark & Yolanda Reef', 27.717770, 34.259690),
  ('Indonesia / Bali / USS Liberty', -8.275390, 115.594720),
  ('Indonesia / Komodo / Batu Bolong', -8.527780, 119.587500),
  ('Philippines / Cebu / Moalboal Sardine Run', 9.946110, 123.394170),
  ('Maldives / South Ari / Broken Rock', 3.500280, 72.833610),
  ('Mexico / Cozumel / Palancar Gardens', 20.361940, -87.021670),
  ('Australia / Great Barrier Reef / Cod Hole', -14.684170, 145.634170),
  ('Red Sea / Brothers / Little Brother', 26.315830, 34.851390),
  ('Croatia / Vis / B-17 Wreck', 43.022500, 16.141390),
  ('Malta / Gozo / Blue Hole', 36.054720, 14.190280),
  ('Iceland / Silfra / Cathedral', 64.255830, -21.116390),
  ('Bahamas / Tiger Beach', 26.865000, -79.075000),
  ('South Africa / Aliwal Shoal / Cathedral', -30.265280, 30.848610),
  ('Costa Rica / Cocos Island / Bajo Alcyone', 5.544440, -87.058890),
  ('Galapagos / Darwin / Darwin Arch', -1.676940, -92.003610),
  ('Palau / Blue Corner', 7.135830, 134.223890),
  ('Japan / Okinawa / Yonaguni Monument', 24.432780, 123.012500),
  ('Fiji / Beqa Lagoon / Shark Reef', -18.230830, 178.024720),
  ('Portugal / Azores / Princess Alice Bank', 37.753890, -29.000000),
];

// Names pool
final buddyNames = [
  'Anna',
  'Erik',
  'Maria',
  'Johan',
  'Lisa',
  'Anders',
  'Sofia',
  'Magnus',
  'Emma',
  'Oscar',
  'Hanna',
  'Karl',
  'Elin',
  'Per',
  'Sara',
  'Nils',
  'Julia',
  'Lars',
  'Maja',
  'Olof',
  'Alice',
  'Gustav',
  'Ida',
  'Henrik',
  'Klara',
  'Axel',
  'Vera',
  'David',
  'Astrid',
  'Filip',
  'Linnea',
  'Viktor',
  'Elsa',
  'Martin',
  'Wilma',
  'Jonas',
  'Ella',
  'Mattias',
  'Ingrid',
  'Peter',
];

final divemasters = [
  'Nina',
  'Carlos',
  'Yuki',
  'Ahmed',
  'Sven',
  'Pietro',
  'Hans',
  'Miguel',
  'Akira',
  'Omar',
  'Bjorn',
  'Marco',
  'Kenji',
  'Ali',
  'Erik',
  'Luigi',
  'Hiroshi',
  'Hassan',
  'Olaf',
  'Giovanni',
  'Takeshi',
  'Khalid',
  'Lars',
  'Franco',
];

final tags = [
  ['Boat', 'Wet'],
  ['Shore', 'Dry'],
  ['Boat', 'Dry'],
  ['Shore', 'Wet'],
  ['Boat', 'Night'],
  ['Boat', 'Deep'],
  ['Shore', 'Night'],
  ['Boat', 'Drift'],
  ['Shore', 'Training'],
  ['Boat', 'Wreck'],
  ['Boat', 'Cave'],
  ['Shore', 'Reef'],
];

final cylinderTypes = [
  (10.0, 300.0, '10x300'),
  (11.1, 232.0, 'AL80'),
  (11.0, 200.0, 'S80'),
  (15.0, 232.0, 'HP100'),
  (24.0, 200.0, 'D12'),
  (12.0, 232.0, '12x232'),
  (10.0, 232.0, '10x232'),
];

final diveComputerModels = [
  ('Suunto D5', 'suunto_d5'),
  ('Shearwater Perdix', 'shearwater_perdix'),
  ('Garmin Descent Mk2', 'garmin_mk2'),
  ('Mares Puck Pro', 'mares_puck'),
  ('Scubapro G2', 'scubapro_g2'),
  ('Oceanic Geo 4.0', 'oceanic_geo4'),
  ('Aqualung i330R', 'aqualung_i330r'),
  ('Cressi Leonardo', 'cressi_leonardo'),
];

String generateUuid() {
  return List.generate(8, (_) => random.nextInt(16).toRadixString(16)).join();
}

String formatDuration(int seconds) {
  final mins = seconds ~/ 60;
  final secs = seconds % 60;
  return '$mins:${secs.toString().padLeft(2, '0')} min';
}

String formatDepth(double depth) => '${depth.toStringAsFixed(2)} m';
String formatTemp(double temp) => '${temp.toStringAsFixed(1)} C';
String formatPressure(double bar) => '${bar.toStringAsFixed(1)} bar';

List<(int, double, double?, double?)> generateSamples(int durationSecs, double maxDepth) {
  final samples = <(int, double, double?, double?)>[];
  final sampleInterval = 15; // 15 second intervals

  // Generate a realistic dive profile
  final descentTime = 60 + random.nextInt(120); // 1-3 min descent
  final ascentTime = (maxDepth * 10).toInt() + random.nextInt(60); // ~10sec per meter + safety stop
  final bottomTime = durationSecs - descentTime - ascentTime;

  double currentDepth = 0;
  double? currentTemp;
  double? currentPressure;

  // Surface temp varies by location/season
  final surfaceTemp = 10.0 + random.nextDouble() * 20; // 10-30C
  final bottomTemp = surfaceTemp - (maxDepth * 0.3); // Roughly -0.3C per meter

  // Starting pressure
  final startPressure = 180.0 + random.nextDouble() * 50; // 180-230 bar
  final endPressure = 30.0 + random.nextDouble() * 40; // 30-70 bar
  final pressurePerSecond = (startPressure - endPressure) / durationSecs;

  for (int t = 0; t <= durationSecs; t += sampleInterval) {
    // Calculate depth based on dive phase
    if (t < descentTime) {
      // Descent phase
      currentDepth = (t / descentTime) * maxDepth;
    } else if (t < descentTime + bottomTime) {
      // Bottom phase - some variation
      currentDepth = maxDepth * (0.85 + random.nextDouble() * 0.15);
    } else {
      // Ascent phase
      final ascentProgress = (t - descentTime - bottomTime) / ascentTime;
      if (ascentProgress < 0.7) {
        // Normal ascent
        currentDepth = maxDepth * (1 - ascentProgress * 1.2);
      } else if (ascentProgress < 0.95) {
        // Safety stop at 5m
        currentDepth = 4.5 + random.nextDouble();
      } else {
        // Final ascent
        currentDepth = 5 * (1 - (ascentProgress - 0.95) * 20);
      }
    }

    currentDepth = max(0, currentDepth + (random.nextDouble() - 0.5) * 0.5);

    // Temperature - occasionally record
    if (t == 0 || random.nextDouble() < 0.1) {
      final depthRatio = currentDepth / maxDepth;
      currentTemp = surfaceTemp - (surfaceTemp - bottomTemp) * depthRatio;
      currentTemp = currentTemp + (random.nextDouble() - 0.5) * 0.5;
    } else {
      currentTemp = null;
    }

    // Pressure - occasionally record
    if (random.nextDouble() < 0.05) {
      currentPressure = startPressure - (t * pressurePerSecond);
      currentPressure = max(endPressure, currentPressure + (random.nextDouble() - 0.5) * 5);
    } else {
      currentPressure = null;
    }

    samples.add((t, currentDepth, currentTemp, currentPressure));
  }

  return samples;
}

void main(List<String> args) async {
  final count = int.parse(args[0]);
  final sink = File(args[1]).openWrite();

  sink.writeln("<divelog program='subsurface' version='3'>");

  // Write settings with fake fingerprints
  sink.writeln('<settings>');
  for (int i = 0; i < 5; i++) {
    final model = generateUuid();
    final serial = generateUuid();
    final deviceid = generateUuid();
    final diveid = generateUuid();
    final data = generateUuid();
    sink.writeln("<fingerprint model='$model' serial='$serial' deviceid='$deviceid' diveid='$diveid' data='$data'/>");
  }
  sink.writeln('</settings>');

  // Generate site UUIDs
  final siteUuids = <String>[];
  sink.writeln('<sites>');
  for (final site in sites) {
    final uuid = generateUuid();
    siteUuids.add(uuid);
    final name = site.$1.replaceAll('&', '&amp;');
    sink.writeln("<site uuid='$uuid' name='$name' gps='${site.$2.toStringAsFixed(6)} ${site.$3.toStringAsFixed(6)}'>");
    sink.writeln('</site>');
  }
  sink.writeln('</sites>');

  // Generate dives
  sink.writeln('<dives>');

  var currentDate = DateTime(2015, 1, 1, 9, 0, 0);

  for (int diveNum = 1; diveNum <= count; diveNum++) {
    // Advance date - average 2-3 dives per dive day, some gaps
    if (random.nextDouble() < 0.4) {
      currentDate = currentDate.add(Duration(days: 1 + random.nextInt(30)));
      currentDate = DateTime(currentDate.year, currentDate.month, currentDate.day, 7 + random.nextInt(3), random.nextInt(60), random.nextInt(60));
    } else {
      currentDate = currentDate.add(Duration(hours: 2 + random.nextInt(3), minutes: random.nextInt(60)));
    }

    // Pick random site
    final siteIdx = random.nextInt(siteUuids.length);
    final siteUuid = siteUuids[siteIdx];

    // Dive parameters
    final rating = 1 + random.nextInt(5);
    final durationMins = 25 + random.nextInt(50); // 25-75 min
    final durationSecs = durationMins * 60 + random.nextInt(60);
    final maxDepth = 8.0 + random.nextDouble() * 32; // 8-40m
    final meanDepth = maxDepth * (0.5 + random.nextDouble() * 0.2);
    final sac = 10.0 + random.nextDouble() * 15; // 10-25 l/min

    final tagSet = tags[random.nextInt(tags.length)];
    final tagsStr = tagSet.join(', ');

    final dateStr = '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${currentDate.hour.toString().padLeft(2, '0')}:${currentDate.minute.toString().padLeft(2, '0')}:${currentDate.second.toString().padLeft(2, '0')}';

    sink.writeln(
      "<dive number='$diveNum' rating='$rating' sac='${sac.toStringAsFixed(3)} l/min' tags='$tagsStr' siteid='$siteUuid' date='$dateStr' time='$timeStr' duration='${formatDuration(durationSecs)}'>",
    );

    // Divemaster (50% chance)
    if (random.nextBool()) {
      final dm = divemasters[random.nextInt(divemasters.length)];
      sink.writeln('  <divemaster>$dm</divemaster>');
    }

    // Buddies (1-3)
    final numBuddies = 1 + random.nextInt(3);
    final buddySet = <String>{};
    while (buddySet.length < numBuddies) {
      buddySet.add(buddyNames[random.nextInt(buddyNames.length)]);
    }
    sink.writeln('  <buddy>${buddySet.join(', ')}</buddy>');

    // Notes (30% chance)
    if (random.nextDouble() < 0.3) {
      final notes = _generateNotes(maxDepth, tagSet);
      sink.writeln('  <notes>$notes</notes>');
    }

    // Cylinder
    final cyl = cylinderTypes[random.nextInt(cylinderTypes.length)];
    final startBar = 180 + random.nextInt(50);
    final endBar = 30 + random.nextInt(50);
    sink.writeln("  <cylinder size='${cyl.$1} l' workpressure='${cyl.$2} bar' description='${cyl.$3}' start='$startBar.0 bar' end='$endBar.0 bar' />");

    // Weightsystem (80% chance)
    if (random.nextDouble() < 0.8) {
      final weight = 2.0 + random.nextDouble() * 8;
      sink.writeln("  <weightsystem weight='${weight.toStringAsFixed(1)} kg' description='integrated' />");
    }

    // Dive computer section
    final dcModel = diveComputerModels[random.nextInt(diveComputerModels.length)];
    sink.writeln("  <divecomputer model='${dcModel.$1}' serial='${generateUuid()}'>");
    sink.writeln("  <depth max='${formatDepth(maxDepth)}' mean='${formatDepth(meanDepth)}' />");

    // Temperature
    final airTemp = 15.0 + random.nextDouble() * 20;
    final waterTemp = 8.0 + random.nextDouble() * 22;
    sink.writeln("  <temperature air='${formatTemp(airTemp)}' water='${formatTemp(waterTemp)}' />");

    // Extradata
    final currents = ['None', 'Light', 'Moderate', 'Strong'];
    final entries = ['Shore', 'Boat', 'Platform'];
    sink.writeln("  <extradata key='current' value='${currents[random.nextInt(currents.length)]}' />");
    sink.writeln("  <extradata key='entryType' value='${entries[random.nextInt(entries.length)]}' />");

    // Gas change event
    sink.writeln("  <event time='0:00 min' type='11' value='21' name='gaschange' cylinder='0' />");

    // Generate samples
    final samples = generateSamples(durationSecs, maxDepth);
    for (final sample in samples) {
      final (time, depth, temp, pressure) = sample;
      var sampleStr = "  <sample time='${formatDuration(time)}' depth='${formatDepth(depth)}'";
      if (temp != null) {
        sampleStr += " temp='${formatTemp(temp)}'";
      }
      if (pressure != null) {
        sampleStr += " pressure='${formatPressure(pressure)}'";
      }
      sampleStr += ' />';
      sink.writeln(sampleStr);
    }

    sink.writeln('  </divecomputer>');
    sink.writeln('</dive>');
  }

  sink.writeln('</dives>');
  sink.writeln('</divelog>');

  await sink.close();
}

String _generateNotes(double maxDepth, List<String> tags) {
  final notes = <String>[
    'Great visibility today, saw lots of fish.',
    'Strong current at the beginning, calmed down later.',
    'Beautiful coral formations.',
    'Saw a turtle during the safety stop!',
    'Good dive, practiced buoyancy control.',
    'Night dive with great bioluminescence.',
    'Wreck penetration, amazing experience.',
    'Perfect conditions for photography.',
    'Cold thermocline at ${(maxDepth * 0.6).toStringAsFixed(0)}m.',
    'Encountered a school of barracuda.',
    'Drift dive along the wall.',
    'Training dive, worked on trim.',
    'Saw manta rays at cleaning station.',
    'Jellyfish everywhere, had to be careful.',
  ];

  return notes[random.nextInt(notes.length)];
}
