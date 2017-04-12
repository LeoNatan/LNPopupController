Pod::Spec.new do |s|
  s.name                  = 'LNPopupController'
  s.version               = '1.4'
  s.license               = 'MIT'
  s.summary               = 'A framework for presenting view controllers as popups of other view controllers.'
  s.description           = 'LNPopupController is a framework for presenting view controllers as popups of other view controllers, much like the Apple Music and Podcasts apps.'
  s.homepage              = 'https://github.com/LeoNatan/LNPopupController'
  s.authors               = 'Leo Natan'
  s.source                = { :git => 'https://github.com/LeoNatan/LNPopupController.git', :tag => 'v' << s.version.to_s }
  s.source_files          = 'LNPopupController/*.h', 'LNPopupController/**/*.{h,m}', 'LNPopupController/**/**/*.{h,m}'
  s.resources             = 'LNPopupController/LNPopupControllerAssets.xcassets'
  s.public_header_files   = 'LNPopupController/*.h', 'LNPopupController/**/*.h'
  s.requires_arc          = true
  s.ios.deployment_target = '8.0'
end
