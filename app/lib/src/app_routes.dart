abstract class AppRouteName {
  static const dives = 'dives';
  static const divesDetails = 'dive-details';
  static const divesDetailsEdit = 'dive-edit';
  static const divesNew = 'new-dive';

  static const sites = 'sites';
  static const sitesDetails = 'site-details';
  static const sitesDetailsEdit = 'site-edit';
  static const sitesNew = 'new-site';

  static const equipment = 'equipment';
  static const cylinders = 'cylinders';
  static const cylindersDetails = 'cylinder-details';
  static const cylindersDetailsEdit = 'cylinder-edit';
  static const cylindersNew = 'new-cylinder';

  static const connect = 'connect';
}

abstract class AppRoutePath {
  static const dives = '/dives';
  static const divesDetails = ':diveID';
  static const divesDetailsEdit = 'edit';
  static const divesNew = 'new';

  static const sites = '/sites';
  static const sitesDetails = ':siteID';
  static const sitesDetailsEdit = 'edit';
  static const sitesNew = 'new';

  static const equipment = '/equipment';
  static const cylinders = 'cylinders';
  static const cylindersDetails = ':cylinderID';
  static const cylindersDetailsEdit = 'edit';
  static const cylindersNew = 'new';

  static const connect = '/connect';
}
