//
//  LNMarqueeLabelUtils.h
//  LNPopupController
//
//  Created by Léo Natan on 23/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarqueeLabel.h"

#define _LN_SYSTEM_MARQUEE_LABEL_HEADER <LNSystemMarqueeLabel.h>
#define LN_HAS_SYSTEM_MARQUEE_LABEL __has_include(_LN_SYSTEM_MARQUEE_LABEL_HEADER)

#if LN_HAS_SYSTEM_MARQUEE_LABEL
#import _LN_SYSTEM_MARQUEE_LABEL_HEADER
#endif

@protocol LNMarqueeLabel <NSObject>

@property (nonatomic, getter=isMarqueeScrollEnabled) BOOL marqueeScrollEnabled;
@property (nonatomic, getter=isRunning) BOOL running;

@property (nonatomic, copy) NSArray<id<LNMarqueeLabel>>* synchronizedLabels;

- (void)reset;

@end

@interface LNNonMarqueeLabel : UILabel <LNMarqueeLabel> @end
@interface LNLegacyMarqueeLabel: _LNMarqueeLabelImpl <LNMarqueeLabel> @end
#if LN_HAS_SYSTEM_MARQUEE_LABEL
@interface LNSystemMarqueeLabel () <LNMarqueeLabel> @end
#endif
