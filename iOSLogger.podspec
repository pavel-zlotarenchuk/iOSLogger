#
# Be sure to run `pod lib lint iOSLogger.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'iOSLogger'
  s.version          = '0.1.7'
  s.summary          = 'Easy logging and send logs for your app.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/pavel-zlotarenchuk/iOSLogger'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'pavel-zlotarenchuk' => 'pavel.zlotarenchuk@gmail.com' }
  s.source           = { :git => 'https://github.com/pavel-zlotarenchuk/iOSLogger.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'iOSLogger/Classes/**/*'
  s.swift_version = '4.0'
# s.resource_bundles = {
  #   'iOSLogger' => ['iOSLogger/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'Zip'
  s.dependency 'Zip', '~> 1.1'
end
