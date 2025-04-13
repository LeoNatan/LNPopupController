//
//  LNPopupPresentationContainerSupport.m
//  LNPopupController
//
//  Created by Léo Natan on 13/4/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "LNPopupPresentationContainerSupport.h"
#import "UIViewController+LNPopupSupportPrivate.h"
#import "_LNPopupSwizzlingUtils.h"

#define LN_POPUP_SMART_CHILD_OVERRIDE(name, availability) \
- (UIViewController*)name API_AVAILABLE(availability) \
{ \
UIViewController* rv = [self _ln_childViewControllerForStatusBarLogic]; \
if(rv != nil) \
{ \
return rv;\
}\
\
Class superclass = LNDynamicSubclassSuper(self, LNPopupPresentationContainerSupport.class);\
struct objc_super super = {.receiver = self, .super_class = superclass};\
UIViewController* (*super_class)(struct objc_super*, SEL) = (void*)objc_msgSendSuper;\
return super_class(&super, _cmd);\
}

@implementation LNPopupPresentationContainerSupport

LN_POPUP_SMART_CHILD_OVERRIDE(childViewControllerForPointerLock, ios(14))
LN_POPUP_SMART_CHILD_OVERRIDE(childViewControllerForStatusBarStyle, ios(7))
LN_POPUP_SMART_CHILD_OVERRIDE(childViewControllerForStatusBarHidden, ios(7))
LN_POPUP_SMART_CHILD_OVERRIDE(childViewControllerForHomeIndicatorAutoHidden, ios(11))
LN_POPUP_SMART_CHILD_OVERRIDE(childViewControllerForScreenEdgesDeferringSystemGestures, ios(11))

@end
