//
//  LNChevronView.h
//
//  Created by Leo Natan on 16/9/16.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#define LNChevronView __LNChevronView
#define LNChevronViewState __LNChevronViewState
#define LNChevronViewStateUp __LNChevronViewStateUp
#define LNChevronViewStateFlat __LNChevronViewStateFlat
#define LNChevronViewStateDown __LNChevronViewStateDown

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, LNChevronViewState) {
	LNChevronViewStateUp = -1,
	LNChevronViewStateFlat = 0,
	LNChevronViewStateDown = 1
};

@interface LNChevronView : UIView

@property (nonatomic, assign) LNChevronViewState state;
@property (nonatomic, strong, null_resettable) UIColor* color;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) NSTimeInterval animationDuration;

- (void)setState:(LNChevronViewState)state animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
