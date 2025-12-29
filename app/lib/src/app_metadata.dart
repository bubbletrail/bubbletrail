const appBuild = int.fromEnvironment('BUILD', defaultValue: 9000);
const appVer = String.fromEnvironment('MARKETINGVERSION', defaultValue: '1.0.0');
const gitSHA = String.fromEnvironment('GITSHA', defaultValue: 'development');
const _buildSeconds = int.fromEnvironment('BUILDSECONDS', defaultValue: 0);
final buildTime = _buildSeconds > 0 ? DateTime.fromMillisecondsSinceEpoch(1000 * _buildSeconds) : DateTime.now();
const gitVer = '$appBuild-$gitSHA';
