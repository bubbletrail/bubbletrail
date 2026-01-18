abstract class AppRouteName {
  static const dives = 'dives';
  static const divesDetails = 'dive-details';
  static const divesDetailsEdit = 'dive-edit';
  static const divesNew = 'new-dive';

  static const divesDetailsDepthProfile = 'dive-depth-profile';

  static const sites = 'sites';
  static const sitesDetailsMap = 'site-map';
  static const sitesDetails = 'site-details';
  static const sitesDetailsEdit = 'site-edit';
  static const sitesNew = 'new-site';

  static const equipment = 'equipment';
  static const cylinders = 'cylinders';
  static const cylindersDetails = 'cylinder-details';
  static const cylindersNew = 'new-cylinder';

  static const preferences = 'preferences';
  static const units = 'units';
  static const divePreferences = 'dive-preferences';
  static const syncing = 'syncing';
  static const logs = 'logs';

  static const connect = 'connect';
}

abstract class AppRoutePath {
  static const dives = '/dives';
  static const divesDetails = ':diveID';
  static const divesDetailsEdit = 'edit';
  static const divesNew = 'new';

  static const divesDetailsDepthProfile = '/depth-profile/:diveID';

  static const sites = '/sites';
  static const sitesDetails = ':siteID';
  static const sitesDetailsEdit = 'edit';
  static const sitesNew = 'new';

  static const sitesDetailsMap = '/sites/:siteID/map';

  static const equipment = '/equipment';
  static const cylinders = 'cylinders';
  static const cylindersDetails = ':cylinderID';
  static const cylindersNew = 'new';

  static const preferences = '/preferences';
  static const units = 'units';
  static const divePreferences = 'dive';
  static const syncing = 'syncing';
  static const logs = 'logs';

  static const connect = '/connect';
}
