abstract class AppRouteName {
  static const dives = 'dives';
  static const divesDetails = 'dive-details';
  static const divesDetailsEdit = 'dive-edit';
  static const divesNew = 'new-dive';

  static const sites = 'sites';
  static const sitesDetails = 'site-details';

  static const connect = 'connect';
}

abstract class AppRoutePath {
  static const dives = '/dives';
  static const divesDetails = ':diveID';
  static const divesDetailsEdit = 'edit';
  static const divesNew = 'new';

  static const sites = '/sites';
  static const sitesDetails = ':siteID';

  static const connect = '/connect';
}
