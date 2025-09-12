Pod::Spec.new do |s|
  s.name         = 'LNPopupController'
  s.version      = '4.0.5'  # use a real tag from the repo
  s.summary      = 'Popup bar like Apple Music/Podcasts.'
  s.description  = 'LNPopupController provides a popup bar and content presentation.'
  s.homepage     = 'https://github.com/LeoNatan/LNPopupController'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'Leo Natan' => 'leonatan@icloud.com' }
  s.source       = { :git => 'https://github.com/everappz/LNPopupController.git', :tag => s.version.to_s }

  s.swift_version = '5.9'
  s.platforms = { :ios => '13.0' }

  # Subspec mirroring SPM targets
  s.subspec 'ObjC' do |ss|
    ss.source_files = [
      'LNPopupController/LNPopupController/**/*.{h,m,mm,c,cpp}',   # ObjC sources (and their headers)
      'LNPopupController/LNPopupController.h'                      # umbrella header (top-level)
    ]
    ss.public_header_files = [
      'LNPopupController/LNPopupController/**/*.h',
      'LNPopupController/LNPopupController.h'
    ]
    ss.exclude_files = ['LNPopupController/Info.plist']

    ss.frameworks = 'UIKit'
    ss.pod_target_xcconfig = {
      'HEADER_SEARCH_PATHS' => '$(PODS_TARGET_SRCROOT)/LNPopupController/LNPopupController $(PODS_TARGET_SRCROOT)/LNPopupController/LNPopupController/Private',
      'SUPPORTS_MACCATALYST' => 'YES',
      'DERIVE_MACCATALYST_PRODUCT_BUNDLE_IDENTIFIER' => 'YES',
      'CLANG_CXX_LANGUAGE_STANDARD' => 'gnu++20'
    }
  end

  s.subspec 'Swift' do |ss|
    ss.dependency 'LNPopupController/ObjC'
    ss.source_files = 'LNPCSwiftRefinements/**/*.swift'            # Swift target only
  end

  # Default = both targets
  s.default_subspecs = ['ObjC', 'Swift']
end
