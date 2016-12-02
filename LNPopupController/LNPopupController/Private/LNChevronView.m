//
//  LNChevronView.m
//
//  Created by Leo Natan on 16/9/16.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import "LNChevronView.h"

static const CGFloat _LNChevronDefaultWidth = 4.67;
static const CGFloat _LNChevronAngleCoefficient = 42.5714286;
static const NSTimeInterval _LNChevronDefaultAnimationDuration = 0.3;

IB_DESIGNABLE
@interface LNChevronView (Inspectable)

@property (nonatomic, assign) IBInspectable NSInteger chevronState;
@property (nonatomic, strong, null_resettable) IBInspectable UIColor* color;
@property (nonatomic, assign) IBInspectable CGFloat width;

@end

@implementation LNChevronView
{
	UIView* _leftView;
	UIView* _rightView;
	
	LNChevronViewState _pendingState;
}

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	[self _commonInit];
	return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	[self _commonInit];
	return self;
}

- (void)_commonInit
{
	self.color = [UIColor lightGrayColor];
	self.width = _LNChevronDefaultWidth;
	self.animationDuration = _LNChevronDefaultAnimationDuration;
	
	self.userInteractionEnabled = NO;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	if(_leftView == nil)
	{
		_leftView = [[UIView alloc] initWithFrame:CGRectZero];
		_leftView.backgroundColor = self.color;
		_rightView = [[UIView alloc] initWithFrame:CGRectZero];
		_rightView.backgroundColor = self.color;
		
		[self addSubview:_leftView];
		[self addSubview:_rightView];
	}
	
	CGRect leftFrame, rightFrame;
	CGRectDivide(self.bounds, &leftFrame, &rightFrame, self.bounds.size.width * 0.5, CGRectMinXEdge);
	rightFrame.size.height = leftFrame.size.height = self.width;
	
	CGFloat angle = self.bounds.size.height / self.bounds.size.width * _LNChevronAngleCoefficient;
	CGFloat dx = leftFrame.size.width * (1 - cos(angle * M_PI / 180.0)) / 2.0;
	
	leftFrame = CGRectOffset(leftFrame, self.width / 2 + dx - 0.75, 0.0);
	rightFrame = CGRectOffset(rightFrame, -(self.width / 2) - dx + 0.75, 0.0);
	
	_leftView.bounds = leftFrame;
	_rightView.bounds = rightFrame;
	_leftView.center = CGPointMake(CGRectGetMidX(leftFrame), CGRectGetMidY(self.bounds));
	_rightView.center = CGPointMake(CGRectGetMidX(rightFrame), CGRectGetMidY(self.bounds));
	
	_leftView.layer.cornerRadius = self.width / 2.0;
	_rightView.layer.cornerRadius = self.width / 2.0;
	
	if(_pendingState != 0)
	{
		[self setState:_pendingState];
		_pendingState = 0;
	}
}

- (void)setChevronState:(NSInteger)state
{
	[self setState:state];
}

- (void)setState:(LNChevronViewState)state
{
	[self setState:state animated:NO];
}

- (void)setState:(LNChevronViewState)state animated:(BOOL)animated
{
	if(state > 1)
	{
		state = 1;
	}
	if(state < -1)
	{
		state = -1;
	}
	
	if(state == _state)
	{
		return;
	}
	
	if(_leftView == nil)
	{
		_pendingState = state;
		return;
	}
	
	_state = state;
	
	CGFloat angle = self.bounds.size.height / self.bounds.size.width * _LNChevronAngleCoefficient;
	void (^transition)() = ^() {
		_leftView.transform = CGAffineTransformMakeRotation(-state * angle * M_PI / 180.0);
		_rightView.transform = CGAffineTransformMakeRotation(state * angle * M_PI / 180.0);
	};
	
	if(animated == NO)
	{
		[UIView performWithoutAnimation:transition];
	}
	else
	{
		[UIView animateWithDuration:_animationDuration animations:transition];
	}
}

- (void)setColor:(UIColor *)color
{
	if(color == nil)
	{
		color = [UIColor lightGrayColor];
	}
	
	_color = color;
	
	_leftView.backgroundColor = color;
	_rightView.backgroundColor = color;
}

- (void)setWidth:(CGFloat)width
{
	_width = width;
	
	[self setNeedsLayout];
}

#if TARGET_INTERFACE_BUILDER
- (void)prepareForInterfaceBuilder
{
	
}
#endif

@end
