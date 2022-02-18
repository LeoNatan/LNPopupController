#
# Be sure to run `pod lib lint LNPopupController.podspec --allow-warnings' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |spec|
  spec.name             = 'LNPopupController'
  spec.version          = '2.13.3'
  spec.summary          = 'LNPopupController is a framework for presenting view controllers as popups of other view controllers'
  spec.description      = <<-DESC
LNPopupController is a framework for presenting view controllers as popups of other view controllers, much like the Apple Music and Podcasts apps.
                       DESC

  spec.homepage = 'https://github.com/LeoNatan/LNPopupController'
  spec.license = { type: 'MIT', file: "LICENSE" }
  spec.author = { 'LeoNatan' => 'LeoNatan@users.noreply.github.com' }

  spec.ios.deployment_target = '9.0'

  spec.source = { :git => 'git@github.com:egeniq-forks/LNPopupController.git', :tag => "#{spec.version}"}

  spec.source_files  = "LNPopupController/LNPopupController/**/*.{h,m}"

  spec.requires_arc = true

  spec.frameworks = 'UIKit', 'Foundation'

end
