Pod::Spec.new do |s|
  s.name = 'PrediKit'
  s.version = '3.0'
  s.license = 'MIT'
  s.summary = 'A Swift NSPredicate DSL for iOS & OS X inspired by SnapKit, lovingly written in Swift, and created by the awesome peeps at KrakenDev.io!'
  s.homepage = 'https://github.com/KrakenDev/PrediKit'
  s.authors = { 'Hector Matos' => 'hectormatos2011@gmail.com' }
  s.social_media_url = 'http://twitter.com/allonsykraken'
  s.source = { :git => 'https://github.com/KrakenDev/PrediKit.git', :tag => s.version }

  s.ios.deployment_target = '8.0'
  s.osx.deployment_target = '10.9'
  s.tvos.deployment_target = '9.0'
  s.watchos.deployment_target = '2.0'

  s.source_files = 'Sources/**/*.swift'

  s.requires_arc = true
end
