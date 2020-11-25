#
# Be sure to run `pod lib lint FirebaseRemoteSettings.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FirebaseRemoteSettings'
  s.version          = '0.2.0'
  s.swift_versions    = ['5.0', '5.1', '5.2', '5.3']
  s.summary          = 'A default RemoteSettings for Firebase FirebaseRemoteSettings.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  A default CoreRemoteSettings for Firebase which should be injected from Application layer.
                       DESC

  s.homepage         = 'https://github.com/congncif/FirebaseRemoteSettings'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NGUYEN CHI CONG' => 'congnc.if@gmail.com' }
  s.source           = { :git => 'https://github.com/congncif/FirebaseRemoteSettings.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/congncif'

  s.ios.deployment_target = '10.0'
  
  s.static_framework = true

  s.source_files = 'FirebaseRemoteSettings/Classes/**/*'
  
  s.dependency 'CoreRemoteSettings'
  s.dependency 'FirebaseRemoteConfig'
   
end
