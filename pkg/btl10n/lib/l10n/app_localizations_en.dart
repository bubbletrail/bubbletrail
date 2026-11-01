// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get dives => 'Dives';

  @override
  String get sites => 'Sites';

  @override
  String get equipment => 'Equipment';

  @override
  String get statistics => 'Statistics';

  @override
  String get preferences => 'Preferences';

  @override
  String get more => 'More';

  @override
  String get noDivesYetAddYourFirstDiveToSeeStatistics => 'No dives yet. Add your first dive to see statistics!';

  @override
  String get unknownState => 'Unknown state';

  @override
  String get activity => 'Activity';

  @override
  String get lifetime => 'Lifetime';

  @override
  String get yearsDiving => 'Years diving';

  @override
  String message(Object years) {
    return '$years';
  }

  @override
  String get totalTime => 'Total time';

  @override
  String get averageMaxDepth => 'Average max depth';

  @override
  String get deepestDive => 'Deepest dive';

  @override
  String get longestDive => 'Longest dive';

  @override
  String get warmestDive => 'Warmest dive';

  @override
  String get coldestDive => 'Coldest dive';

  @override
  String get averageSAC => 'Average SAC';

  @override
  String get units => 'Units';

  @override
  String get depth => 'Depth';

  @override
  String get pressure => 'Pressure';

  @override
  String get temperature => 'Temperature';

  @override
  String get volume => 'Volume';

  @override
  String get weight => 'Weight';

  @override
  String get dateFormat => 'Date format';

  @override
  String get timeFormat => 'Time format';

  @override
  String get syncing => 'Syncing...';

  @override
  String syncFailed(Object error) {
    return 'Sync failed: $error';
  }

  @override
  String get lastSynced => 'Last synced';

  @override
  String get syncNow => 'Sync now';

  @override
  String get editSyncSettings => 'Edit sync settings';

  @override
  String get importExport => 'Import & export';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get editUnits => 'Edit units';

  @override
  String get divePreferences => 'Dive preferences';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get renumberDives => 'Renumber dives';

  @override
  String get resetDatabase => 'Reset database';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get thisWillRenumberAllDivesSequentiallyInChronologicalOrderReplacingAnyExistingDiveNumbe =>
      'This will renumber all dives sequentially, in chronological order, replacing any existing dive numbers.';

  @override
  String get startFrom => 'Start from:';

  @override
  String get cancel => 'Cancel';

  @override
  String get renumberingDives => 'Renumbering dives...';

  @override
  String get logs => 'Logs';

  @override
  String get noLogEntries => 'No log entries';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get importBackup => 'Import backup';

  @override
  String get thisWillReplaceYourExistingDataWithTheBackupYourCurrentDataWillBeMovedToABackupFolder =>
      'This will replace your existing data with the backup. Your current data will be moved to a backup folder. Continue?';

  @override
  String get import => 'Import';

  @override
  String get importingDives => 'Importing dives...';

  @override
  String get importingEquipment => 'Importing equipment...';

  @override
  String errorDetails(Object error) {
    return 'Error: $error';
  }

  @override
  String get exportComplete => 'Export complete';

  @override
  String get importComplete => 'Import complete';

  @override
  String get importLogFile => 'Import log file';

  @override
  String get importEquipment => 'Import equipment';

  @override
  String get exportSubsurfaceFile => 'Export Subsurface file';

  @override
  String get exportUDDFFile => 'Export UDDF file';

  @override
  String get importDatabaseBackup => 'Import database backup';

  @override
  String get exportDatabaseBackup => 'Export database backup';

  @override
  String get gradientFactors => 'Gradient Factors';

  @override
  String get gradientFactorsAdjustTheConservatismOfTheBuhlmannDecompressionAlgorithm =>
      'Gradient factors adjust the conservatism of the Buhlmann decompression algorithm.';

  @override
  String get gfLow => 'GF Low';

  @override
  String get gfHigh => 'GF High';

  @override
  String get filterByLevel => 'Filter by level';

  @override
  String get all => 'All';

  @override
  String get debug => 'Debug+';

  @override
  String get info => 'Info+';

  @override
  String get warning => 'Warning+';

  @override
  String get severe => 'Severe';

  @override
  String get copyAllLogs => 'Copy all logs';

  @override
  String copiedLogEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Copied $count log entries', one: 'Copied 1 log entry');
    return '$_temp0';
  }

  @override
  String get clearLogs => 'Clear logs';

  @override
  String get syncProvider => 'Sync provider';

  @override
  String get off => 'Off';

  @override
  String get bubbletrailS3 => 'Bubbletrail S3';

  @override
  String get genericS3 => 'Generic S3';

  @override
  String get bubbletrailSyncConfiguration => 'Bubbletrail sync configuration';

  @override
  String get s3Configuration => 'S3 configuration';

  @override
  String get endpoint => 'Endpoint';

  @override
  String get s3AmazonawsComOrMinioExampleCom => 's3.amazonaws.com or minio.example.com';

  @override
  String get region => 'Region';

  @override
  String get bucket => 'Bucket';

  @override
  String get myBucketName => 'my-bucket-name';

  @override
  String get theBucketIsTheIdentifierForWhereYourCloudDataIsStored => 'The bucket is the identifier for where your cloud data is stored.';

  @override
  String get accessKey => 'Access key';

  @override
  String get theAccessKeyIsYourUsernameForAuthenticatingToTheStorageProvider => 'The access key is your username for authenticating to the storage provider.';

  @override
  String get secretKey => 'Secret key';

  @override
  String get theSecretKeyIsYourPasswordForAuthenticatingToTheStorageProvider => 'The secret key is your password for authenticating to the storage provider.';

  @override
  String get vaultKey => 'Vault key';

  @override
  String get theVaultKeyIsTheEncryptionPasswordForDataUploadedToTheCloudItPreventsTheStorageProvid =>
      'The vault key is the encryption password for data uploaded to the cloud. It prevents the storage provider from being able to read your data.';

  @override
  String get selectDiveSite => 'Select dive site';

  @override
  String get tags => 'Tags:';

  @override
  String get diveDetails => 'Dive details';

  @override
  String timesShownIn(Object zoneAbbreviation) {
    return 'Times shown in $zoneAbbreviation';
  }

  @override
  String diveNumber(Object number) {
    return 'Dive #$number';
  }

  @override
  String get date => 'Date';

  @override
  String get time => 'Time';

  @override
  String get duration => 'Duration';

  @override
  String get maxDepth => 'Max depth';

  @override
  String get done => 'Done';

  @override
  String get rating => 'Rating';

  @override
  String get defaultEquipmentUpdated => 'Default equipment updated';

  @override
  String get addDefaults => 'Add defaults';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get selectEquipment => 'Select equipment';

  @override
  String get noEquipmentAvailable => 'No equipment available';

  @override
  String get usedThisDive => 'Used this dive';

  @override
  String get availableEquipment => 'Available equipment';

  @override
  String get dragEquipmentHere => 'Drag equipment here';

  @override
  String get noMoreEquipment => 'No more equipment';

  @override
  String get gasChangeTime => 'Gas change time';

  @override
  String get cylinders => 'Cylinders';

  @override
  String get cylinder => 'Cylinder';

  @override
  String cylinderWithId(Object id) {
    return 'Cylinder $id';
  }

  @override
  String get removeCylinder => 'Remove cylinder';

  @override
  String get oxygen => 'Oxygen %';

  @override
  String get helium => 'Helium %';

  @override
  String get startPressure => 'Start pressure';

  @override
  String get endPressure => 'End pressure';

  @override
  String get addCylinder => 'Add cylinder';

  @override
  String get noCylindersDefinedAddCylindersInEquipmentFirst => 'No cylinders defined. Add cylinders in Equipment first.';

  @override
  String get gasChanges => 'Gas changes';

  @override
  String get startOfDive => 'Start of dive';

  @override
  String switchToThisCylinder(Object time) {
    return '$time switch to this cylinder';
  }

  @override
  String get removeGasChange => 'Remove gas change';

  @override
  String get addGasChange => 'Add gas change';

  @override
  String get minutes => 'Minutes';

  @override
  String get seconds => 'Seconds';

  @override
  String get ok => 'OK';

  @override
  String get waitABit => 'Wait a bit';

  @override
  String get gotIt => 'Got it';

  @override
  String get youCanFly => 'You can fly';

  @override
  String diveCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dives', one: '1 dive');
    return '$_temp0';
  }

  @override
  String underwater(Object duration) {
    return '$duration underwater';
  }

  @override
  String get defaultEquipment => 'Default';

  @override
  String get archived => 'Archived';

  @override
  String otherItems(Object count) {
    return 'Others ($count)';
  }

  @override
  String get addTag => 'Add tag';

  @override
  String get unspecified => 'Unspecified';

  @override
  String get none => 'None';

  @override
  String vpm(Object conservatism) {
    return 'VPM $conservatism';
  }

  @override
  String rgbm(Object conservatism) {
    return 'RGBM $conservatism';
  }

  @override
  String dciem(Object conservatism) {
    return 'DCIEM $conservatism';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String deco(Object time, Object depth) {
    return 'Deco $time @ $depth';
  }

  @override
  String deepStop(Object time, Object depth) {
    return 'Deep stop $time @ $depth';
  }

  @override
  String safetyStop(Object time, Object depth) {
    return 'Safety stop $time @ $depth';
  }

  @override
  String ndl(Object time) {
    return '$time NDL';
  }

  @override
  String get air => 'Air';

  @override
  String get weights => 'Weights';

  @override
  String get type => 'Type';

  @override
  String get remove => 'Remove';

  @override
  String get addWeight => 'Add weight';

  @override
  String cylinderNumber(Object number) {
    return 'Cylinder $number';
  }

  @override
  String get wp => 'WP';

  @override
  String get mix => 'Mix';

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get sac => 'SAC';

  @override
  String get backgas => 'Backgas';

  @override
  String get deepDeco => 'Deep deco';

  @override
  String get shallowDeco => 'Shallow deco';

  @override
  String get loading => 'Loading...';

  @override
  String get error => 'Error';

  @override
  String get anErrorOccurred => 'An error occurred';

  @override
  String get noDepthProfileDataAvailable => 'No depth profile data available';

  @override
  String get compCeil => 'Comp ceil: ';

  @override
  String get calcCeil => 'Calc ceil: ';

  @override
  String get addNewDive => 'Add new dive';

  @override
  String get downloadFromComputer => 'Download from computer';

  @override
  String get enterManually => 'Enter manually';

  @override
  String get noDivesYetAddYourFirstDive => 'No dives yet. Add your first dive!';

  @override
  String get enterValidCoordinatesOrClearBothFields => 'Enter valid coordinates, or clear both fields.';

  @override
  String get position => 'Position';

  @override
  String get latitude => 'Latitude';

  @override
  String get longitude => 'Longitude';

  @override
  String get dive => 'Dive ';

  @override
  String get addGases => 'Add gases';

  @override
  String get addWeights => 'Add weights';

  @override
  String get addEquipment => 'Add equipment';

  @override
  String get mergeIntoPreviousDive => 'Merge into previous dive';

  @override
  String get merge => 'Merge';

  @override
  String get deleteDive => 'Delete dive';

  @override
  String get delete => 'Delete';

  @override
  String get viewRawData => 'View raw data';

  @override
  String get addSite => 'Add site';

  @override
  String get location => 'Location';

  @override
  String get addBuddies => 'Add buddies';

  @override
  String get buddy => 'Buddy';

  @override
  String get addDivemaster => 'Add divemaster';

  @override
  String get divemaster => 'Divemaster';

  @override
  String get noDiveSitesAvailable => 'No dive sites available';

  @override
  String get noSite => 'No site';

  @override
  String get buddies => 'Buddies';

  @override
  String get addBuddy => 'Add buddy';

  @override
  String get name => 'Name';

  @override
  String get addNotes => 'Add notes';

  @override
  String get notes => 'Notes';

  @override
  String get addTags => 'Add tags';

  @override
  String get addRating => 'Add rating';

  @override
  String weightNumber(Object number) {
    return 'Weight $number';
  }

  @override
  String get otu => 'OTU';

  @override
  String get cns => 'CNS';

  @override
  String get model => 'Model';

  @override
  String get computer => 'Computer';

  @override
  String get serial => 'Serial';

  @override
  String get number => 'Number';

  @override
  String get meanDepth => 'Mean depth';

  @override
  String get viewFullscreen => 'View fullscreen';

  @override
  String get temp => 'Temp';

  @override
  String get country => 'Country';

  @override
  String get bodyOfWater => 'Body of water';

  @override
  String get sitePosition => 'Site position';

  @override
  String get diveStartPosition => 'Dive start position';

  @override
  String get diveEndPosition => 'Dive end position';

  @override
  String get volumeUsed => 'Volume used';

  @override
  String get noLocationDataAvailable => 'No location data available';

  @override
  String get newDiveSite => 'New dive site';

  @override
  String get notSet => 'Not set';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get deleteSite => 'Delete site';

  @override
  String get addLocation => 'Add location';

  @override
  String get diveSites => 'Dive sites';

  @override
  String get viewAsMap => 'View as map';

  @override
  String get addNewDiveSite => 'Add new dive site';

  @override
  String get noDiveSitesYet => 'No dive sites yet.';

  @override
  String get siteMap => 'Site map';

  @override
  String get noDivesToDisplay => 'No dives to display';

  @override
  String get noDivesMatchTheseFilters => 'No dives match these filters.';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get site => 'Site';

  @override
  String get year => 'Year';

  @override
  String get allYears => 'All years';

  @override
  String get allCountries => 'All countries';

  @override
  String get tag => 'Tag';

  @override
  String get allTags => 'All tags';

  @override
  String get noCountry => 'No country';

  @override
  String get siteDetails => 'Site details';

  @override
  String get selectCountry => 'Select country';

  @override
  String get connectDiveComputer => 'Connect dive computer';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get stop => 'Stop';

  @override
  String get scan => 'Scan';

  @override
  String bluetoothIs(String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'on': 'Bluetooth is on',
      'off': 'Bluetooth is off',
      'turningOn': 'Bluetooth is turning on',
      'turningOff': 'Bluetooth is turning off',
      'unauthorized': 'Bluetooth is unauthorized',
      'unavailable': 'Bluetooth is unavailable',
      'unknown': 'Bluetooth state is unknown',
      'other': 'Bluetooth is $state',
    });
    return '$_temp0';
  }

  @override
  String get pleaseEnableBluetoothToScanForDiveComputers => 'Please enable Bluetooth to scan for dive computers';

  @override
  String get turnOnBluetooth => 'Turn on Bluetooth';

  @override
  String get scanToFindYourDiveComputer => 'Scan to find your dive computer';

  @override
  String get knownDiveComputers => 'Known dive computers';

  @override
  String computersFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dive computers found', one: '1 dive computer found');
    return '$_temp0';
  }

  @override
  String get makeSureYourDiveComputerIsInBluetoothCommunicationMode => 'Make sure your dive computer is in Bluetooth communication mode';

  @override
  String otherDevicesFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count non-dive-computer devices found', one: '1 non-dive-computer device found');
    return '$_temp0';
  }

  @override
  String get showAll => 'Show all';

  @override
  String get download => 'Download';

  @override
  String get forget => 'Forget';

  @override
  String get connect => 'Connect';

  @override
  String status(String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'connected': 'connected',
      'disconnected': 'disconnected',
      'connecting': 'connecting',
      'disconnecting': 'disconnecting',
      'other': '$state',
    });
    return 'Status: $_temp0';
  }

  @override
  String get discoveringServices => 'Discovering services...';

  @override
  String get downloadDives => 'Download dives';

  @override
  String get loadingSupportedComputers => 'Loading supported computers...';

  @override
  String get selectDiveComputer => 'Select dive computer';

  @override
  String suggestedFor(Object deviceName) {
    return 'Suggested for \"$deviceName\":';
  }

  @override
  String get showAllComputers => 'Show all computers...';

  @override
  String get allBLEDiveComputers => 'All BLE dive computers';

  @override
  String divesDownloaded(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dives downloaded', one: '1 dive downloaded');
    return ', $_temp0';
  }

  @override
  String downloadingDives(Object downloadedLabel) {
    return 'Downloading dives...$downloadedLabel';
  }

  @override
  String get excellent => 'Excellent';

  @override
  String get good => 'Good';

  @override
  String get fair => 'Fair';

  @override
  String get weak => 'Weak';

  @override
  String get certifications => 'Certifications';

  @override
  String get addNewCertification => 'Add new certification';

  @override
  String get noCertificationsYetTapToAddOne => 'No certifications yet. Tap + to add one.';

  @override
  String get expired => 'Expired';

  @override
  String get expiring => 'Expiring';

  @override
  String certification(Object id) {
    return 'Certification #$id';
  }

  @override
  String get cylinderTypes => 'Cylinder types';

  @override
  String get addNewCylinderType => 'Add new cylinder type';

  @override
  String get noCylinderTypesYetTapToAddOne => 'No cylinder types yet. Tap + to add one.';

  @override
  String cylinderType(Object id) {
    return 'Cylinder type #$id';
  }

  @override
  String get bcdsRegulatorsWetsuitsEtc => 'BCDs, regulators, wetsuits, etc.';

  @override
  String get availableCylinderTypesAndDefaults => 'Available cylinder types and defaults';

  @override
  String get diverCertificationCards => 'Diver certification cards';

  @override
  String get otherEquipment => 'Other Equipment';

  @override
  String get addNewEquipment => 'Add new equipment';

  @override
  String get noEquipmentYetTapToAddOne => 'No equipment yet. Tap + to add one.';

  @override
  String get showArchived => 'Show archived';

  @override
  String get photoNotYetDownloaded => 'Photo not yet downloaded';

  @override
  String get edit => 'Edit';

  @override
  String get cardFront => 'Card front';

  @override
  String get cardBack => 'Card back';

  @override
  String get agency => 'Agency';

  @override
  String get instructorName => 'Instructor name';

  @override
  String get instructorNumber => 'Instructor number';

  @override
  String get granted => 'Granted';

  @override
  String get expires => 'Expires';

  @override
  String get deleteCertification => 'Delete Certification';

  @override
  String get areYouSureYouWantToDeleteThisCertification => 'Are you sure you want to delete this certification?';

  @override
  String failedToPickImage(Object details) {
    return 'Failed to pick image: $details';
  }

  @override
  String get takePhoto => 'Take photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get newCertification => 'New Certification';

  @override
  String get editCertification => 'Edit Certification';

  @override
  String get discardChanges => 'Discard changes';

  @override
  String get certificationName => 'Certification Name *';

  @override
  String get eGOpenWaterDiver => 'e.g., Open Water Diver';

  @override
  String get required => 'Required';

  @override
  String get certificationNumber => 'Certification Number *';

  @override
  String get eGPADISSI => 'e.g., PADI, SSI';

  @override
  String get replacePhoto => 'Replace photo';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get tapToAddPhoto => 'Tap to add photo';

  @override
  String get deleteCylinderType => 'Delete cylinder type';

  @override
  String get areYouSureYouWantToDeleteThisCylinderTypeThisCannotBeUndone => 'Are you sure you want to delete this cylinder type? This cannot be undone.';

  @override
  String get newCylinderType => 'New cylinder type';

  @override
  String get editCylinderType => 'Edit cylinder type';

  @override
  String get description => 'Description';

  @override
  String get eGAL8012x232 => 'e.g., AL80, 12x232';

  @override
  String get metric => 'Metric';

  @override
  String get waterVolumeL => 'Water volume (L)';

  @override
  String get eG12 => 'e.g. 12';

  @override
  String get workingPressureBar => 'Working pressure (bar)';

  @override
  String get eG232 => 'e.g. 232';

  @override
  String get imperial => 'Imperial';

  @override
  String get sizeCuft => 'Size (cuft)';

  @override
  String get eG80 => 'e.g. 80';

  @override
  String get workingPressurePsi => 'Working pressure (psi)';

  @override
  String get eG3000 => 'e.g. 3000';

  @override
  String get defaultForImports => 'Default for imports';

  @override
  String get useThisCylinderWhenImportingDivesWithoutCylinderTypeInfo => 'Use this cylinder when importing dives without cylinder type info';

  @override
  String get backgas40O => 'Backgas (<40% O₂)';

  @override
  String get deepDeco4060O => 'Deep deco (40-60% O₂)';

  @override
  String get shallowDeco60O => 'Shallow deco (>60% O₂)';

  @override
  String get leaveDivesWithoutCylinderType => 'Leave dives without cylinder type';

  @override
  String get replaceWithAnotherCylinderType => 'Replace with another cylinder type';

  @override
  String get noOtherCylinderTypesExistSoThoseDivesWillBeLeftWithoutACylinder =>
      'No other cylinder types exist, so those dives will be left without a cylinder.';

  @override
  String get deleteEquipment => 'Delete Equipment';

  @override
  String get areYouSureYouWantToDeleteThisEquipment => 'Are you sure you want to delete this equipment?';

  @override
  String get newEquipment => 'New Equipment';

  @override
  String get editEquipment => 'Edit Equipment';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get modelName => 'Model/Name';

  @override
  String get serialNumber => 'Serial Number';

  @override
  String get purchasePrice => 'Purchase Price';

  @override
  String get shop => 'Shop';

  @override
  String get purchaseDate => 'Purchase Date';

  @override
  String get warrantyUntil => 'Warranty Until';

  @override
  String get lastService => 'Last Service';

  @override
  String get addToNewDivesByDefault => 'Add to new dives by default';

  @override
  String get eGBCDRegulatorWetsuit => 'e.g., BCD, Regulator, Wetsuit';

  @override
  String get appTitle => 'Bubbletrail';

  @override
  String mergeDiveConfirmation(int number, int previousNumber) {
    return 'Dive #$number will be merged into dive #$previousNumber, appending its profile to that dive. Dive #$number is then deleted. Continue?';
  }

  @override
  String get resetDatabaseConfirmation =>
      'This will remove all dives, sites, etc. in Bubbletrail and revert to an empty state. Syncing will be disabled, but synced data remains untouched in the cloud. Continue?';

  @override
  String get confirm => 'Confirm';

  @override
  String get unknownSite => 'Unknown site';

  @override
  String diveTitle(int number, String site) {
    return 'Dive #$number: $site';
  }

  @override
  String compactDiveTitle(int number, String site) {
    return '#$number: $site';
  }

  @override
  String minutesDuration(int minutes) {
    return '$minutes min';
  }

  @override
  String hoursMinutesDuration(int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(hours, locale: localeName, other: '$hours hours', one: '1 hour');
    return '$_temp0, $minutes min';
  }

  @override
  String daysHoursDuration(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days', one: '1 day');
    String _temp1 = intl.Intl.pluralLogic(hours, locale: localeName, other: '$hours hours', one: '1 hour');
    return '$_temp0, $_temp1';
  }

  @override
  String daysHoursMinutesDuration(int days, int hours, int minutes) {
    String _temp0 = intl.Intl.pluralLogic(days, locale: localeName, other: '$days days', one: '1 day');
    String _temp1 = intl.Intl.pluralLogic(hours, locale: localeName, other: '$hours hours', one: '1 hour');
    return '$_temp0, $_temp1, $minutes min';
  }

  @override
  String monthlyDiveCount(String month, int year, int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count dives', one: '1 dive');
    return '$month $year: $_temp0';
  }

  @override
  String get weightBackplate => 'Backplate';

  @override
  String get weightBelt => 'Belt';

  @override
  String get weightHarness => 'Harness';

  @override
  String get weightIntegrated => 'Integrated';

  @override
  String get weightTrim => 'Trim';

  @override
  String get noLocation => 'No location';

  @override
  String get equipmentNotFound => 'Equipment not found';

  @override
  String loadEquipmentFailed(String details) {
    return 'Failed to load equipment details: $details';
  }

  @override
  String updateEquipmentFailed(String details) {
    return 'Failed to update equipment: $details';
  }

  @override
  String deleteEquipmentFailed(String details) {
    return 'Failed to delete equipment: $details';
  }

  @override
  String get certificationNotFound => 'Certification not found';

  @override
  String loadCertificationFailed(String details) {
    return 'Failed to load certification details: $details';
  }

  @override
  String updateCertificationFailed(String details) {
    return 'Failed to update certification: $details';
  }

  @override
  String deleteCertificationFailed(String details) {
    return 'Failed to delete certification: $details';
  }

  @override
  String get cylinderNotFound => 'Cylinder not found';

  @override
  String loadCylinderFailed(String details) {
    return 'Failed to load cylinder details: $details';
  }

  @override
  String updateCylinderFailed(String details) {
    return 'Failed to update cylinder: $details';
  }

  @override
  String connectFailed(String details) {
    return 'Failed to connect: $details';
  }

  @override
  String get noServicesDiscovered => 'No services discovered';

  @override
  String get noBleCharacteristics => 'No suitable BLE characteristics found';

  @override
  String notificationsFailed(String details) {
    return 'Failed to enable notifications: $details';
  }

  @override
  String downloadFailed(String details) {
    return 'Download exception: $details';
  }

  @override
  String get unknownError => 'Unknown error';

  @override
  String cylinderTypeWithId(String id) {
    return 'Cylinder type $id';
  }

  @override
  String get equipmentBcd => 'BCD';

  @override
  String get equipmentRegulator => 'Regulator';

  @override
  String get equipmentWetsuit => 'Wetsuit';

  @override
  String get equipmentDrysuit => 'Drysuit';

  @override
  String get equipmentMask => 'Mask';

  @override
  String get equipmentFins => 'Fins';

  @override
  String get equipmentComputer => 'Computer';

  @override
  String get equipmentLight => 'Light';

  @override
  String get equipmentCamera => 'Camera';

  @override
  String get equipmentSmb => 'SMB';

  @override
  String get equipmentReel => 'Reel';

  @override
  String get equipmentWeightBelt => 'Weight belt';

  @override
  String get equipmentHood => 'Hood';

  @override
  String get equipmentGloves => 'Gloves';

  @override
  String get equipmentBoots => 'Boots';

  @override
  String get equipmentOther => 'Other';

  @override
  String measurement(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get perMinute => '/min';

  @override
  String ratePerMinute(String value) {
    return '$value/min';
  }

  @override
  String trimix(int oxygen, int helium) {
    return 'Tx$oxygen/$helium';
  }

  @override
  String nitrox(int oxygen) {
    return 'EAN$oxygen';
  }

  @override
  String get syncingSection => 'Syncing';

  @override
  String equipmentWithId(Object id) {
    return 'Equipment #$id';
  }

  @override
  String get tagsLabel => 'Tags';

  @override
  String buhlmannGradientFactors(Object gfLow, Object gfHigh) {
    return 'Bühlmann GF $gfLow/$gfHigh';
  }

  @override
  String get buhlmann => 'Bühlmann';

  @override
  String durationRange(Object maximumMinutes) {
    return '0 - $maximumMinutes min';
  }

  @override
  String surfaceGradientFactorValue(Object percent) {
    return 'SurfGF: $percent%';
  }

  @override
  String get surfaceGradientFactor => 'SurfGF';

  @override
  String percentage(Object value) {
    return '$value%';
  }

  @override
  String get decoLabel => 'Deco';

  @override
  String get bodyOfWaterTitle => 'Body of Water';

  @override
  String get diveCountColumn => '# Dives';

  @override
  String get diveNumberColumn => 'Dive #';

  @override
  String get requiredName => 'Name *';

  @override
  String downloadingDivesProgress(Object percent, Object downloadedLabel) {
    return 'Downloading dives... $percent%$downloadedLabel';
  }

  @override
  String get certificationTitle => 'Certification';

  @override
  String get deleteCertificationAction => 'Delete certification';

  @override
  String get instructorNameTitle => 'Instructor Name';

  @override
  String get instructorNumberTitle => 'Instructor Number';

  @override
  String get requiredAgency => 'Agency *';

  @override
  String get cylinderTypeLabel => 'Cylinder type';

  @override
  String get deleteEquipmentAction => 'Delete equipment';

  @override
  String get dateExampleEuropean => '25/12/2024';

  @override
  String get dateExampleIso => '2024-12-25';

  @override
  String get dateExampleUs => '12/25/2024';

  @override
  String get timeFormat24Hour => '24h';

  @override
  String get timeFormat12Hour => '12h';

  @override
  String signalStrength(Object strength, Object rssi) {
    return '$strength ($rssi dBm)';
  }

  @override
  String noFlyWaitExplanation(Object waitHours, Object waitFlightGF, Object curFlightGF) {
    return 'Wait $waitHours hours, then your gradient factor at flight level will be $waitFlightGF%. Right now, if teleported to 8000 ft, your GF would be $curFlightGF%.';
  }

  @override
  String noFlySafeExplanation(Object gf) {
    return 'Your gradient factor at flight level will be $gf%, which is likely safe.';
  }

  @override
  String appVersion(Object appVer, Object gitVer) {
    return 'Bubbletrail $appVer ($gitVer)';
  }

  @override
  String deleteDiveConfirmation(Object number) {
    return 'Are you sure you want to delete dive #$number? This cannot be undone.';
  }

  @override
  String deleteSiteConfirmation(Object name) {
    return 'Are you sure you want to delete the site $name? Dives using this site will be left without site. This cannot be undone.';
  }

  @override
  String deviceDownloadFailed(String details) {
    return '$details';
  }

  @override
  String cylinderReplacementPrompt(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dives use this cylinder type. What should those dives use instead?',
      one: '1 dive uses this cylinder type. What should that dive use instead?',
    );
    return '$_temp0';
  }

  @override
  String get countryAD => 'Andorra';

  @override
  String get countryAE => 'United Arab Emirates';

  @override
  String get countryAF => 'Afghanistan';

  @override
  String get countryAG => 'Antigua and Barbuda';

  @override
  String get countryAI => 'Anguilla';

  @override
  String get countryAL => 'Albania';

  @override
  String get countryAM => 'Armenia';

  @override
  String get countryAO => 'Angola';

  @override
  String get countryAQ => 'Antarctica';

  @override
  String get countryAR => 'Argentina';

  @override
  String get countryAS => 'American Samoa';

  @override
  String get countryAT => 'Austria';

  @override
  String get countryAU => 'Australia';

  @override
  String get countryAW => 'Aruba';

  @override
  String get countryAX => 'Åland Islands';

  @override
  String get countryAZ => 'Azerbaijan';

  @override
  String get countryBA => 'Bosnia and Herzegovina';

  @override
  String get countryBB => 'Barbados';

  @override
  String get countryBD => 'Bangladesh';

  @override
  String get countryBE => 'Belgium';

  @override
  String get countryBF => 'Burkina Faso';

  @override
  String get countryBG => 'Bulgaria';

  @override
  String get countryBH => 'Bahrain';

  @override
  String get countryBI => 'Burundi';

  @override
  String get countryBJ => 'Benin';

  @override
  String get countryBL => 'Saint Barthélemy';

  @override
  String get countryBM => 'Bermuda';

  @override
  String get countryBN => 'Brunei';

  @override
  String get countryBO => 'Bolivia';

  @override
  String get countryBQ => 'Caribbean Netherlands';

  @override
  String get countryBR => 'Brazil';

  @override
  String get countryBS => 'Bahamas';

  @override
  String get countryBT => 'Bhutan';

  @override
  String get countryBV => 'Bouvet Island';

  @override
  String get countryBW => 'Botswana';

  @override
  String get countryBY => 'Belarus';

  @override
  String get countryBZ => 'Belize';

  @override
  String get countryCA => 'Canada';

  @override
  String get countryCC => 'Cocos (Keeling) Islands';

  @override
  String get countryCD => 'DR Congo';

  @override
  String get countryCF => 'Central African Republic';

  @override
  String get countryCG => 'Republic of the Congo';

  @override
  String get countryCH => 'Switzerland';

  @override
  String get countryCI => 'Ivory Coast';

  @override
  String get countryCK => 'Cook Islands';

  @override
  String get countryCL => 'Chile';

  @override
  String get countryCM => 'Cameroon';

  @override
  String get countryCN => 'China';

  @override
  String get countryCO => 'Colombia';

  @override
  String get countryCR => 'Costa Rica';

  @override
  String get countryCU => 'Cuba';

  @override
  String get countryCV => 'Cape Verde';

  @override
  String get countryCW => 'Curaçao';

  @override
  String get countryCX => 'Christmas Island';

  @override
  String get countryCY => 'Cyprus';

  @override
  String get countryCZ => 'Czechia';

  @override
  String get countryDE => 'Germany';

  @override
  String get countryDJ => 'Djibouti';

  @override
  String get countryDK => 'Denmark';

  @override
  String get countryDM => 'Dominica';

  @override
  String get countryDO => 'Dominican Republic';

  @override
  String get countryDZ => 'Algeria';

  @override
  String get countryEC => 'Ecuador';

  @override
  String get countryEE => 'Estonia';

  @override
  String get countryEG => 'Egypt';

  @override
  String get countryEH => 'Western Sahara';

  @override
  String get countryER => 'Eritrea';

  @override
  String get countryES => 'Spain';

  @override
  String get countryET => 'Ethiopia';

  @override
  String get countryFI => 'Finland';

  @override
  String get countryFJ => 'Fiji';

  @override
  String get countryFK => 'Falkland Islands';

  @override
  String get countryFM => 'Micronesia';

  @override
  String get countryFO => 'Faroe Islands';

  @override
  String get countryFR => 'France';

  @override
  String get countryGA => 'Gabon';

  @override
  String get countryGB => 'United Kingdom';

  @override
  String get countryGD => 'Grenada';

  @override
  String get countryGE => 'Georgia';

  @override
  String get countryGF => 'French Guiana';

  @override
  String get countryGG => 'Guernsey';

  @override
  String get countryGH => 'Ghana';

  @override
  String get countryGI => 'Gibraltar';

  @override
  String get countryGL => 'Greenland';

  @override
  String get countryGM => 'Gambia';

  @override
  String get countryGN => 'Guinea';

  @override
  String get countryGP => 'Guadeloupe';

  @override
  String get countryGQ => 'Equatorial Guinea';

  @override
  String get countryGR => 'Greece';

  @override
  String get countryGS => 'South Georgia';

  @override
  String get countryGT => 'Guatemala';

  @override
  String get countryGU => 'Guam';

  @override
  String get countryGW => 'Guinea-Bissau';

  @override
  String get countryGY => 'Guyana';

  @override
  String get countryHK => 'Hong Kong';

  @override
  String get countryHM => 'Heard Island and McDonald Islands';

  @override
  String get countryHN => 'Honduras';

  @override
  String get countryHR => 'Croatia';

  @override
  String get countryHT => 'Haiti';

  @override
  String get countryHU => 'Hungary';

  @override
  String get countryID => 'Indonesia';

  @override
  String get countryIE => 'Ireland';

  @override
  String get countryIL => 'Israel';

  @override
  String get countryIM => 'Isle of Man';

  @override
  String get countryIN => 'India';

  @override
  String get countryIO => 'British Indian Ocean Territory';

  @override
  String get countryIQ => 'Iraq';

  @override
  String get countryIR => 'Iran';

  @override
  String get countryIS => 'Iceland';

  @override
  String get countryIT => 'Italy';

  @override
  String get countryJE => 'Jersey';

  @override
  String get countryJM => 'Jamaica';

  @override
  String get countryJO => 'Jordan';

  @override
  String get countryJP => 'Japan';

  @override
  String get countryKE => 'Kenya';

  @override
  String get countryKG => 'Kyrgyzstan';

  @override
  String get countryKH => 'Cambodia';

  @override
  String get countryKI => 'Kiribati';

  @override
  String get countryKM => 'Comoros';

  @override
  String get countryKN => 'Saint Kitts and Nevis';

  @override
  String get countryKP => 'North Korea';

  @override
  String get countryKR => 'South Korea';

  @override
  String get countryKW => 'Kuwait';

  @override
  String get countryKY => 'Cayman Islands';

  @override
  String get countryKZ => 'Kazakhstan';

  @override
  String get countryLA => 'Laos';

  @override
  String get countryLB => 'Lebanon';

  @override
  String get countryLC => 'Saint Lucia';

  @override
  String get countryLI => 'Liechtenstein';

  @override
  String get countryLK => 'Sri Lanka';

  @override
  String get countryLR => 'Liberia';

  @override
  String get countryLS => 'Lesotho';

  @override
  String get countryLT => 'Lithuania';

  @override
  String get countryLU => 'Luxembourg';

  @override
  String get countryLV => 'Latvia';

  @override
  String get countryLY => 'Libya';

  @override
  String get countryMA => 'Morocco';

  @override
  String get countryMC => 'Monaco';

  @override
  String get countryMD => 'Moldova';

  @override
  String get countryME => 'Montenegro';

  @override
  String get countryMF => 'Saint Martin';

  @override
  String get countryMG => 'Madagascar';

  @override
  String get countryMH => 'Marshall Islands';

  @override
  String get countryMK => 'North Macedonia';

  @override
  String get countryML => 'Mali';

  @override
  String get countryMM => 'Myanmar';

  @override
  String get countryMN => 'Mongolia';

  @override
  String get countryMO => 'Macau';

  @override
  String get countryMP => 'Northern Mariana Islands';

  @override
  String get countryMQ => 'Martinique';

  @override
  String get countryMR => 'Mauritania';

  @override
  String get countryMS => 'Montserrat';

  @override
  String get countryMT => 'Malta';

  @override
  String get countryMU => 'Mauritius';

  @override
  String get countryMV => 'Maldives';

  @override
  String get countryMW => 'Malawi';

  @override
  String get countryMX => 'Mexico';

  @override
  String get countryMY => 'Malaysia';

  @override
  String get countryMZ => 'Mozambique';

  @override
  String get countryNA => 'Namibia';

  @override
  String get countryNC => 'New Caledonia';

  @override
  String get countryNE => 'Niger';

  @override
  String get countryNF => 'Norfolk Island';

  @override
  String get countryNG => 'Nigeria';

  @override
  String get countryNI => 'Nicaragua';

  @override
  String get countryNL => 'Netherlands';

  @override
  String get countryNO => 'Norway';

  @override
  String get countryNP => 'Nepal';

  @override
  String get countryNR => 'Nauru';

  @override
  String get countryNU => 'Niue';

  @override
  String get countryNZ => 'New Zealand';

  @override
  String get countryOM => 'Oman';

  @override
  String get countryPA => 'Panama';

  @override
  String get countryPE => 'Peru';

  @override
  String get countryPF => 'French Polynesia';

  @override
  String get countryPG => 'Papua New Guinea';

  @override
  String get countryPH => 'Philippines';

  @override
  String get countryPK => 'Pakistan';

  @override
  String get countryPL => 'Poland';

  @override
  String get countryPM => 'Saint Pierre and Miquelon';

  @override
  String get countryPN => 'Pitcairn Islands';

  @override
  String get countryPR => 'Puerto Rico';

  @override
  String get countryPS => 'Palestine';

  @override
  String get countryPT => 'Portugal';

  @override
  String get countryPW => 'Palau';

  @override
  String get countryPY => 'Paraguay';

  @override
  String get countryQA => 'Qatar';

  @override
  String get countryRE => 'Réunion';

  @override
  String get countryRO => 'Romania';

  @override
  String get countryRS => 'Serbia';

  @override
  String get countryRU => 'Russia';

  @override
  String get countryRW => 'Rwanda';

  @override
  String get countrySA => 'Saudi Arabia';

  @override
  String get countrySB => 'Solomon Islands';

  @override
  String get countrySC => 'Seychelles';

  @override
  String get countrySD => 'Sudan';

  @override
  String get countrySE => 'Sweden';

  @override
  String get countrySG => 'Singapore';

  @override
  String get countrySH => 'Saint Helena';

  @override
  String get countrySI => 'Slovenia';

  @override
  String get countrySJ => 'Svalbard and Jan Mayen';

  @override
  String get countrySK => 'Slovakia';

  @override
  String get countrySL => 'Sierra Leone';

  @override
  String get countrySM => 'San Marino';

  @override
  String get countrySN => 'Senegal';

  @override
  String get countrySO => 'Somalia';

  @override
  String get countrySR => 'Suriname';

  @override
  String get countrySS => 'South Sudan';

  @override
  String get countryST => 'São Tomé and Príncipe';

  @override
  String get countrySV => 'El Salvador';

  @override
  String get countrySX => 'Sint Maarten';

  @override
  String get countrySY => 'Syria';

  @override
  String get countrySZ => 'Eswatini';

  @override
  String get countryTC => 'Turks and Caicos Islands';

  @override
  String get countryTD => 'Chad';

  @override
  String get countryTF => 'French Southern Territories';

  @override
  String get countryTG => 'Togo';

  @override
  String get countryTH => 'Thailand';

  @override
  String get countryTJ => 'Tajikistan';

  @override
  String get countryTK => 'Tokelau';

  @override
  String get countryTL => 'Timor-Leste';

  @override
  String get countryTM => 'Turkmenistan';

  @override
  String get countryTN => 'Tunisia';

  @override
  String get countryTO => 'Tonga';

  @override
  String get countryTR => 'Turkey';

  @override
  String get countryTT => 'Trinidad and Tobago';

  @override
  String get countryTV => 'Tuvalu';

  @override
  String get countryTW => 'Taiwan';

  @override
  String get countryTZ => 'Tanzania';

  @override
  String get countryUA => 'Ukraine';

  @override
  String get countryUG => 'Uganda';

  @override
  String get countryUM => 'U.S. Minor Outlying Islands';

  @override
  String get countryUS => 'United States';

  @override
  String get countryUY => 'Uruguay';

  @override
  String get countryUZ => 'Uzbekistan';

  @override
  String get countryVA => 'Vatican City';

  @override
  String get countryVC => 'Saint Vincent and the Grenadines';

  @override
  String get countryVE => 'Venezuela';

  @override
  String get countryVG => 'British Virgin Islands';

  @override
  String get countryVI => 'U.S. Virgin Islands';

  @override
  String get countryVN => 'Vietnam';

  @override
  String get countryVU => 'Vanuatu';

  @override
  String get countryWF => 'Wallis and Futuna';

  @override
  String get countryWS => 'Samoa';

  @override
  String get countryXK => 'Kosovo';

  @override
  String get countryYE => 'Yemen';

  @override
  String get countryYT => 'Mayotte';

  @override
  String get countryZA => 'South Africa';

  @override
  String get countryZM => 'Zambia';

  @override
  String get countryZW => 'Zimbabwe';

  @override
  String get searchCountries => 'Search...';

  @override
  String get diveNumberLabel => 'Dive number';

  @override
  String get unitMeters => 'm';

  @override
  String get unitFeet => 'ft';

  @override
  String get unitBar => 'bar';

  @override
  String get unitPsi => 'psi';

  @override
  String get unitCelsius => '°C';

  @override
  String get unitFahrenheit => '°F';

  @override
  String get unitLiters => 'L';

  @override
  String get unitCubicFeet => 'cuft';

  @override
  String get unitKilograms => 'kg';

  @override
  String get unitPounds => 'lb';

  @override
  String get unitPoundsPlural => 'lbs';

  @override
  String unknownXmlDiveLog(String details) {
    return 'Unknown dive log XML format: root element is <$details>';
  }

  @override
  String get unsupportedJsonDiveLog => 'Unsupported JSON dive log structure';

  @override
  String get unknownJsonDiveLog => 'Unknown JSON dive log format';

  @override
  String get invalidSuuntoDiveLog => 'Not a Suunto JSON dive log: missing DeviceLog';
}
