Pod::Spec.new do |s|
  s.name             = "PrediKit"
  s.version          = "1.0.0"
  s.summary          = "A short description of PrediKit."
  s.homepage         = "https://github.com/hectormatos2011/PrediKit"
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.author           = { "Hector Matos" => "hectormatos2011@gmail.com" }
  s.source           = { git: "https://github.com/hectormatos2011/PrediKit.git", tag: s.version.to_s }
  s.social_media_url = 'https://twitter.com/hectormatos2011'
  s.ios.deployment_target = '8.0'
  s.requires_arc = true
  s.ios.source_files = 'Sources/**/*'
  # s.ios.frameworks = 'UIKit', 'Foundation'
  # s.dependency 'Eureka', '~> 1.0'
end
