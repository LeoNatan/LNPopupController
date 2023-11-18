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

NS_ASSUME_NONNULL_BEGIN

@interface UIBlurEffect ()

+ (instancetype)effectWithBlurRadius:(CGFloat)arg1;
+ (instancetype)effectWithVariableBlurRadius:(CGFloat)arg1 imageMask:(UIImage*)arg2 API_AVAILABLE(ios(17.0));

@end

NS_ASSUME_NONNULL_END
