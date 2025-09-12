Pod::Spec.new do |s|
  s.name             = 'LNPopupController'
  s.version          = '4.0.5'
  s.summary          = 'A framework for presenting popup bars and content views.'
  s.description      = 'LNPopupController provides a popup bar, similar to Apple Music and Podcasts.'
  s.homepage         = 'https://github.com/LeoNatan/LNPopupController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Leo Natan' => 'leonatan@icloud.com' }

  s.source           = { :git => 'https://github.com/LeoNatan/LNPopupController.git', :tag => s.version.to_s }

  s.swift_version    = '5.9'
  s.platforms        = { :ios => '13.0' }  # Mac Catalyst enabled via xcconfig below

  s.requires_arc     = true
  s.module_name      = 'LNPopupController'

  # ObjC core
  s.public_header_files = 'LNPopupController/include/**/*.h'
  s.source_files        = [
    'LNPopupController/**/*.{h,m,mm,c,cpp}',
    'LNPCSwiftRefinements/**/*.{swift}'
  ]
  s.exclude_files = [
    'LNPopupController/Info.plist'
  ]

  s.frameworks = 'UIKit'
  s.ios.deployment_target = '13.0'

  # Header search paths required by SPM target config (include + Private)
  s.pod_target_xcconfig = {
    'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/LNPopupController $(PODS_TARGET_SRCROOT)/LNPopupController/Private',
    # Mac Catalyst support
    'SUPPORTS_MACCATALYST' => 'YES',
    'DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER' => 'YES',
    # Match SPM’s C++ standard just in case
    'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++20'
  }

  # If the project uses resource images in the future, declare them here:
  # s.resource_bundles = { 'LNPopupController' => ['LNPopupController/Resources/**/*'] }
end