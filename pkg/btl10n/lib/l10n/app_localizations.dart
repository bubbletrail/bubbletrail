import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @dives.
  ///
  /// In en, this message translates to:
  /// **'Dives'**
  String get dives;

  /// No description provided for @sites.
  ///
  /// In en, this message translates to:
  /// **'Sites'**
  String get sites;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @more.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// No description provided for @noDivesYetAddYourFirstDiveToSeeStatistics.
  ///
  /// In en, this message translates to:
  /// **'No dives yet. Add your first dive to see statistics!'**
  String get noDivesYetAddYourFirstDiveToSeeStatistics;

  /// No description provided for @unknownState.
  ///
  /// In en, this message translates to:
  /// **'Unknown state'**
  String get unknownState;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @lifetime.
  ///
  /// In en, this message translates to:
  /// **'Lifetime'**
  String get lifetime;

  /// No description provided for @yearsDiving.
  ///
  /// In en, this message translates to:
  /// **'Years diving'**
  String get yearsDiving;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'{years}'**
  String message(Object years);

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTime;

  /// No description provided for @averageMaxDepth.
  ///
  /// In en, this message translates to:
  /// **'Average max depth'**
  String get averageMaxDepth;

  /// No description provided for @deepestDive.
  ///
  /// In en, this message translates to:
  /// **'Deepest dive'**
  String get deepestDive;

  /// No description provided for @longestDive.
  ///
  /// In en, this message translates to:
  /// **'Longest dive'**
  String get longestDive;

  /// No description provided for @warmestDive.
  ///
  /// In en, this message translates to:
  /// **'Warmest dive'**
  String get warmestDive;

  /// No description provided for @coldestDive.
  ///
  /// In en, this message translates to:
  /// **'Coldest dive'**
  String get coldestDive;

  /// No description provided for @averageSAC.
  ///
  /// In en, this message translates to:
  /// **'Average SAC'**
  String get averageSAC;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @depth.
  ///
  /// In en, this message translates to:
  /// **'Depth'**
  String get depth;

  /// No description provided for @pressure.
  ///
  /// In en, this message translates to:
  /// **'Pressure'**
  String get pressure;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'Date format'**
  String get dateFormat;

  /// No description provided for @timeFormat.
  ///
  /// In en, this message translates to:
  /// **'Time format'**
  String get timeFormat;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed: {error}'**
  String syncFailed(Object error);

  /// No description provided for @lastSynced.
  ///
  /// In en, this message translates to:
  /// **'Last synced'**
  String get lastSynced;

  /// No description provided for @syncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncNow;

  /// No description provided for @editSyncSettings.
  ///
  /// In en, this message translates to:
  /// **'Edit sync settings'**
  String get editSyncSettings;

  /// No description provided for @importExport.
  ///
  /// In en, this message translates to:
  /// **'Import & export'**
  String get importExport;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// No description provided for @editUnits.
  ///
  /// In en, this message translates to:
  /// **'Edit units'**
  String get editUnits;

  /// No description provided for @divePreferences.
  ///
  /// In en, this message translates to:
  /// **'Dive preferences'**
  String get divePreferences;

  /// No description provided for @maintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get maintenance;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @renumberDives.
  ///
  /// In en, this message translates to:
  /// **'Renumber dives'**
  String get renumberDives;

  /// No description provided for @resetDatabase.
  ///
  /// In en, this message translates to:
  /// **'Reset database'**
  String get resetDatabase;

  /// No description provided for @openSourceLicenses.
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// No description provided for @thisWillRenumberAllDivesSequentiallyInChronologicalOrderReplacingAnyExistingDiveNumbe.
  ///
  /// In en, this message translates to:
  /// **'This will renumber all dives sequentially, in chronological order, replacing any existing dive numbers.'**
  String get thisWillRenumberAllDivesSequentiallyInChronologicalOrderReplacingAnyExistingDiveNumbe;

  /// No description provided for @startFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from:'**
  String get startFrom;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @renumberingDives.
  ///
  /// In en, this message translates to:
  /// **'Renumbering dives...'**
  String get renumberingDives;

  /// No description provided for @logs.
  ///
  /// In en, this message translates to:
  /// **'Logs'**
  String get logs;

  /// No description provided for @noLogEntries.
  ///
  /// In en, this message translates to:
  /// **'No log entries'**
  String get noLogEntries;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @thisWillReplaceYourExistingDataWithTheBackupYourCurrentDataWillBeMovedToABackupFolder.
  ///
  /// In en, this message translates to:
  /// **'This will replace your existing data with the backup. Your current data will be moved to a backup folder. Continue?'**
  String get thisWillReplaceYourExistingDataWithTheBackupYourCurrentDataWillBeMovedToABackupFolder;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @importingDives.
  ///
  /// In en, this message translates to:
  /// **'Importing dives...'**
  String get importingDives;

  /// No description provided for @importingEquipment.
  ///
  /// In en, this message translates to:
  /// **'Importing equipment...'**
  String get importingEquipment;

  /// No description provided for @errorDetails.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorDetails(Object error);

  /// No description provided for @exportComplete.
  ///
  /// In en, this message translates to:
  /// **'Export complete'**
  String get exportComplete;

  /// No description provided for @importComplete.
  ///
  /// In en, this message translates to:
  /// **'Import complete'**
  String get importComplete;

  /// No description provided for @importLogFile.
  ///
  /// In en, this message translates to:
  /// **'Import log file'**
  String get importLogFile;

  /// No description provided for @importEquipment.
  ///
  /// In en, this message translates to:
  /// **'Import equipment'**
  String get importEquipment;

  /// No description provided for @exportSubsurfaceFile.
  ///
  /// In en, this message translates to:
  /// **'Export Subsurface file'**
  String get exportSubsurfaceFile;

  /// No description provided for @exportUDDFFile.
  ///
  /// In en, this message translates to:
  /// **'Export UDDF file'**
  String get exportUDDFFile;

  /// No description provided for @importDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Import database backup'**
  String get importDatabaseBackup;

  /// No description provided for @exportDatabaseBackup.
  ///
  /// In en, this message translates to:
  /// **'Export database backup'**
  String get exportDatabaseBackup;

  /// No description provided for @gradientFactors.
  ///
  /// In en, this message translates to:
  /// **'Gradient Factors'**
  String get gradientFactors;

  /// No description provided for @gradientFactorsAdjustTheConservatismOfTheBuhlmannDecompressionAlgorithm.
  ///
  /// In en, this message translates to:
  /// **'Gradient factors adjust the conservatism of the Buhlmann decompression algorithm.'**
  String get gradientFactorsAdjustTheConservatismOfTheBuhlmannDecompressionAlgorithm;

  /// No description provided for @gfLow.
  ///
  /// In en, this message translates to:
  /// **'GF Low'**
  String get gfLow;

  /// No description provided for @gfHigh.
  ///
  /// In en, this message translates to:
  /// **'GF High'**
  String get gfHigh;

  /// No description provided for @filterByLevel.
  ///
  /// In en, this message translates to:
  /// **'Filter by level'**
  String get filterByLevel;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug+'**
  String get debug;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info+'**
  String get info;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning+'**
  String get warning;

  /// No description provided for @severe.
  ///
  /// In en, this message translates to:
  /// **'Severe'**
  String get severe;

  /// No description provided for @copyAllLogs.
  ///
  /// In en, this message translates to:
  /// **'Copy all logs'**
  String get copyAllLogs;

  /// No description provided for @copiedLogEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Copied 1 log entry} other{Copied {count} log entries}}'**
  String copiedLogEntries(int count);

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get clearLogs;

  /// No description provided for @syncProvider.
  ///
  /// In en, this message translates to:
  /// **'Sync provider'**
  String get syncProvider;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @bubbletrailS3.
  ///
  /// In en, this message translates to:
  /// **'Bubbletrail S3'**
  String get bubbletrailS3;

  /// No description provided for @genericS3.
  ///
  /// In en, this message translates to:
  /// **'Generic S3'**
  String get genericS3;

  /// No description provided for @bubbletrailSyncConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Bubbletrail sync configuration'**
  String get bubbletrailSyncConfiguration;

  /// No description provided for @s3Configuration.
  ///
  /// In en, this message translates to:
  /// **'S3 configuration'**
  String get s3Configuration;

  /// No description provided for @endpoint.
  ///
  /// In en, this message translates to:
  /// **'Endpoint'**
  String get endpoint;

  /// No description provided for @s3AmazonawsComOrMinioExampleCom.
  ///
  /// In en, this message translates to:
  /// **'s3.amazonaws.com or minio.example.com'**
  String get s3AmazonawsComOrMinioExampleCom;

  /// No description provided for @region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get region;

  /// No description provided for @bucket.
  ///
  /// In en, this message translates to:
  /// **'Bucket'**
  String get bucket;

  /// No description provided for @myBucketName.
  ///
  /// In en, this message translates to:
  /// **'my-bucket-name'**
  String get myBucketName;

  /// No description provided for @theBucketIsTheIdentifierForWhereYourCloudDataIsStored.
  ///
  /// In en, this message translates to:
  /// **'The bucket is the identifier for where your cloud data is stored.'**
  String get theBucketIsTheIdentifierForWhereYourCloudDataIsStored;

  /// No description provided for @accessKey.
  ///
  /// In en, this message translates to:
  /// **'Access key'**
  String get accessKey;

  /// No description provided for @theAccessKeyIsYourUsernameForAuthenticatingToTheStorageProvider.
  ///
  /// In en, this message translates to:
  /// **'The access key is your username for authenticating to the storage provider.'**
  String get theAccessKeyIsYourUsernameForAuthenticatingToTheStorageProvider;

  /// No description provided for @secretKey.
  ///
  /// In en, this message translates to:
  /// **'Secret key'**
  String get secretKey;

  /// No description provided for @theSecretKeyIsYourPasswordForAuthenticatingToTheStorageProvider.
  ///
  /// In en, this message translates to:
  /// **'The secret key is your password for authenticating to the storage provider.'**
  String get theSecretKeyIsYourPasswordForAuthenticatingToTheStorageProvider;

  /// No description provided for @vaultKey.
  ///
  /// In en, this message translates to:
  /// **'Vault key'**
  String get vaultKey;

  /// No description provided for @theVaultKeyIsTheEncryptionPasswordForDataUploadedToTheCloudItPreventsTheStorageProvid.
  ///
  /// In en, this message translates to:
  /// **'The vault key is the encryption password for data uploaded to the cloud. It prevents the storage provider from being able to read your data.'**
  String get theVaultKeyIsTheEncryptionPasswordForDataUploadedToTheCloudItPreventsTheStorageProvid;

  /// No description provided for @selectDiveSite.
  ///
  /// In en, this message translates to:
  /// **'Select dive site'**
  String get selectDiveSite;

  /// No description provided for @tags.
  ///
  /// In en, this message translates to:
  /// **'Tags:'**
  String get tags;

  /// No description provided for @diveDetails.
  ///
  /// In en, this message translates to:
  /// **'Dive details'**
  String get diveDetails;

  /// No description provided for @timesShownIn.
  ///
  /// In en, this message translates to:
  /// **'Times shown in {zoneAbbreviation}'**
  String timesShownIn(Object zoneAbbreviation);

  /// No description provided for @diveNumber.
  ///
  /// In en, this message translates to:
  /// **'Dive #{number}'**
  String diveNumber(Object number);

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @maxDepth.
  ///
  /// In en, this message translates to:
  /// **'Max depth'**
  String get maxDepth;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @rating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @defaultEquipmentUpdated.
  ///
  /// In en, this message translates to:
  /// **'Default equipment updated'**
  String get defaultEquipmentUpdated;

  /// No description provided for @addDefaults.
  ///
  /// In en, this message translates to:
  /// **'Add defaults'**
  String get addDefaults;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @selectEquipment.
  ///
  /// In en, this message translates to:
  /// **'Select equipment'**
  String get selectEquipment;

  /// No description provided for @noEquipmentAvailable.
  ///
  /// In en, this message translates to:
  /// **'No equipment available'**
  String get noEquipmentAvailable;

  /// No description provided for @usedThisDive.
  ///
  /// In en, this message translates to:
  /// **'Used this dive'**
  String get usedThisDive;

  /// No description provided for @availableEquipment.
  ///
  /// In en, this message translates to:
  /// **'Available equipment'**
  String get availableEquipment;

  /// No description provided for @dragEquipmentHere.
  ///
  /// In en, this message translates to:
  /// **'Drag equipment here'**
  String get dragEquipmentHere;

  /// No description provided for @noMoreEquipment.
  ///
  /// In en, this message translates to:
  /// **'No more equipment'**
  String get noMoreEquipment;

  /// No description provided for @gasChangeTime.
  ///
  /// In en, this message translates to:
  /// **'Gas change time'**
  String get gasChangeTime;

  /// No description provided for @cylinders.
  ///
  /// In en, this message translates to:
  /// **'Cylinders'**
  String get cylinders;

  /// No description provided for @cylinder.
  ///
  /// In en, this message translates to:
  /// **'Cylinder'**
  String get cylinder;

  /// No description provided for @cylinderWithId.
  ///
  /// In en, this message translates to:
  /// **'Cylinder {id}'**
  String cylinderWithId(Object id);

  /// No description provided for @removeCylinder.
  ///
  /// In en, this message translates to:
  /// **'Remove cylinder'**
  String get removeCylinder;

  /// No description provided for @oxygen.
  ///
  /// In en, this message translates to:
  /// **'Oxygen %'**
  String get oxygen;

  /// No description provided for @helium.
  ///
  /// In en, this message translates to:
  /// **'Helium %'**
  String get helium;

  /// No description provided for @startPressure.
  ///
  /// In en, this message translates to:
  /// **'Start pressure'**
  String get startPressure;

  /// No description provided for @endPressure.
  ///
  /// In en, this message translates to:
  /// **'End pressure'**
  String get endPressure;

  /// No description provided for @addCylinder.
  ///
  /// In en, this message translates to:
  /// **'Add cylinder'**
  String get addCylinder;

  /// No description provided for @noCylindersDefinedAddCylindersInEquipmentFirst.
  ///
  /// In en, this message translates to:
  /// **'No cylinders defined. Add cylinders in Equipment first.'**
  String get noCylindersDefinedAddCylindersInEquipmentFirst;

  /// No description provided for @gasChanges.
  ///
  /// In en, this message translates to:
  /// **'Gas changes'**
  String get gasChanges;

  /// No description provided for @startOfDive.
  ///
  /// In en, this message translates to:
  /// **'Start of dive'**
  String get startOfDive;

  /// No description provided for @switchToThisCylinder.
  ///
  /// In en, this message translates to:
  /// **'{time} switch to this cylinder'**
  String switchToThisCylinder(Object time);

  /// No description provided for @removeGasChange.
  ///
  /// In en, this message translates to:
  /// **'Remove gas change'**
  String get removeGasChange;

  /// No description provided for @addGasChange.
  ///
  /// In en, this message translates to:
  /// **'Add gas change'**
  String get addGasChange;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'Seconds'**
  String get seconds;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @waitABit.
  ///
  /// In en, this message translates to:
  /// **'Wait a bit'**
  String get waitABit;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @youCanFly.
  ///
  /// In en, this message translates to:
  /// **'You can fly'**
  String get youCanFly;

  /// No description provided for @diveCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dive} other{{count} dives}}'**
  String diveCount(int count);

  /// No description provided for @underwater.
  ///
  /// In en, this message translates to:
  /// **'{duration} underwater'**
  String underwater(Object duration);

  /// No description provided for @defaultEquipment.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultEquipment;

  /// No description provided for @archived.
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get archived;

  /// No description provided for @otherItems.
  ///
  /// In en, this message translates to:
  /// **'Others ({count})'**
  String otherItems(Object count);

  /// No description provided for @addTag.
  ///
  /// In en, this message translates to:
  /// **'Add tag'**
  String get addTag;

  /// No description provided for @unspecified.
  ///
  /// In en, this message translates to:
  /// **'Unspecified'**
  String get unspecified;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @vpm.
  ///
  /// In en, this message translates to:
  /// **'VPM {conservatism}'**
  String vpm(Object conservatism);

  /// No description provided for @rgbm.
  ///
  /// In en, this message translates to:
  /// **'RGBM {conservatism}'**
  String rgbm(Object conservatism);

  /// No description provided for @dciem.
  ///
  /// In en, this message translates to:
  /// **'DCIEM {conservatism}'**
  String dciem(Object conservatism);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @deco.
  ///
  /// In en, this message translates to:
  /// **'Starting at {depth}, TTS {time}'**
  String deco(Object time, Object depth);

  /// No description provided for @deepStop.
  ///
  /// In en, this message translates to:
  /// **'Deep stop {time} @ {depth}'**
  String deepStop(Object time, Object depth);

  /// No description provided for @safetyStop.
  ///
  /// In en, this message translates to:
  /// **'Safety stop {time} @ {depth}'**
  String safetyStop(Object time, Object depth);

  /// No description provided for @ndl.
  ///
  /// In en, this message translates to:
  /// **'{time} NDL'**
  String ndl(Object time);

  /// No description provided for @air.
  ///
  /// In en, this message translates to:
  /// **'Air'**
  String get air;

  /// No description provided for @weights.
  ///
  /// In en, this message translates to:
  /// **'Weights'**
  String get weights;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @addWeight.
  ///
  /// In en, this message translates to:
  /// **'Add weight'**
  String get addWeight;

  /// No description provided for @cylinderNumber.
  ///
  /// In en, this message translates to:
  /// **'Cylinder {number}'**
  String cylinderNumber(Object number);

  /// No description provided for @wp.
  ///
  /// In en, this message translates to:
  /// **'WP'**
  String get wp;

  /// No description provided for @mix.
  ///
  /// In en, this message translates to:
  /// **'Mix'**
  String get mix;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @sac.
  ///
  /// In en, this message translates to:
  /// **'SAC'**
  String get sac;

  /// No description provided for @backgas.
  ///
  /// In en, this message translates to:
  /// **'Backgas'**
  String get backgas;

  /// No description provided for @deepDeco.
  ///
  /// In en, this message translates to:
  /// **'Deep deco'**
  String get deepDeco;

  /// No description provided for @shallowDeco.
  ///
  /// In en, this message translates to:
  /// **'Shallow deco'**
  String get shallowDeco;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @anErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get anErrorOccurred;

  /// No description provided for @noDepthProfileDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No depth profile data available'**
  String get noDepthProfileDataAvailable;

  /// No description provided for @compCeil.
  ///
  /// In en, this message translates to:
  /// **'Comp ceil: '**
  String get compCeil;

  /// No description provided for @calcCeil.
  ///
  /// In en, this message translates to:
  /// **'Calc ceil: '**
  String get calcCeil;

  /// No description provided for @addNewDive.
  ///
  /// In en, this message translates to:
  /// **'Add new dive'**
  String get addNewDive;

  /// No description provided for @downloadFromComputer.
  ///
  /// In en, this message translates to:
  /// **'Download from computer'**
  String get downloadFromComputer;

  /// No description provided for @enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter manually'**
  String get enterManually;

  /// No description provided for @noDivesYetAddYourFirstDive.
  ///
  /// In en, this message translates to:
  /// **'No dives yet. Add your first dive!'**
  String get noDivesYetAddYourFirstDive;

  /// No description provided for @enterValidCoordinatesOrClearBothFields.
  ///
  /// In en, this message translates to:
  /// **'Enter valid coordinates, or clear both fields.'**
  String get enterValidCoordinatesOrClearBothFields;

  /// No description provided for @position.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get position;

  /// No description provided for @latitude.
  ///
  /// In en, this message translates to:
  /// **'Latitude'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In en, this message translates to:
  /// **'Longitude'**
  String get longitude;

  /// No description provided for @dive.
  ///
  /// In en, this message translates to:
  /// **'Dive '**
  String get dive;

  /// No description provided for @addGases.
  ///
  /// In en, this message translates to:
  /// **'Add gases'**
  String get addGases;

  /// No description provided for @addWeights.
  ///
  /// In en, this message translates to:
  /// **'Add weights'**
  String get addWeights;

  /// No description provided for @addEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add equipment'**
  String get addEquipment;

  /// No description provided for @mergeIntoPreviousDive.
  ///
  /// In en, this message translates to:
  /// **'Merge into previous dive'**
  String get mergeIntoPreviousDive;

  /// No description provided for @merge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get merge;

  /// No description provided for @deleteDive.
  ///
  /// In en, this message translates to:
  /// **'Delete dive'**
  String get deleteDive;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @viewRawData.
  ///
  /// In en, this message translates to:
  /// **'View raw data'**
  String get viewRawData;

  /// No description provided for @addSite.
  ///
  /// In en, this message translates to:
  /// **'Add site'**
  String get addSite;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @addBuddies.
  ///
  /// In en, this message translates to:
  /// **'Add buddies'**
  String get addBuddies;

  /// No description provided for @buddy.
  ///
  /// In en, this message translates to:
  /// **'Buddy'**
  String get buddy;

  /// No description provided for @addDivemaster.
  ///
  /// In en, this message translates to:
  /// **'Add divemaster'**
  String get addDivemaster;

  /// No description provided for @divemaster.
  ///
  /// In en, this message translates to:
  /// **'Divemaster'**
  String get divemaster;

  /// No description provided for @noDiveSitesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No dive sites available'**
  String get noDiveSitesAvailable;

  /// No description provided for @noSite.
  ///
  /// In en, this message translates to:
  /// **'No site'**
  String get noSite;

  /// No description provided for @buddies.
  ///
  /// In en, this message translates to:
  /// **'Buddies'**
  String get buddies;

  /// No description provided for @addBuddy.
  ///
  /// In en, this message translates to:
  /// **'Add buddy'**
  String get addBuddy;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add notes'**
  String get addNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @addTags.
  ///
  /// In en, this message translates to:
  /// **'Add tags'**
  String get addTags;

  /// No description provided for @addRating.
  ///
  /// In en, this message translates to:
  /// **'Add rating'**
  String get addRating;

  /// No description provided for @weightNumber.
  ///
  /// In en, this message translates to:
  /// **'Weight {number}'**
  String weightNumber(Object number);

  /// No description provided for @otu.
  ///
  /// In en, this message translates to:
  /// **'OTU'**
  String get otu;

  /// No description provided for @cns.
  ///
  /// In en, this message translates to:
  /// **'CNS'**
  String get cns;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get model;

  /// No description provided for @computer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// No description provided for @serial.
  ///
  /// In en, this message translates to:
  /// **'Serial'**
  String get serial;

  /// No description provided for @number.
  ///
  /// In en, this message translates to:
  /// **'Number'**
  String get number;

  /// No description provided for @meanDepth.
  ///
  /// In en, this message translates to:
  /// **'Mean depth'**
  String get meanDepth;

  /// No description provided for @viewFullscreen.
  ///
  /// In en, this message translates to:
  /// **'View fullscreen'**
  String get viewFullscreen;

  /// No description provided for @temp.
  ///
  /// In en, this message translates to:
  /// **'Temp'**
  String get temp;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @bodyOfWater.
  ///
  /// In en, this message translates to:
  /// **'Body of water'**
  String get bodyOfWater;

  /// No description provided for @sitePosition.
  ///
  /// In en, this message translates to:
  /// **'Site position'**
  String get sitePosition;

  /// No description provided for @diveStartPosition.
  ///
  /// In en, this message translates to:
  /// **'Dive start position'**
  String get diveStartPosition;

  /// No description provided for @diveEndPosition.
  ///
  /// In en, this message translates to:
  /// **'Dive end position'**
  String get diveEndPosition;

  /// No description provided for @volumeUsed.
  ///
  /// In en, this message translates to:
  /// **'Volume used'**
  String get volumeUsed;

  /// No description provided for @noLocationDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No location data available'**
  String get noLocationDataAvailable;

  /// No description provided for @newDiveSite.
  ///
  /// In en, this message translates to:
  /// **'New dive site'**
  String get newDiveSite;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @deleteSite.
  ///
  /// In en, this message translates to:
  /// **'Delete site'**
  String get deleteSite;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add location'**
  String get addLocation;

  /// No description provided for @diveSites.
  ///
  /// In en, this message translates to:
  /// **'Dive sites'**
  String get diveSites;

  /// No description provided for @viewAsMap.
  ///
  /// In en, this message translates to:
  /// **'View as map'**
  String get viewAsMap;

  /// No description provided for @addNewDiveSite.
  ///
  /// In en, this message translates to:
  /// **'Add new dive site'**
  String get addNewDiveSite;

  /// No description provided for @noDiveSitesYet.
  ///
  /// In en, this message translates to:
  /// **'No dive sites yet.'**
  String get noDiveSitesYet;

  /// No description provided for @siteMap.
  ///
  /// In en, this message translates to:
  /// **'Site map'**
  String get siteMap;

  /// No description provided for @noDivesToDisplay.
  ///
  /// In en, this message translates to:
  /// **'No dives to display'**
  String get noDivesToDisplay;

  /// No description provided for @noDivesMatchTheseFilters.
  ///
  /// In en, this message translates to:
  /// **'No dives match these filters.'**
  String get noDivesMatchTheseFilters;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @site.
  ///
  /// In en, this message translates to:
  /// **'Site'**
  String get site;

  /// No description provided for @year.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get year;

  /// No description provided for @allYears.
  ///
  /// In en, this message translates to:
  /// **'All years'**
  String get allYears;

  /// No description provided for @allCountries.
  ///
  /// In en, this message translates to:
  /// **'All countries'**
  String get allCountries;

  /// No description provided for @tag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get tag;

  /// No description provided for @allTags.
  ///
  /// In en, this message translates to:
  /// **'All tags'**
  String get allTags;

  /// No description provided for @noCountry.
  ///
  /// In en, this message translates to:
  /// **'No country'**
  String get noCountry;

  /// No description provided for @siteDetails.
  ///
  /// In en, this message translates to:
  /// **'Site details'**
  String get siteDetails;

  /// No description provided for @selectCountry.
  ///
  /// In en, this message translates to:
  /// **'Select country'**
  String get selectCountry;

  /// No description provided for @connectDiveComputer.
  ///
  /// In en, this message translates to:
  /// **'Connect dive computer'**
  String get connectDiveComputer;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// No description provided for @bluetoothIs.
  ///
  /// In en, this message translates to:
  /// **'{state, select, on{Bluetooth is on} off{Bluetooth is off} turningOn{Bluetooth is turning on} turningOff{Bluetooth is turning off} unauthorized{Bluetooth is unauthorized} unavailable{Bluetooth is unavailable} unknown{Bluetooth state is unknown} other{Bluetooth is {state}}}'**
  String bluetoothIs(String state);

  /// No description provided for @pleaseEnableBluetoothToScanForDiveComputers.
  ///
  /// In en, this message translates to:
  /// **'Please enable Bluetooth to scan for dive computers'**
  String get pleaseEnableBluetoothToScanForDiveComputers;

  /// No description provided for @turnOnBluetooth.
  ///
  /// In en, this message translates to:
  /// **'Turn on Bluetooth'**
  String get turnOnBluetooth;

  /// No description provided for @scanToFindYourDiveComputer.
  ///
  /// In en, this message translates to:
  /// **'Scan to find your dive computer'**
  String get scanToFindYourDiveComputer;

  /// No description provided for @knownDiveComputers.
  ///
  /// In en, this message translates to:
  /// **'Known dive computers'**
  String get knownDiveComputers;

  /// No description provided for @computersFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dive computer found} other{{count} dive computers found}}'**
  String computersFound(int count);

  /// No description provided for @makeSureYourDiveComputerIsInBluetoothCommunicationMode.
  ///
  /// In en, this message translates to:
  /// **'Make sure your dive computer is in Bluetooth communication mode'**
  String get makeSureYourDiveComputerIsInBluetoothCommunicationMode;

  /// No description provided for @otherDevicesFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 non-dive-computer device found} other{{count} non-dive-computer devices found}}'**
  String otherDevicesFound(int count);

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get showAll;

  /// No description provided for @download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get download;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status: {state, select, connected{connected} disconnected{disconnected} connecting{connecting} disconnecting{disconnecting} other{{state}}}'**
  String status(String state);

  /// No description provided for @discoveringServices.
  ///
  /// In en, this message translates to:
  /// **'Discovering services...'**
  String get discoveringServices;

  /// No description provided for @downloadDives.
  ///
  /// In en, this message translates to:
  /// **'Download dives'**
  String get downloadDives;

  /// No description provided for @loadingSupportedComputers.
  ///
  /// In en, this message translates to:
  /// **'Loading supported computers...'**
  String get loadingSupportedComputers;

  /// No description provided for @selectDiveComputer.
  ///
  /// In en, this message translates to:
  /// **'Select dive computer'**
  String get selectDiveComputer;

  /// No description provided for @suggestedFor.
  ///
  /// In en, this message translates to:
  /// **'Suggested for \"{deviceName}\":'**
  String suggestedFor(Object deviceName);

  /// No description provided for @showAllComputers.
  ///
  /// In en, this message translates to:
  /// **'Show all computers...'**
  String get showAllComputers;

  /// No description provided for @allBLEDiveComputers.
  ///
  /// In en, this message translates to:
  /// **'All BLE dive computers'**
  String get allBLEDiveComputers;

  /// No description provided for @divesDownloaded.
  ///
  /// In en, this message translates to:
  /// **', {count, plural, =1{1 dive downloaded} other{{count} dives downloaded}}'**
  String divesDownloaded(int count);

  /// No description provided for @downloadingDives.
  ///
  /// In en, this message translates to:
  /// **'Downloading dives...{downloadedLabel}'**
  String downloadingDives(Object downloadedLabel);

  /// No description provided for @excellent.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get excellent;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get good;

  /// No description provided for @fair.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get fair;

  /// No description provided for @weak.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get weak;

  /// No description provided for @certifications.
  ///
  /// In en, this message translates to:
  /// **'Certifications'**
  String get certifications;

  /// No description provided for @addNewCertification.
  ///
  /// In en, this message translates to:
  /// **'Add new certification'**
  String get addNewCertification;

  /// No description provided for @noCertificationsYetTapToAddOne.
  ///
  /// In en, this message translates to:
  /// **'No certifications yet. Tap + to add one.'**
  String get noCertificationsYetTapToAddOne;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @expiring.
  ///
  /// In en, this message translates to:
  /// **'Expiring'**
  String get expiring;

  /// No description provided for @certification.
  ///
  /// In en, this message translates to:
  /// **'Certification #{id}'**
  String certification(Object id);

  /// No description provided for @cylinderTypes.
  ///
  /// In en, this message translates to:
  /// **'Cylinder types'**
  String get cylinderTypes;

  /// No description provided for @addNewCylinderType.
  ///
  /// In en, this message translates to:
  /// **'Add new cylinder type'**
  String get addNewCylinderType;

  /// No description provided for @noCylinderTypesYetTapToAddOne.
  ///
  /// In en, this message translates to:
  /// **'No cylinder types yet. Tap + to add one.'**
  String get noCylinderTypesYetTapToAddOne;

  /// No description provided for @cylinderType.
  ///
  /// In en, this message translates to:
  /// **'Cylinder type #{id}'**
  String cylinderType(Object id);

  /// No description provided for @bcdsRegulatorsWetsuitsEtc.
  ///
  /// In en, this message translates to:
  /// **'BCDs, regulators, wetsuits, etc.'**
  String get bcdsRegulatorsWetsuitsEtc;

  /// No description provided for @availableCylinderTypesAndDefaults.
  ///
  /// In en, this message translates to:
  /// **'Available cylinder types and defaults'**
  String get availableCylinderTypesAndDefaults;

  /// No description provided for @diverCertificationCards.
  ///
  /// In en, this message translates to:
  /// **'Diver certification cards'**
  String get diverCertificationCards;

  /// No description provided for @otherEquipment.
  ///
  /// In en, this message translates to:
  /// **'Other Equipment'**
  String get otherEquipment;

  /// No description provided for @addNewEquipment.
  ///
  /// In en, this message translates to:
  /// **'Add new equipment'**
  String get addNewEquipment;

  /// No description provided for @noEquipmentYetTapToAddOne.
  ///
  /// In en, this message translates to:
  /// **'No equipment yet. Tap + to add one.'**
  String get noEquipmentYetTapToAddOne;

  /// No description provided for @showArchived.
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get showArchived;

  /// No description provided for @photoNotYetDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Photo not yet downloaded'**
  String get photoNotYetDownloaded;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @cardFront.
  ///
  /// In en, this message translates to:
  /// **'Card front'**
  String get cardFront;

  /// No description provided for @cardBack.
  ///
  /// In en, this message translates to:
  /// **'Card back'**
  String get cardBack;

  /// No description provided for @agency.
  ///
  /// In en, this message translates to:
  /// **'Agency'**
  String get agency;

  /// No description provided for @instructorName.
  ///
  /// In en, this message translates to:
  /// **'Instructor name'**
  String get instructorName;

  /// No description provided for @instructorNumber.
  ///
  /// In en, this message translates to:
  /// **'Instructor number'**
  String get instructorNumber;

  /// No description provided for @granted.
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get granted;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @deleteCertification.
  ///
  /// In en, this message translates to:
  /// **'Delete Certification'**
  String get deleteCertification;

  /// No description provided for @areYouSureYouWantToDeleteThisCertification.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this certification?'**
  String get areYouSureYouWantToDeleteThisCertification;

  /// No description provided for @failedToPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {details}'**
  String failedToPickImage(Object details);

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @newCertification.
  ///
  /// In en, this message translates to:
  /// **'New Certification'**
  String get newCertification;

  /// No description provided for @editCertification.
  ///
  /// In en, this message translates to:
  /// **'Edit Certification'**
  String get editCertification;

  /// No description provided for @discardChanges.
  ///
  /// In en, this message translates to:
  /// **'Discard changes'**
  String get discardChanges;

  /// No description provided for @certificationName.
  ///
  /// In en, this message translates to:
  /// **'Certification Name *'**
  String get certificationName;

  /// No description provided for @eGOpenWaterDiver.
  ///
  /// In en, this message translates to:
  /// **'e.g., Open Water Diver'**
  String get eGOpenWaterDiver;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @certificationNumber.
  ///
  /// In en, this message translates to:
  /// **'Certification Number *'**
  String get certificationNumber;

  /// No description provided for @eGPADISSI.
  ///
  /// In en, this message translates to:
  /// **'e.g., PADI, SSI'**
  String get eGPADISSI;

  /// No description provided for @replacePhoto.
  ///
  /// In en, this message translates to:
  /// **'Replace photo'**
  String get replacePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @deleteCylinderType.
  ///
  /// In en, this message translates to:
  /// **'Delete cylinder type'**
  String get deleteCylinderType;

  /// No description provided for @areYouSureYouWantToDeleteThisCylinderTypeThisCannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this cylinder type? This cannot be undone.'**
  String get areYouSureYouWantToDeleteThisCylinderTypeThisCannotBeUndone;

  /// No description provided for @newCylinderType.
  ///
  /// In en, this message translates to:
  /// **'New cylinder type'**
  String get newCylinderType;

  /// No description provided for @editCylinderType.
  ///
  /// In en, this message translates to:
  /// **'Edit cylinder type'**
  String get editCylinderType;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @eGAL8012x232.
  ///
  /// In en, this message translates to:
  /// **'e.g., AL80, 12x232'**
  String get eGAL8012x232;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @waterVolumeL.
  ///
  /// In en, this message translates to:
  /// **'Water volume (L)'**
  String get waterVolumeL;

  /// No description provided for @eG12.
  ///
  /// In en, this message translates to:
  /// **'e.g. 12'**
  String get eG12;

  /// No description provided for @workingPressureBar.
  ///
  /// In en, this message translates to:
  /// **'Working pressure (bar)'**
  String get workingPressureBar;

  /// No description provided for @eG232.
  ///
  /// In en, this message translates to:
  /// **'e.g. 232'**
  String get eG232;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @sizeCuft.
  ///
  /// In en, this message translates to:
  /// **'Size (cuft)'**
  String get sizeCuft;

  /// No description provided for @eG80.
  ///
  /// In en, this message translates to:
  /// **'e.g. 80'**
  String get eG80;

  /// No description provided for @workingPressurePsi.
  ///
  /// In en, this message translates to:
  /// **'Working pressure (psi)'**
  String get workingPressurePsi;

  /// No description provided for @eG3000.
  ///
  /// In en, this message translates to:
  /// **'e.g. 3000'**
  String get eG3000;

  /// No description provided for @defaultForImports.
  ///
  /// In en, this message translates to:
  /// **'Default for imports'**
  String get defaultForImports;

  /// No description provided for @useThisCylinderWhenImportingDivesWithoutCylinderTypeInfo.
  ///
  /// In en, this message translates to:
  /// **'Use this cylinder when importing dives without cylinder type info'**
  String get useThisCylinderWhenImportingDivesWithoutCylinderTypeInfo;

  /// No description provided for @backgas40O.
  ///
  /// In en, this message translates to:
  /// **'Backgas (<40% O₂)'**
  String get backgas40O;

  /// No description provided for @deepDeco4060O.
  ///
  /// In en, this message translates to:
  /// **'Deep deco (40-60% O₂)'**
  String get deepDeco4060O;

  /// No description provided for @shallowDeco60O.
  ///
  /// In en, this message translates to:
  /// **'Shallow deco (>60% O₂)'**
  String get shallowDeco60O;

  /// No description provided for @leaveDivesWithoutCylinderType.
  ///
  /// In en, this message translates to:
  /// **'Leave dives without cylinder type'**
  String get leaveDivesWithoutCylinderType;

  /// No description provided for @replaceWithAnotherCylinderType.
  ///
  /// In en, this message translates to:
  /// **'Replace with another cylinder type'**
  String get replaceWithAnotherCylinderType;

  /// No description provided for @noOtherCylinderTypesExistSoThoseDivesWillBeLeftWithoutACylinder.
  ///
  /// In en, this message translates to:
  /// **'No other cylinder types exist, so those dives will be left without a cylinder.'**
  String get noOtherCylinderTypesExistSoThoseDivesWillBeLeftWithoutACylinder;

  /// No description provided for @deleteEquipment.
  ///
  /// In en, this message translates to:
  /// **'Delete Equipment'**
  String get deleteEquipment;

  /// No description provided for @areYouSureYouWantToDeleteThisEquipment.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this equipment?'**
  String get areYouSureYouWantToDeleteThisEquipment;

  /// No description provided for @newEquipment.
  ///
  /// In en, this message translates to:
  /// **'New Equipment'**
  String get newEquipment;

  /// No description provided for @editEquipment.
  ///
  /// In en, this message translates to:
  /// **'Edit Equipment'**
  String get editEquipment;

  /// No description provided for @manufacturer.
  ///
  /// In en, this message translates to:
  /// **'Manufacturer'**
  String get manufacturer;

  /// No description provided for @modelName.
  ///
  /// In en, this message translates to:
  /// **'Model/Name'**
  String get modelName;

  /// No description provided for @serialNumber.
  ///
  /// In en, this message translates to:
  /// **'Serial Number'**
  String get serialNumber;

  /// No description provided for @purchasePrice.
  ///
  /// In en, this message translates to:
  /// **'Purchase Price'**
  String get purchasePrice;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @purchaseDate.
  ///
  /// In en, this message translates to:
  /// **'Purchase Date'**
  String get purchaseDate;

  /// No description provided for @warrantyUntil.
  ///
  /// In en, this message translates to:
  /// **'Warranty Until'**
  String get warrantyUntil;

  /// No description provided for @lastService.
  ///
  /// In en, this message translates to:
  /// **'Last Service'**
  String get lastService;

  /// No description provided for @addToNewDivesByDefault.
  ///
  /// In en, this message translates to:
  /// **'Add to new dives by default'**
  String get addToNewDivesByDefault;

  /// No description provided for @eGBCDRegulatorWetsuit.
  ///
  /// In en, this message translates to:
  /// **'e.g., BCD, Regulator, Wetsuit'**
  String get eGBCDRegulatorWetsuit;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Bubbletrail'**
  String get appTitle;

  /// No description provided for @mergeDiveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Dive #{number} will be merged into dive #{previousNumber}, appending its profile to that dive. Dive #{number} is then deleted. Continue?'**
  String mergeDiveConfirmation(int number, int previousNumber);

  /// No description provided for @resetDatabaseConfirmation.
  ///
  /// In en, this message translates to:
  /// **'This will remove all dives, sites, etc. in Bubbletrail and revert to an empty state. Syncing will be disabled, but synced data remains untouched in the cloud. Continue?'**
  String get resetDatabaseConfirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @unknownSite.
  ///
  /// In en, this message translates to:
  /// **'Unknown site'**
  String get unknownSite;

  /// No description provided for @diveTitle.
  ///
  /// In en, this message translates to:
  /// **'Dive #{number}: {site}'**
  String diveTitle(int number, String site);

  /// No description provided for @compactDiveTitle.
  ///
  /// In en, this message translates to:
  /// **'#{number}: {site}'**
  String compactDiveTitle(int number, String site);

  /// No description provided for @minutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesDuration(int minutes);

  /// No description provided for @hoursMinutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{hours, plural, =1{1 hour} other{{hours} hours}}, {minutes} min'**
  String hoursMinutesDuration(int hours, int minutes);

  /// No description provided for @daysHoursDuration.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}, {hours, plural, =1{1 hour} other{{hours} hours}}'**
  String daysHoursDuration(int days, int hours);

  /// No description provided for @daysHoursMinutesDuration.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{1 day} other{{days} days}}, {hours, plural, =1{1 hour} other{{hours} hours}}, {minutes} min'**
  String daysHoursMinutesDuration(int days, int hours, int minutes);

  /// No description provided for @monthlyDiveCount.
  ///
  /// In en, this message translates to:
  /// **'{month} {year}: {count, plural, =1{1 dive} other{{count} dives}}'**
  String monthlyDiveCount(String month, int year, int count);

  /// No description provided for @weightBackplate.
  ///
  /// In en, this message translates to:
  /// **'Backplate'**
  String get weightBackplate;

  /// No description provided for @weightBelt.
  ///
  /// In en, this message translates to:
  /// **'Belt'**
  String get weightBelt;

  /// No description provided for @weightHarness.
  ///
  /// In en, this message translates to:
  /// **'Harness'**
  String get weightHarness;

  /// No description provided for @weightIntegrated.
  ///
  /// In en, this message translates to:
  /// **'Integrated'**
  String get weightIntegrated;

  /// No description provided for @weightTrim.
  ///
  /// In en, this message translates to:
  /// **'Trim'**
  String get weightTrim;

  /// No description provided for @noLocation.
  ///
  /// In en, this message translates to:
  /// **'No location'**
  String get noLocation;

  /// No description provided for @equipmentNotFound.
  ///
  /// In en, this message translates to:
  /// **'Equipment not found'**
  String get equipmentNotFound;

  /// No description provided for @loadEquipmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load equipment details: {details}'**
  String loadEquipmentFailed(String details);

  /// No description provided for @updateEquipmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update equipment: {details}'**
  String updateEquipmentFailed(String details);

  /// No description provided for @deleteEquipmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete equipment: {details}'**
  String deleteEquipmentFailed(String details);

  /// No description provided for @certificationNotFound.
  ///
  /// In en, this message translates to:
  /// **'Certification not found'**
  String get certificationNotFound;

  /// No description provided for @loadCertificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load certification details: {details}'**
  String loadCertificationFailed(String details);

  /// No description provided for @updateCertificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update certification: {details}'**
  String updateCertificationFailed(String details);

  /// No description provided for @deleteCertificationFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete certification: {details}'**
  String deleteCertificationFailed(String details);

  /// No description provided for @cylinderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Cylinder not found'**
  String get cylinderNotFound;

  /// No description provided for @loadCylinderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load cylinder details: {details}'**
  String loadCylinderFailed(String details);

  /// No description provided for @updateCylinderFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update cylinder: {details}'**
  String updateCylinderFailed(String details);

  /// No description provided for @connectFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect: {details}'**
  String connectFailed(String details);

  /// No description provided for @noServicesDiscovered.
  ///
  /// In en, this message translates to:
  /// **'No services discovered'**
  String get noServicesDiscovered;

  /// No description provided for @noBleCharacteristics.
  ///
  /// In en, this message translates to:
  /// **'No suitable BLE characteristics found'**
  String get noBleCharacteristics;

  /// No description provided for @notificationsFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to enable notifications: {details}'**
  String notificationsFailed(String details);

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download exception: {details}'**
  String downloadFailed(String details);

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @cylinderTypeWithId.
  ///
  /// In en, this message translates to:
  /// **'Cylinder type {id}'**
  String cylinderTypeWithId(String id);

  /// No description provided for @equipmentBcd.
  ///
  /// In en, this message translates to:
  /// **'BCD'**
  String get equipmentBcd;

  /// No description provided for @equipmentRegulator.
  ///
  /// In en, this message translates to:
  /// **'Regulator'**
  String get equipmentRegulator;

  /// No description provided for @equipmentWetsuit.
  ///
  /// In en, this message translates to:
  /// **'Wetsuit'**
  String get equipmentWetsuit;

  /// No description provided for @equipmentDrysuit.
  ///
  /// In en, this message translates to:
  /// **'Drysuit'**
  String get equipmentDrysuit;

  /// No description provided for @equipmentMask.
  ///
  /// In en, this message translates to:
  /// **'Mask'**
  String get equipmentMask;

  /// No description provided for @equipmentFins.
  ///
  /// In en, this message translates to:
  /// **'Fins'**
  String get equipmentFins;

  /// No description provided for @equipmentComputer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get equipmentComputer;

  /// No description provided for @equipmentLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get equipmentLight;

  /// No description provided for @equipmentCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get equipmentCamera;

  /// No description provided for @equipmentSmb.
  ///
  /// In en, this message translates to:
  /// **'SMB'**
  String get equipmentSmb;

  /// No description provided for @equipmentReel.
  ///
  /// In en, this message translates to:
  /// **'Reel'**
  String get equipmentReel;

  /// No description provided for @equipmentWeightBelt.
  ///
  /// In en, this message translates to:
  /// **'Weight belt'**
  String get equipmentWeightBelt;

  /// No description provided for @equipmentHood.
  ///
  /// In en, this message translates to:
  /// **'Hood'**
  String get equipmentHood;

  /// No description provided for @equipmentGloves.
  ///
  /// In en, this message translates to:
  /// **'Gloves'**
  String get equipmentGloves;

  /// No description provided for @equipmentBoots.
  ///
  /// In en, this message translates to:
  /// **'Boots'**
  String get equipmentBoots;

  /// No description provided for @equipmentOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get equipmentOther;

  /// No description provided for @measurement.
  ///
  /// In en, this message translates to:
  /// **'{value} {unit}'**
  String measurement(String value, String unit);

  /// No description provided for @perMinute.
  ///
  /// In en, this message translates to:
  /// **'/min'**
  String get perMinute;

  /// No description provided for @ratePerMinute.
  ///
  /// In en, this message translates to:
  /// **'{value}/min'**
  String ratePerMinute(String value);

  /// No description provided for @trimix.
  ///
  /// In en, this message translates to:
  /// **'Tx{oxygen}/{helium}'**
  String trimix(int oxygen, int helium);

  /// No description provided for @nitrox.
  ///
  /// In en, this message translates to:
  /// **'EAN{oxygen}'**
  String nitrox(int oxygen);

  /// No description provided for @syncingSection.
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncingSection;

  /// No description provided for @equipmentWithId.
  ///
  /// In en, this message translates to:
  /// **'Equipment #{id}'**
  String equipmentWithId(Object id);

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsLabel;

  /// No description provided for @buhlmannGradientFactors.
  ///
  /// In en, this message translates to:
  /// **'Bühlmann GF {gfLow}/{gfHigh}'**
  String buhlmannGradientFactors(Object gfLow, Object gfHigh);

  /// No description provided for @buhlmann.
  ///
  /// In en, this message translates to:
  /// **'Bühlmann'**
  String get buhlmann;

  /// No description provided for @durationRange.
  ///
  /// In en, this message translates to:
  /// **'0 - {maximumMinutes} min'**
  String durationRange(Object maximumMinutes);

  /// No description provided for @surfaceGradientFactorValue.
  ///
  /// In en, this message translates to:
  /// **'SurfGF: {percent}%'**
  String surfaceGradientFactorValue(Object percent);

  /// No description provided for @surfaceGradientFactor.
  ///
  /// In en, this message translates to:
  /// **'SurfGF'**
  String get surfaceGradientFactor;

  /// No description provided for @percentage.
  ///
  /// In en, this message translates to:
  /// **'{value}%'**
  String percentage(Object value);

  /// No description provided for @decoLabel.
  ///
  /// In en, this message translates to:
  /// **'Deco'**
  String get decoLabel;

  /// No description provided for @bodyOfWaterTitle.
  ///
  /// In en, this message translates to:
  /// **'Body of Water'**
  String get bodyOfWaterTitle;

  /// No description provided for @diveCountColumn.
  ///
  /// In en, this message translates to:
  /// **'# Dives'**
  String get diveCountColumn;

  /// No description provided for @diveNumberColumn.
  ///
  /// In en, this message translates to:
  /// **'Dive #'**
  String get diveNumberColumn;

  /// No description provided for @requiredName.
  ///
  /// In en, this message translates to:
  /// **'Name *'**
  String get requiredName;

  /// No description provided for @downloadingDivesProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading dives... {percent}%{downloadedLabel}'**
  String downloadingDivesProgress(Object percent, Object downloadedLabel);

  /// No description provided for @certificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Certification'**
  String get certificationTitle;

  /// No description provided for @deleteCertificationAction.
  ///
  /// In en, this message translates to:
  /// **'Delete certification'**
  String get deleteCertificationAction;

  /// No description provided for @instructorNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructor Name'**
  String get instructorNameTitle;

  /// No description provided for @instructorNumberTitle.
  ///
  /// In en, this message translates to:
  /// **'Instructor Number'**
  String get instructorNumberTitle;

  /// No description provided for @requiredAgency.
  ///
  /// In en, this message translates to:
  /// **'Agency *'**
  String get requiredAgency;

  /// No description provided for @cylinderTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Cylinder type'**
  String get cylinderTypeLabel;

  /// No description provided for @deleteEquipmentAction.
  ///
  /// In en, this message translates to:
  /// **'Delete equipment'**
  String get deleteEquipmentAction;

  /// No description provided for @dateExampleEuropean.
  ///
  /// In en, this message translates to:
  /// **'25/12/2024'**
  String get dateExampleEuropean;

  /// No description provided for @dateExampleIso.
  ///
  /// In en, this message translates to:
  /// **'2024-12-25'**
  String get dateExampleIso;

  /// No description provided for @dateExampleUs.
  ///
  /// In en, this message translates to:
  /// **'12/25/2024'**
  String get dateExampleUs;

  /// No description provided for @timeFormat24Hour.
  ///
  /// In en, this message translates to:
  /// **'24h'**
  String get timeFormat24Hour;

  /// No description provided for @timeFormat12Hour.
  ///
  /// In en, this message translates to:
  /// **'12h'**
  String get timeFormat12Hour;

  /// No description provided for @signalStrength.
  ///
  /// In en, this message translates to:
  /// **'{strength} ({rssi} dBm)'**
  String signalStrength(Object strength, Object rssi);

  /// No description provided for @noFlyWaitExplanation.
  ///
  /// In en, this message translates to:
  /// **'Wait {waitHours} hours, then your gradient factor at flight level will be {waitFlightGF}%. Right now, if teleported to 8000 ft, your GF would be {curFlightGF}%.'**
  String noFlyWaitExplanation(Object waitHours, Object waitFlightGF, Object curFlightGF);

  /// No description provided for @noFlySafeExplanation.
  ///
  /// In en, this message translates to:
  /// **'Your gradient factor at flight level will be {gf}%, which is likely safe.'**
  String noFlySafeExplanation(Object gf);

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Bubbletrail {appVer} ({gitVer})'**
  String appVersion(Object appVer, Object gitVer);

  /// No description provided for @deleteDiveConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete dive #{number}? This cannot be undone.'**
  String deleteDiveConfirmation(Object number);

  /// No description provided for @deleteSiteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete the site {name}? Dives using this site will be left without site. This cannot be undone.'**
  String deleteSiteConfirmation(Object name);

  /// No description provided for @deviceDownloadFailed.
  ///
  /// In en, this message translates to:
  /// **'{details}'**
  String deviceDownloadFailed(String details);

  /// No description provided for @cylinderReplacementPrompt.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 dive uses this cylinder type. What should that dive use instead?} other{{count} dives use this cylinder type. What should those dives use instead?}}'**
  String cylinderReplacementPrompt(int count);

  /// No description provided for @countryAD.
  ///
  /// In en, this message translates to:
  /// **'Andorra'**
  String get countryAD;

  /// No description provided for @countryAE.
  ///
  /// In en, this message translates to:
  /// **'United Arab Emirates'**
  String get countryAE;

  /// No description provided for @countryAF.
  ///
  /// In en, this message translates to:
  /// **'Afghanistan'**
  String get countryAF;

  /// No description provided for @countryAG.
  ///
  /// In en, this message translates to:
  /// **'Antigua and Barbuda'**
  String get countryAG;

  /// No description provided for @countryAI.
  ///
  /// In en, this message translates to:
  /// **'Anguilla'**
  String get countryAI;

  /// No description provided for @countryAL.
  ///
  /// In en, this message translates to:
  /// **'Albania'**
  String get countryAL;

  /// No description provided for @countryAM.
  ///
  /// In en, this message translates to:
  /// **'Armenia'**
  String get countryAM;

  /// No description provided for @countryAO.
  ///
  /// In en, this message translates to:
  /// **'Angola'**
  String get countryAO;

  /// No description provided for @countryAQ.
  ///
  /// In en, this message translates to:
  /// **'Antarctica'**
  String get countryAQ;

  /// No description provided for @countryAR.
  ///
  /// In en, this message translates to:
  /// **'Argentina'**
  String get countryAR;

  /// No description provided for @countryAS.
  ///
  /// In en, this message translates to:
  /// **'American Samoa'**
  String get countryAS;

  /// No description provided for @countryAT.
  ///
  /// In en, this message translates to:
  /// **'Austria'**
  String get countryAT;

  /// No description provided for @countryAU.
  ///
  /// In en, this message translates to:
  /// **'Australia'**
  String get countryAU;

  /// No description provided for @countryAW.
  ///
  /// In en, this message translates to:
  /// **'Aruba'**
  String get countryAW;

  /// No description provided for @countryAX.
  ///
  /// In en, this message translates to:
  /// **'Åland Islands'**
  String get countryAX;

  /// No description provided for @countryAZ.
  ///
  /// In en, this message translates to:
  /// **'Azerbaijan'**
  String get countryAZ;

  /// No description provided for @countryBA.
  ///
  /// In en, this message translates to:
  /// **'Bosnia and Herzegovina'**
  String get countryBA;

  /// No description provided for @countryBB.
  ///
  /// In en, this message translates to:
  /// **'Barbados'**
  String get countryBB;

  /// No description provided for @countryBD.
  ///
  /// In en, this message translates to:
  /// **'Bangladesh'**
  String get countryBD;

  /// No description provided for @countryBE.
  ///
  /// In en, this message translates to:
  /// **'Belgium'**
  String get countryBE;

  /// No description provided for @countryBF.
  ///
  /// In en, this message translates to:
  /// **'Burkina Faso'**
  String get countryBF;

  /// No description provided for @countryBG.
  ///
  /// In en, this message translates to:
  /// **'Bulgaria'**
  String get countryBG;

  /// No description provided for @countryBH.
  ///
  /// In en, this message translates to:
  /// **'Bahrain'**
  String get countryBH;

  /// No description provided for @countryBI.
  ///
  /// In en, this message translates to:
  /// **'Burundi'**
  String get countryBI;

  /// No description provided for @countryBJ.
  ///
  /// In en, this message translates to:
  /// **'Benin'**
  String get countryBJ;

  /// No description provided for @countryBL.
  ///
  /// In en, this message translates to:
  /// **'Saint Barthélemy'**
  String get countryBL;

  /// No description provided for @countryBM.
  ///
  /// In en, this message translates to:
  /// **'Bermuda'**
  String get countryBM;

  /// No description provided for @countryBN.
  ///
  /// In en, this message translates to:
  /// **'Brunei'**
  String get countryBN;

  /// No description provided for @countryBO.
  ///
  /// In en, this message translates to:
  /// **'Bolivia'**
  String get countryBO;

  /// No description provided for @countryBQ.
  ///
  /// In en, this message translates to:
  /// **'Caribbean Netherlands'**
  String get countryBQ;

  /// No description provided for @countryBR.
  ///
  /// In en, this message translates to:
  /// **'Brazil'**
  String get countryBR;

  /// No description provided for @countryBS.
  ///
  /// In en, this message translates to:
  /// **'Bahamas'**
  String get countryBS;

  /// No description provided for @countryBT.
  ///
  /// In en, this message translates to:
  /// **'Bhutan'**
  String get countryBT;

  /// No description provided for @countryBV.
  ///
  /// In en, this message translates to:
  /// **'Bouvet Island'**
  String get countryBV;

  /// No description provided for @countryBW.
  ///
  /// In en, this message translates to:
  /// **'Botswana'**
  String get countryBW;

  /// No description provided for @countryBY.
  ///
  /// In en, this message translates to:
  /// **'Belarus'**
  String get countryBY;

  /// No description provided for @countryBZ.
  ///
  /// In en, this message translates to:
  /// **'Belize'**
  String get countryBZ;

  /// No description provided for @countryCA.
  ///
  /// In en, this message translates to:
  /// **'Canada'**
  String get countryCA;

  /// No description provided for @countryCC.
  ///
  /// In en, this message translates to:
  /// **'Cocos (Keeling) Islands'**
  String get countryCC;

  /// No description provided for @countryCD.
  ///
  /// In en, this message translates to:
  /// **'DR Congo'**
  String get countryCD;

  /// No description provided for @countryCF.
  ///
  /// In en, this message translates to:
  /// **'Central African Republic'**
  String get countryCF;

  /// No description provided for @countryCG.
  ///
  /// In en, this message translates to:
  /// **'Republic of the Congo'**
  String get countryCG;

  /// No description provided for @countryCH.
  ///
  /// In en, this message translates to:
  /// **'Switzerland'**
  String get countryCH;

  /// No description provided for @countryCI.
  ///
  /// In en, this message translates to:
  /// **'Ivory Coast'**
  String get countryCI;

  /// No description provided for @countryCK.
  ///
  /// In en, this message translates to:
  /// **'Cook Islands'**
  String get countryCK;

  /// No description provided for @countryCL.
  ///
  /// In en, this message translates to:
  /// **'Chile'**
  String get countryCL;

  /// No description provided for @countryCM.
  ///
  /// In en, this message translates to:
  /// **'Cameroon'**
  String get countryCM;

  /// No description provided for @countryCN.
  ///
  /// In en, this message translates to:
  /// **'China'**
  String get countryCN;

  /// No description provided for @countryCO.
  ///
  /// In en, this message translates to:
  /// **'Colombia'**
  String get countryCO;

  /// No description provided for @countryCR.
  ///
  /// In en, this message translates to:
  /// **'Costa Rica'**
  String get countryCR;

  /// No description provided for @countryCU.
  ///
  /// In en, this message translates to:
  /// **'Cuba'**
  String get countryCU;

  /// No description provided for @countryCV.
  ///
  /// In en, this message translates to:
  /// **'Cape Verde'**
  String get countryCV;

  /// No description provided for @countryCW.
  ///
  /// In en, this message translates to:
  /// **'Curaçao'**
  String get countryCW;

  /// No description provided for @countryCX.
  ///
  /// In en, this message translates to:
  /// **'Christmas Island'**
  String get countryCX;

  /// No description provided for @countryCY.
  ///
  /// In en, this message translates to:
  /// **'Cyprus'**
  String get countryCY;

  /// No description provided for @countryCZ.
  ///
  /// In en, this message translates to:
  /// **'Czechia'**
  String get countryCZ;

  /// No description provided for @countryDE.
  ///
  /// In en, this message translates to:
  /// **'Germany'**
  String get countryDE;

  /// No description provided for @countryDJ.
  ///
  /// In en, this message translates to:
  /// **'Djibouti'**
  String get countryDJ;

  /// No description provided for @countryDK.
  ///
  /// In en, this message translates to:
  /// **'Denmark'**
  String get countryDK;

  /// No description provided for @countryDM.
  ///
  /// In en, this message translates to:
  /// **'Dominica'**
  String get countryDM;

  /// No description provided for @countryDO.
  ///
  /// In en, this message translates to:
  /// **'Dominican Republic'**
  String get countryDO;

  /// No description provided for @countryDZ.
  ///
  /// In en, this message translates to:
  /// **'Algeria'**
  String get countryDZ;

  /// No description provided for @countryEC.
  ///
  /// In en, this message translates to:
  /// **'Ecuador'**
  String get countryEC;

  /// No description provided for @countryEE.
  ///
  /// In en, this message translates to:
  /// **'Estonia'**
  String get countryEE;

  /// No description provided for @countryEG.
  ///
  /// In en, this message translates to:
  /// **'Egypt'**
  String get countryEG;

  /// No description provided for @countryEH.
  ///
  /// In en, this message translates to:
  /// **'Western Sahara'**
  String get countryEH;

  /// No description provided for @countryER.
  ///
  /// In en, this message translates to:
  /// **'Eritrea'**
  String get countryER;

  /// No description provided for @countryES.
  ///
  /// In en, this message translates to:
  /// **'Spain'**
  String get countryES;

  /// No description provided for @countryET.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get countryET;

  /// No description provided for @countryFI.
  ///
  /// In en, this message translates to:
  /// **'Finland'**
  String get countryFI;

  /// No description provided for @countryFJ.
  ///
  /// In en, this message translates to:
  /// **'Fiji'**
  String get countryFJ;

  /// No description provided for @countryFK.
  ///
  /// In en, this message translates to:
  /// **'Falkland Islands'**
  String get countryFK;

  /// No description provided for @countryFM.
  ///
  /// In en, this message translates to:
  /// **'Micronesia'**
  String get countryFM;

  /// No description provided for @countryFO.
  ///
  /// In en, this message translates to:
  /// **'Faroe Islands'**
  String get countryFO;

  /// No description provided for @countryFR.
  ///
  /// In en, this message translates to:
  /// **'France'**
  String get countryFR;

  /// No description provided for @countryGA.
  ///
  /// In en, this message translates to:
  /// **'Gabon'**
  String get countryGA;

  /// No description provided for @countryGB.
  ///
  /// In en, this message translates to:
  /// **'United Kingdom'**
  String get countryGB;

  /// No description provided for @countryGD.
  ///
  /// In en, this message translates to:
  /// **'Grenada'**
  String get countryGD;

  /// No description provided for @countryGE.
  ///
  /// In en, this message translates to:
  /// **'Georgia'**
  String get countryGE;

  /// No description provided for @countryGF.
  ///
  /// In en, this message translates to:
  /// **'French Guiana'**
  String get countryGF;

  /// No description provided for @countryGG.
  ///
  /// In en, this message translates to:
  /// **'Guernsey'**
  String get countryGG;

  /// No description provided for @countryGH.
  ///
  /// In en, this message translates to:
  /// **'Ghana'**
  String get countryGH;

  /// No description provided for @countryGI.
  ///
  /// In en, this message translates to:
  /// **'Gibraltar'**
  String get countryGI;

  /// No description provided for @countryGL.
  ///
  /// In en, this message translates to:
  /// **'Greenland'**
  String get countryGL;

  /// No description provided for @countryGM.
  ///
  /// In en, this message translates to:
  /// **'Gambia'**
  String get countryGM;

  /// No description provided for @countryGN.
  ///
  /// In en, this message translates to:
  /// **'Guinea'**
  String get countryGN;

  /// No description provided for @countryGP.
  ///
  /// In en, this message translates to:
  /// **'Guadeloupe'**
  String get countryGP;

  /// No description provided for @countryGQ.
  ///
  /// In en, this message translates to:
  /// **'Equatorial Guinea'**
  String get countryGQ;

  /// No description provided for @countryGR.
  ///
  /// In en, this message translates to:
  /// **'Greece'**
  String get countryGR;

  /// No description provided for @countryGS.
  ///
  /// In en, this message translates to:
  /// **'South Georgia'**
  String get countryGS;

  /// No description provided for @countryGT.
  ///
  /// In en, this message translates to:
  /// **'Guatemala'**
  String get countryGT;

  /// No description provided for @countryGU.
  ///
  /// In en, this message translates to:
  /// **'Guam'**
  String get countryGU;

  /// No description provided for @countryGW.
  ///
  /// In en, this message translates to:
  /// **'Guinea-Bissau'**
  String get countryGW;

  /// No description provided for @countryGY.
  ///
  /// In en, this message translates to:
  /// **'Guyana'**
  String get countryGY;

  /// No description provided for @countryHK.
  ///
  /// In en, this message translates to:
  /// **'Hong Kong'**
  String get countryHK;

  /// No description provided for @countryHM.
  ///
  /// In en, this message translates to:
  /// **'Heard Island and McDonald Islands'**
  String get countryHM;

  /// No description provided for @countryHN.
  ///
  /// In en, this message translates to:
  /// **'Honduras'**
  String get countryHN;

  /// No description provided for @countryHR.
  ///
  /// In en, this message translates to:
  /// **'Croatia'**
  String get countryHR;

  /// No description provided for @countryHT.
  ///
  /// In en, this message translates to:
  /// **'Haiti'**
  String get countryHT;

  /// No description provided for @countryHU.
  ///
  /// In en, this message translates to:
  /// **'Hungary'**
  String get countryHU;

  /// No description provided for @countryID.
  ///
  /// In en, this message translates to:
  /// **'Indonesia'**
  String get countryID;

  /// No description provided for @countryIE.
  ///
  /// In en, this message translates to:
  /// **'Ireland'**
  String get countryIE;

  /// No description provided for @countryIL.
  ///
  /// In en, this message translates to:
  /// **'Israel'**
  String get countryIL;

  /// No description provided for @countryIM.
  ///
  /// In en, this message translates to:
  /// **'Isle of Man'**
  String get countryIM;

  /// No description provided for @countryIN.
  ///
  /// In en, this message translates to:
  /// **'India'**
  String get countryIN;

  /// No description provided for @countryIO.
  ///
  /// In en, this message translates to:
  /// **'British Indian Ocean Territory'**
  String get countryIO;

  /// No description provided for @countryIQ.
  ///
  /// In en, this message translates to:
  /// **'Iraq'**
  String get countryIQ;

  /// No description provided for @countryIR.
  ///
  /// In en, this message translates to:
  /// **'Iran'**
  String get countryIR;

  /// No description provided for @countryIS.
  ///
  /// In en, this message translates to:
  /// **'Iceland'**
  String get countryIS;

  /// No description provided for @countryIT.
  ///
  /// In en, this message translates to:
  /// **'Italy'**
  String get countryIT;

  /// No description provided for @countryJE.
  ///
  /// In en, this message translates to:
  /// **'Jersey'**
  String get countryJE;

  /// No description provided for @countryJM.
  ///
  /// In en, this message translates to:
  /// **'Jamaica'**
  String get countryJM;

  /// No description provided for @countryJO.
  ///
  /// In en, this message translates to:
  /// **'Jordan'**
  String get countryJO;

  /// No description provided for @countryJP.
  ///
  /// In en, this message translates to:
  /// **'Japan'**
  String get countryJP;

  /// No description provided for @countryKE.
  ///
  /// In en, this message translates to:
  /// **'Kenya'**
  String get countryKE;

  /// No description provided for @countryKG.
  ///
  /// In en, this message translates to:
  /// **'Kyrgyzstan'**
  String get countryKG;

  /// No description provided for @countryKH.
  ///
  /// In en, this message translates to:
  /// **'Cambodia'**
  String get countryKH;

  /// No description provided for @countryKI.
  ///
  /// In en, this message translates to:
  /// **'Kiribati'**
  String get countryKI;

  /// No description provided for @countryKM.
  ///
  /// In en, this message translates to:
  /// **'Comoros'**
  String get countryKM;

  /// No description provided for @countryKN.
  ///
  /// In en, this message translates to:
  /// **'Saint Kitts and Nevis'**
  String get countryKN;

  /// No description provided for @countryKP.
  ///
  /// In en, this message translates to:
  /// **'North Korea'**
  String get countryKP;

  /// No description provided for @countryKR.
  ///
  /// In en, this message translates to:
  /// **'South Korea'**
  String get countryKR;

  /// No description provided for @countryKW.
  ///
  /// In en, this message translates to:
  /// **'Kuwait'**
  String get countryKW;

  /// No description provided for @countryKY.
  ///
  /// In en, this message translates to:
  /// **'Cayman Islands'**
  String get countryKY;

  /// No description provided for @countryKZ.
  ///
  /// In en, this message translates to:
  /// **'Kazakhstan'**
  String get countryKZ;

  /// No description provided for @countryLA.
  ///
  /// In en, this message translates to:
  /// **'Laos'**
  String get countryLA;

  /// No description provided for @countryLB.
  ///
  /// In en, this message translates to:
  /// **'Lebanon'**
  String get countryLB;

  /// No description provided for @countryLC.
  ///
  /// In en, this message translates to:
  /// **'Saint Lucia'**
  String get countryLC;

  /// No description provided for @countryLI.
  ///
  /// In en, this message translates to:
  /// **'Liechtenstein'**
  String get countryLI;

  /// No description provided for @countryLK.
  ///
  /// In en, this message translates to:
  /// **'Sri Lanka'**
  String get countryLK;

  /// No description provided for @countryLR.
  ///
  /// In en, this message translates to:
  /// **'Liberia'**
  String get countryLR;

  /// No description provided for @countryLS.
  ///
  /// In en, this message translates to:
  /// **'Lesotho'**
  String get countryLS;

  /// No description provided for @countryLT.
  ///
  /// In en, this message translates to:
  /// **'Lithuania'**
  String get countryLT;

  /// No description provided for @countryLU.
  ///
  /// In en, this message translates to:
  /// **'Luxembourg'**
  String get countryLU;

  /// No description provided for @countryLV.
  ///
  /// In en, this message translates to:
  /// **'Latvia'**
  String get countryLV;

  /// No description provided for @countryLY.
  ///
  /// In en, this message translates to:
  /// **'Libya'**
  String get countryLY;

  /// No description provided for @countryMA.
  ///
  /// In en, this message translates to:
  /// **'Morocco'**
  String get countryMA;

  /// No description provided for @countryMC.
  ///
  /// In en, this message translates to:
  /// **'Monaco'**
  String get countryMC;

  /// No description provided for @countryMD.
  ///
  /// In en, this message translates to:
  /// **'Moldova'**
  String get countryMD;

  /// No description provided for @countryME.
  ///
  /// In en, this message translates to:
  /// **'Montenegro'**
  String get countryME;

  /// No description provided for @countryMF.
  ///
  /// In en, this message translates to:
  /// **'Saint Martin'**
  String get countryMF;

  /// No description provided for @countryMG.
  ///
  /// In en, this message translates to:
  /// **'Madagascar'**
  String get countryMG;

  /// No description provided for @countryMH.
  ///
  /// In en, this message translates to:
  /// **'Marshall Islands'**
  String get countryMH;

  /// No description provided for @countryMK.
  ///
  /// In en, this message translates to:
  /// **'North Macedonia'**
  String get countryMK;

  /// No description provided for @countryML.
  ///
  /// In en, this message translates to:
  /// **'Mali'**
  String get countryML;

  /// No description provided for @countryMM.
  ///
  /// In en, this message translates to:
  /// **'Myanmar'**
  String get countryMM;

  /// No description provided for @countryMN.
  ///
  /// In en, this message translates to:
  /// **'Mongolia'**
  String get countryMN;

  /// No description provided for @countryMO.
  ///
  /// In en, this message translates to:
  /// **'Macau'**
  String get countryMO;

  /// No description provided for @countryMP.
  ///
  /// In en, this message translates to:
  /// **'Northern Mariana Islands'**
  String get countryMP;

  /// No description provided for @countryMQ.
  ///
  /// In en, this message translates to:
  /// **'Martinique'**
  String get countryMQ;

  /// No description provided for @countryMR.
  ///
  /// In en, this message translates to:
  /// **'Mauritania'**
  String get countryMR;

  /// No description provided for @countryMS.
  ///
  /// In en, this message translates to:
  /// **'Montserrat'**
  String get countryMS;

  /// No description provided for @countryMT.
  ///
  /// In en, this message translates to:
  /// **'Malta'**
  String get countryMT;

  /// No description provided for @countryMU.
  ///
  /// In en, this message translates to:
  /// **'Mauritius'**
  String get countryMU;

  /// No description provided for @countryMV.
  ///
  /// In en, this message translates to:
  /// **'Maldives'**
  String get countryMV;

  /// No description provided for @countryMW.
  ///
  /// In en, this message translates to:
  /// **'Malawi'**
  String get countryMW;

  /// No description provided for @countryMX.
  ///
  /// In en, this message translates to:
  /// **'Mexico'**
  String get countryMX;

  /// No description provided for @countryMY.
  ///
  /// In en, this message translates to:
  /// **'Malaysia'**
  String get countryMY;

  /// No description provided for @countryMZ.
  ///
  /// In en, this message translates to:
  /// **'Mozambique'**
  String get countryMZ;

  /// No description provided for @countryNA.
  ///
  /// In en, this message translates to:
  /// **'Namibia'**
  String get countryNA;

  /// No description provided for @countryNC.
  ///
  /// In en, this message translates to:
  /// **'New Caledonia'**
  String get countryNC;

  /// No description provided for @countryNE.
  ///
  /// In en, this message translates to:
  /// **'Niger'**
  String get countryNE;

  /// No description provided for @countryNF.
  ///
  /// In en, this message translates to:
  /// **'Norfolk Island'**
  String get countryNF;

  /// No description provided for @countryNG.
  ///
  /// In en, this message translates to:
  /// **'Nigeria'**
  String get countryNG;

  /// No description provided for @countryNI.
  ///
  /// In en, this message translates to:
  /// **'Nicaragua'**
  String get countryNI;

  /// No description provided for @countryNL.
  ///
  /// In en, this message translates to:
  /// **'Netherlands'**
  String get countryNL;

  /// No description provided for @countryNO.
  ///
  /// In en, this message translates to:
  /// **'Norway'**
  String get countryNO;

  /// No description provided for @countryNP.
  ///
  /// In en, this message translates to:
  /// **'Nepal'**
  String get countryNP;

  /// No description provided for @countryNR.
  ///
  /// In en, this message translates to:
  /// **'Nauru'**
  String get countryNR;

  /// No description provided for @countryNU.
  ///
  /// In en, this message translates to:
  /// **'Niue'**
  String get countryNU;

  /// No description provided for @countryNZ.
  ///
  /// In en, this message translates to:
  /// **'New Zealand'**
  String get countryNZ;

  /// No description provided for @countryOM.
  ///
  /// In en, this message translates to:
  /// **'Oman'**
  String get countryOM;

  /// No description provided for @countryPA.
  ///
  /// In en, this message translates to:
  /// **'Panama'**
  String get countryPA;

  /// No description provided for @countryPE.
  ///
  /// In en, this message translates to:
  /// **'Peru'**
  String get countryPE;

  /// No description provided for @countryPF.
  ///
  /// In en, this message translates to:
  /// **'French Polynesia'**
  String get countryPF;

  /// No description provided for @countryPG.
  ///
  /// In en, this message translates to:
  /// **'Papua New Guinea'**
  String get countryPG;

  /// No description provided for @countryPH.
  ///
  /// In en, this message translates to:
  /// **'Philippines'**
  String get countryPH;

  /// No description provided for @countryPK.
  ///
  /// In en, this message translates to:
  /// **'Pakistan'**
  String get countryPK;

  /// No description provided for @countryPL.
  ///
  /// In en, this message translates to:
  /// **'Poland'**
  String get countryPL;

  /// No description provided for @countryPM.
  ///
  /// In en, this message translates to:
  /// **'Saint Pierre and Miquelon'**
  String get countryPM;

  /// No description provided for @countryPN.
  ///
  /// In en, this message translates to:
  /// **'Pitcairn Islands'**
  String get countryPN;

  /// No description provided for @countryPR.
  ///
  /// In en, this message translates to:
  /// **'Puerto Rico'**
  String get countryPR;

  /// No description provided for @countryPS.
  ///
  /// In en, this message translates to:
  /// **'Palestine'**
  String get countryPS;

  /// No description provided for @countryPT.
  ///
  /// In en, this message translates to:
  /// **'Portugal'**
  String get countryPT;

  /// No description provided for @countryPW.
  ///
  /// In en, this message translates to:
  /// **'Palau'**
  String get countryPW;

  /// No description provided for @countryPY.
  ///
  /// In en, this message translates to:
  /// **'Paraguay'**
  String get countryPY;

  /// No description provided for @countryQA.
  ///
  /// In en, this message translates to:
  /// **'Qatar'**
  String get countryQA;

  /// No description provided for @countryRE.
  ///
  /// In en, this message translates to:
  /// **'Réunion'**
  String get countryRE;

  /// No description provided for @countryRO.
  ///
  /// In en, this message translates to:
  /// **'Romania'**
  String get countryRO;

  /// No description provided for @countryRS.
  ///
  /// In en, this message translates to:
  /// **'Serbia'**
  String get countryRS;

  /// No description provided for @countryRU.
  ///
  /// In en, this message translates to:
  /// **'Russia'**
  String get countryRU;

  /// No description provided for @countryRW.
  ///
  /// In en, this message translates to:
  /// **'Rwanda'**
  String get countryRW;

  /// No description provided for @countrySA.
  ///
  /// In en, this message translates to:
  /// **'Saudi Arabia'**
  String get countrySA;

  /// No description provided for @countrySB.
  ///
  /// In en, this message translates to:
  /// **'Solomon Islands'**
  String get countrySB;

  /// No description provided for @countrySC.
  ///
  /// In en, this message translates to:
  /// **'Seychelles'**
  String get countrySC;

  /// No description provided for @countrySD.
  ///
  /// In en, this message translates to:
  /// **'Sudan'**
  String get countrySD;

  /// No description provided for @countrySE.
  ///
  /// In en, this message translates to:
  /// **'Sweden'**
  String get countrySE;

  /// No description provided for @countrySG.
  ///
  /// In en, this message translates to:
  /// **'Singapore'**
  String get countrySG;

  /// No description provided for @countrySH.
  ///
  /// In en, this message translates to:
  /// **'Saint Helena'**
  String get countrySH;

  /// No description provided for @countrySI.
  ///
  /// In en, this message translates to:
  /// **'Slovenia'**
  String get countrySI;

  /// No description provided for @countrySJ.
  ///
  /// In en, this message translates to:
  /// **'Svalbard and Jan Mayen'**
  String get countrySJ;

  /// No description provided for @countrySK.
  ///
  /// In en, this message translates to:
  /// **'Slovakia'**
  String get countrySK;

  /// No description provided for @countrySL.
  ///
  /// In en, this message translates to:
  /// **'Sierra Leone'**
  String get countrySL;

  /// No description provided for @countrySM.
  ///
  /// In en, this message translates to:
  /// **'San Marino'**
  String get countrySM;

  /// No description provided for @countrySN.
  ///
  /// In en, this message translates to:
  /// **'Senegal'**
  String get countrySN;

  /// No description provided for @countrySO.
  ///
  /// In en, this message translates to:
  /// **'Somalia'**
  String get countrySO;

  /// No description provided for @countrySR.
  ///
  /// In en, this message translates to:
  /// **'Suriname'**
  String get countrySR;

  /// No description provided for @countrySS.
  ///
  /// In en, this message translates to:
  /// **'South Sudan'**
  String get countrySS;

  /// No description provided for @countryST.
  ///
  /// In en, this message translates to:
  /// **'São Tomé and Príncipe'**
  String get countryST;

  /// No description provided for @countrySV.
  ///
  /// In en, this message translates to:
  /// **'El Salvador'**
  String get countrySV;

  /// No description provided for @countrySX.
  ///
  /// In en, this message translates to:
  /// **'Sint Maarten'**
  String get countrySX;

  /// No description provided for @countrySY.
  ///
  /// In en, this message translates to:
  /// **'Syria'**
  String get countrySY;

  /// No description provided for @countrySZ.
  ///
  /// In en, this message translates to:
  /// **'Eswatini'**
  String get countrySZ;

  /// No description provided for @countryTC.
  ///
  /// In en, this message translates to:
  /// **'Turks and Caicos Islands'**
  String get countryTC;

  /// No description provided for @countryTD.
  ///
  /// In en, this message translates to:
  /// **'Chad'**
  String get countryTD;

  /// No description provided for @countryTF.
  ///
  /// In en, this message translates to:
  /// **'French Southern Territories'**
  String get countryTF;

  /// No description provided for @countryTG.
  ///
  /// In en, this message translates to:
  /// **'Togo'**
  String get countryTG;

  /// No description provided for @countryTH.
  ///
  /// In en, this message translates to:
  /// **'Thailand'**
  String get countryTH;

  /// No description provided for @countryTJ.
  ///
  /// In en, this message translates to:
  /// **'Tajikistan'**
  String get countryTJ;

  /// No description provided for @countryTK.
  ///
  /// In en, this message translates to:
  /// **'Tokelau'**
  String get countryTK;

  /// No description provided for @countryTL.
  ///
  /// In en, this message translates to:
  /// **'Timor-Leste'**
  String get countryTL;

  /// No description provided for @countryTM.
  ///
  /// In en, this message translates to:
  /// **'Turkmenistan'**
  String get countryTM;

  /// No description provided for @countryTN.
  ///
  /// In en, this message translates to:
  /// **'Tunisia'**
  String get countryTN;

  /// No description provided for @countryTO.
  ///
  /// In en, this message translates to:
  /// **'Tonga'**
  String get countryTO;

  /// No description provided for @countryTR.
  ///
  /// In en, this message translates to:
  /// **'Turkey'**
  String get countryTR;

  /// No description provided for @countryTT.
  ///
  /// In en, this message translates to:
  /// **'Trinidad and Tobago'**
  String get countryTT;

  /// No description provided for @countryTV.
  ///
  /// In en, this message translates to:
  /// **'Tuvalu'**
  String get countryTV;

  /// No description provided for @countryTW.
  ///
  /// In en, this message translates to:
  /// **'Taiwan'**
  String get countryTW;

  /// No description provided for @countryTZ.
  ///
  /// In en, this message translates to:
  /// **'Tanzania'**
  String get countryTZ;

  /// No description provided for @countryUA.
  ///
  /// In en, this message translates to:
  /// **'Ukraine'**
  String get countryUA;

  /// No description provided for @countryUG.
  ///
  /// In en, this message translates to:
  /// **'Uganda'**
  String get countryUG;

  /// No description provided for @countryUM.
  ///
  /// In en, this message translates to:
  /// **'U.S. Minor Outlying Islands'**
  String get countryUM;

  /// No description provided for @countryUS.
  ///
  /// In en, this message translates to:
  /// **'United States'**
  String get countryUS;

  /// No description provided for @countryUY.
  ///
  /// In en, this message translates to:
  /// **'Uruguay'**
  String get countryUY;

  /// No description provided for @countryUZ.
  ///
  /// In en, this message translates to:
  /// **'Uzbekistan'**
  String get countryUZ;

  /// No description provided for @countryVA.
  ///
  /// In en, this message translates to:
  /// **'Vatican City'**
  String get countryVA;

  /// No description provided for @countryVC.
  ///
  /// In en, this message translates to:
  /// **'Saint Vincent and the Grenadines'**
  String get countryVC;

  /// No description provided for @countryVE.
  ///
  /// In en, this message translates to:
  /// **'Venezuela'**
  String get countryVE;

  /// No description provided for @countryVG.
  ///
  /// In en, this message translates to:
  /// **'British Virgin Islands'**
  String get countryVG;

  /// No description provided for @countryVI.
  ///
  /// In en, this message translates to:
  /// **'U.S. Virgin Islands'**
  String get countryVI;

  /// No description provided for @countryVN.
  ///
  /// In en, this message translates to:
  /// **'Vietnam'**
  String get countryVN;

  /// No description provided for @countryVU.
  ///
  /// In en, this message translates to:
  /// **'Vanuatu'**
  String get countryVU;

  /// No description provided for @countryWF.
  ///
  /// In en, this message translates to:
  /// **'Wallis and Futuna'**
  String get countryWF;

  /// No description provided for @countryWS.
  ///
  /// In en, this message translates to:
  /// **'Samoa'**
  String get countryWS;

  /// No description provided for @countryXK.
  ///
  /// In en, this message translates to:
  /// **'Kosovo'**
  String get countryXK;

  /// No description provided for @countryYE.
  ///
  /// In en, this message translates to:
  /// **'Yemen'**
  String get countryYE;

  /// No description provided for @countryYT.
  ///
  /// In en, this message translates to:
  /// **'Mayotte'**
  String get countryYT;

  /// No description provided for @countryZA.
  ///
  /// In en, this message translates to:
  /// **'South Africa'**
  String get countryZA;

  /// No description provided for @countryZM.
  ///
  /// In en, this message translates to:
  /// **'Zambia'**
  String get countryZM;

  /// No description provided for @countryZW.
  ///
  /// In en, this message translates to:
  /// **'Zimbabwe'**
  String get countryZW;

  /// No description provided for @searchCountries.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchCountries;

  /// No description provided for @diveNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Dive number'**
  String get diveNumberLabel;

  /// No description provided for @unitMeters.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get unitMeters;

  /// No description provided for @unitFeet.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get unitFeet;

  /// No description provided for @unitBar.
  ///
  /// In en, this message translates to:
  /// **'bar'**
  String get unitBar;

  /// No description provided for @unitPsi.
  ///
  /// In en, this message translates to:
  /// **'psi'**
  String get unitPsi;

  /// No description provided for @unitCelsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get unitCelsius;

  /// No description provided for @unitFahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get unitFahrenheit;

  /// No description provided for @unitLiters.
  ///
  /// In en, this message translates to:
  /// **'L'**
  String get unitLiters;

  /// No description provided for @unitCubicFeet.
  ///
  /// In en, this message translates to:
  /// **'cuft'**
  String get unitCubicFeet;

  /// No description provided for @unitKilograms.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKilograms;

  /// No description provided for @unitPounds.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitPounds;

  /// No description provided for @unitPoundsPlural.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get unitPoundsPlural;

  /// No description provided for @unknownXmlDiveLog.
  ///
  /// In en, this message translates to:
  /// **'Unknown dive log XML format: root element is <{details}>'**
  String unknownXmlDiveLog(String details);

  /// No description provided for @unsupportedJsonDiveLog.
  ///
  /// In en, this message translates to:
  /// **'Unsupported JSON dive log structure'**
  String get unsupportedJsonDiveLog;

  /// No description provided for @unknownJsonDiveLog.
  ///
  /// In en, this message translates to:
  /// **'Unknown JSON dive log format'**
  String get unknownJsonDiveLog;

  /// No description provided for @invalidSuuntoDiveLog.
  ///
  /// In en, this message translates to:
  /// **'Not a Suunto JSON dive log: missing DeviceLog'**
  String get invalidSuuntoDiveLog;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
