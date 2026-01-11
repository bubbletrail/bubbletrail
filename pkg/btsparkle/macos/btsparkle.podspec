#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_sparkle.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'btsparkle'
  s.version          = '1.0.0'
  s.summary          = 'Sparkle updater'
  s.description      = 'Sparkle updater'
  s.homepage         = 'https://bubbletrail.app/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Kastelo AB' => 'info@kastelo.net' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'FlutterMacOS'
  s.osx.dependency 'Sparkle'

  s.platform = :osx, '10.15'
  s.osx.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
