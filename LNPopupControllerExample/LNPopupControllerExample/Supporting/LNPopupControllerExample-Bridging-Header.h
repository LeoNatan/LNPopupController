//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#if LNPOPUP
@import LNPopupController;
#endif
#import "LoremIpsum.h"
#import "RandomColors.h"
#import "SafeSystemImages.h"
#import "SettingKeys.h"
#import "DemoPopupContentViewController.h"
#import "LNPopupControllerExampleSupport.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect ()

+ (instancetype)_effectWithStyle:(UIBlurEffectStyle)arg1 tintColor:(UIColor*)arg2 invertAutomaticStyle:(BOOL)arg3;
+ (instancetype)_effectWithTintColor:(UIColor*)arg1;
+ (instancetype)effectWithBlurRadius:(CGFloat)arg1;
+ (instancetype)effectWithVariableBlurRadius:(CGFloat)arg1 imageMask:(UIImage*)arg2 API_AVAILABLE(ios(17.0));

@end

@interface UIImage ()

+ (instancetype)_systemImageNamed:(NSString*)name;
+ (instancetype)_systemImageNamed:(NSString*)name withConfiguration:(nullable UIImageConfiguration *)configuration allowPrivate:(BOOL)allowPrivate;

@end

NS_ASSUME_NONNULL_END
