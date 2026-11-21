//
//  LNPopupVerticalBarSupport.h
//  LNPopupController
//
//  Created by Léo Natan on 20/11/26.
//  Copyright © 2015-2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#if defined(__IPHONE_27_1)
extern NSInteger _LNPopupResolvedVerticalBarBehavior(UIViewController* _Nullable controller) API_AVAILABLE(ios(27.1));
extern void _LNPopupSetVerticalBarDisabled(UIViewController* _Nullable controller, BOOL disabled) API_AVAILABLE(ios(27.1));
extern UIEdgeInsets _LNPopupInsetsAdjustedForHorizontalStatusBarAxis(UIView* view, UIEdgeInsets insets) API_AVAILABLE(ios(27.1));
#endif

extern void _LNPopupPerformForcingHorizontalStatusBarAxis(BOOL force, NS_NOESCAPE dispatch_block_t block);
extern BOOL _LNPopupIsForcingHorizontalStatusBarAxis(void);

NS_ASSUME_NONNULL_END
