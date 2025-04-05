//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#if LNPOPUP
@import LNPopupController;
#endif
#import "LoremIpsum.h"
#import "RandomColors.h"
#import "SettingsTableViewController.h"

NS_ASSUME_NONNULL_BEGIN

extern UIImage* LNSystemImage(NSString* named) NS_SWIFT_NAME(LNSystemImage(named:));

@interface UIBlurEffect ()

+ (instancetype)effectWithBlurRadius:(CGFloat)arg1;

@end

NS_ASSUME_NONNULL_END
