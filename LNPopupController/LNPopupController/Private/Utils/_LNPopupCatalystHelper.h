//
//  _LNPopupCatalystHelper.h
//  LNPopupController
//
//  Created by Léo Natan on 18/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_OS_MACCATALYST

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupCatalystMetrics: NSObject

@property (nonatomic) CGSize glassButtonSize;
@property (nonatomic) CGFloat topConstant;
@property (nonatomic) CGFloat leadingConstant;
@property (nonatomic) CGFloat trailingConstant;

@end

@interface _LNPopupCatalystHelper : NSObject

+ (_LNPopupCatalystMetrics*)metricsForScene:(UIWindowScene*)scene;
- (void)startHidingToolbarWithScene:(UIWindowScene*)scene;
- (void)restore;

@end

NS_ASSUME_NONNULL_END

#endif
