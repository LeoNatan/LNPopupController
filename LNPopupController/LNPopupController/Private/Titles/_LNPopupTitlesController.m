//
//  _LNPopupTitlesController.m
//  LNPopupController
//
//  Created by Léo Natan on 16/10/25.
//  Copyright © 2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTitlesController.h"
#import "LNPopupBar+Private.h"
#import "LNPopupItem+Private.h"
#import "UIView+LNPopupSupportPrivate.h"
#import "NSAttributedString+LNPopupSupport.h"
#import "_LNPopupSwizzlingUtils.h"
#import "_LNPopupTitleLabelWrapper.h"

@interface _LNPopupBarTitlesView : UIStackView @end
@implementation _LNPopupBarTitlesView @end

@implementation _LNPopupTitlesController
{
	_LNPopupBarTitlesView* _titlesView;
	UIView* _wrapperView;
	
	UILabel<LNMarqueeLabel>* _titleLabel;
	UILabel<LNMarqueeLabel>* _subtitleLabel;
	
	BOOL _needsTitleLayout;
	BOOL _needsTitleRemove;
}

- (instancetype)initWithPopupBar:(LNPopupBar *)popupBar
{
	return [self initWithPopupBar:popupBar popupItem:nil];
}

- (instancetype)initWithPopupBar:(LNPopupBar*)popupBar popupItem:(LNPopupItem*)popupItem
{
	self = [super init];
	if(self)
	{
		_popupBar = popupBar;
		_popupItem = popupItem;
		
		[self setNeedsTitleLayoutRemovingLabels:NO];
	}
	return self;
}

- (LNPopupItem *)popupItem
{
	if(_popupItem != nil)
	{
		return _popupItem;
	}
	
	return _popupBar.popupItem;
}

- (void)loadView
{
	_wrapperView = [UIView new];
	
	_titlesView = [_LNPopupBarTitlesView new];
	_titlesView.axis = UILayoutConstraintAxisVertical;
	_titlesView.alignment = UIStackViewAlignmentFill;
	_titlesView.distribution = UIStackViewDistributionFill;
	_titlesView.autoresizingMask = UIViewAutoresizingNone;
	_titlesView.accessibilityTraits = UIAccessibilityTraitButton;
	_titlesView.isAccessibilityElement = YES;
	
	[_wrapperView addSubview:_titlesView];
	
	self.view = _wrapperView;
	
	self.view.autoresizingMask = UIViewAutoresizingNone;
}

- (_LNPopupBarTitlesView*)titlesView
{
	[self loadViewIfNeeded];
	return _titlesView;
}

- (CGFloat)spacing
{
	return self.titlesView.spacing;
}

- (void)setSpacing:(CGFloat)spacing
{
	self.titlesView.spacing = spacing;
}

- (NSUInteger)numberOfLabels
{
	return (_titleLabel ? 1 : 0) + (_subtitleLabel ? 1 : 0);
}

- (CGFloat)heightFittingTitleLabel
{
	return [_titleLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (CGFloat)heightFittingSubtitleLabel
{
	return [_subtitleLabel systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (UILabel<LNMarqueeLabel>*)_labelWithFrame:(CGRect)frame marqueeEnabled:(BOOL)marqueeEnabled
{
	UILabel<LNMarqueeLabel>* _rv = nil;
	
	if(!marqueeEnabled)
	{
		LNNonMarqueeLabel* rv = [[LNNonMarqueeLabel alloc] initWithFrame:frame];
		rv.minimumScaleFactor = 1.0;
		rv.lineBreakMode = NSLineBreakByTruncatingTail;
		_rv = rv;
	}
	else
	{
#if __has_include(<LNSystemMarqueeLabel.h>)
		if(__LNPopupUseSystemMarqueeLabel())
		{
			LNSystemMarqueeLabel* rv = [[LNSystemMarqueeLabel alloc] initWithFrame:frame];
			_rv = rv;
		}
		else
		{
#endif
			LNLegacyMarqueeLabel* rv = [[LNLegacyMarqueeLabel alloc] initWithFrame:frame rate:_popupBar.activeAppearance.marqueeScrollRate andFadeLength:10];
			rv.leadingBuffer = 0.0;
			rv.trailingBuffer = 50.0;
			rv.animationDelay = _popupBar.activeAppearance.marqueeScrollDelay;
			rv.marqueeType = MLContinuous;
			_rv = rv;
#if __has_include(<LNSystemMarqueeLabel.h>)
		}
#endif
	}
	
	_rv.numberOfLines = 1;
	_rv.adjustsFontForContentSizeCategory = YES;
	_rv.translatesAutoresizingMaskIntoConstraints = NO;
	[_rv setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
	return _rv;
}

- (void)setNeedsTitleLayoutRemovingLabels:(BOOL)remove
{
	_needsTitleLayout = YES;
	_needsTitleRemove = remove;
	
	[self.view setNeedsLayout];
}

- (void)layoutTitlesRemovingLabels:(BOOL)remove
{
	_needsTitleLayout = NO;
	_needsTitleRemove = NO;
	
//	[UIView performWithoutAnimation:^{
		BOOL reset = NO;
		
		CGRect titleFrameToUse = CGRectZero;
		CGRect subtitleFrameToUse = CGRectZero;
		if(remove == YES)
		{
			if(_titleLabel.superview == self.titlesView)
			{
				titleFrameToUse = _titleLabel.bounds;
				[_titleLabel removeFromSuperview];
			}
			else
			{
				titleFrameToUse = _titleLabel.superview.bounds;
				[_titleLabel.superview removeFromSuperview];
			}
			
			if(_subtitleLabel.superview == self.titlesView)
			{
				subtitleFrameToUse = _titleLabel.bounds;
				[_subtitleLabel removeFromSuperview];
			}
			else
			{
				subtitleFrameToUse = _subtitleLabel.superview.bounds;
				[_subtitleLabel.superview removeFromSuperview];
			}
			
			_titleLabel = nil;
			_subtitleLabel = nil;
		}
		
		if(self.popupItem.swiftuiTitleContentView != nil)
		{
			[_titleLabel.superview removeFromSuperview];
			_titleLabel = nil;
			[_subtitleLabel.superview removeFromSuperview];
			_subtitleLabel = nil;
			
			if(self.popupItem.swiftuiTitleContentView.superview != self.titlesView)
			{
				[self.titlesView addArrangedSubview:self.popupItem.swiftuiTitleContentView];
				[self.titlesView layoutIfNeeded];
			}
			if(ln_unavailable(iOS 17.0, *))
			{
				UIView* textView = self.popupItem.swiftuiTitleContentView.subviews.firstObject;
				[NSLayoutConstraint activateConstraints:@[
					[self.popupItem.swiftuiTitleContentView.heightAnchor constraintEqualToAnchor:textView.heightAnchor],
				]];
			}
		}
		else
		{
			NSAttributedString* attr = self.popupItem.attributedTitle.length > 0 ? [NSAttributedString ln_attributedStringWithAttributedString:self.popupItem.attributedTitle defaultAttributes:_popupBar.activeAppearance.titleTextAttributes] : nil;
			
			if(attr.length > 0)
			{
				if(_titleLabel == nil)
				{
					_titleLabel = [self _labelWithFrame:titleFrameToUse marqueeEnabled:_popupBar.activeAppearance.marqueeScrollEnabled];
#if DEBUG
					if(_LNEnableBarLayoutDebug())
					{
						_titleLabel.backgroundColor = [UIColor.redColor colorWithAlphaComponent:0.5];
					}
					else
					{
						_titleLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.0];
					}
#endif
					_titleLabel.textColor = _popupBar._titleColor;
					_titleLabel.font = _popupBar._titleFont;
					if(_popupBar.resolvedStyle == LNPopupBarStyleCompact)
					{
						_titleLabel.textAlignment = NSTextAlignmentCenter;
					}
					
//					[_titlesView addArrangedSubview:_titleLabel];
					[self.titlesView addArrangedSubview:[_LNPopupTitleLabelWrapper wrapperForLabel:_titleLabel]];
				}
				
				if([_titleLabel.attributedText isEqualToAttributedString:attr] == NO)
				{
					_titleLabel.attributedText = attr;
					reset = YES;
				}
			}
			else
			{
				[_titleLabel removeFromSuperview];
				_titleLabel = nil;
			}
			
			attr = self.popupItem.attributedSubtitle.length > 0 ? [NSAttributedString ln_attributedStringWithAttributedString:self.popupItem.attributedSubtitle defaultAttributes:_popupBar.activeAppearance.subtitleTextAttributes] : nil;
			
			if(attr.length > 0)
			{
				if(_subtitleLabel == nil)
				{
					_subtitleLabel = [self _labelWithFrame:subtitleFrameToUse marqueeEnabled:_popupBar.activeAppearance.marqueeScrollEnabled];
#if DEBUG
					if(_LNEnableBarLayoutDebug())
					{
						_subtitleLabel.backgroundColor = [UIColor.cyanColor colorWithAlphaComponent:0.5];
					}
					else
					{
						_subtitleLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.0];
					}
#endif
					_subtitleLabel.textColor = _popupBar._subtitleColor;
					_subtitleLabel.font = _popupBar._subtitleFont;
					if(_popupBar.resolvedStyle == LNPopupBarStyleCompact)
					{
						_subtitleLabel.textAlignment = NSTextAlignmentCenter;
					}
					
//					[_titlesView addArrangedSubview:_subtitleLabel];
					[self.titlesView addArrangedSubview:[_LNPopupTitleLabelWrapper wrapperForLabel:_subtitleLabel]];
				}
				
				if([_subtitleLabel.attributedText isEqualToAttributedString:attr] == NO)
				{
					_subtitleLabel.attributedText = attr;
					reset = YES;
				}
			}
			else
			{
				[_subtitleLabel removeFromSuperview];
				_subtitleLabel = nil;
			}
		}
		
		if(reset)
		{
			[_titleLabel reset];
			[_subtitleLabel reset];
		}
//	}];
	
	[self updateAccessibility];
	
	[self _recalculateCoordinatedMarqueeAndStartScrollIfNeeded];
}

- (void)updateAccessibility
{
	if(_popupBar.accessibilityCenterLabel.length > 0)
	{
		self.titlesView.accessibilityLabel = _popupBar.accessibilityCenterLabel;
	}
	else
	{
		NSMutableString* accessibilityLabel = [NSMutableString new];
		if(self.popupItem.attributedTitle.length > 0)
		{
			[accessibilityLabel appendString:self.popupItem.attributedTitle.string];
			[accessibilityLabel appendString:@"\n"];
		}
		if(self.popupItem.attributedSubtitle.length > 0)
		{
			[accessibilityLabel appendString:self.popupItem.attributedSubtitle.string];
		}
		self.titlesView.accessibilityLabel = accessibilityLabel;
	}
	
	if(_popupBar.accessibilityCenterHint.length > 0)
	{
		self.titlesView.accessibilityHint = _popupBar.accessibilityCenterHint;
	}
	else
	{
		self.titlesView.accessibilityHint = NSLocalizedString(@"Double tap to open.", @"");
	}
}

- (void)_recalculateCoordinatedMarqueeAndStartScrollIfNeeded
{
	if(_popupBar.activeAppearance.marqueeScrollEnabled == NO)
	{
		return;
	}
	
	if(_marqueePaused == YES)
	{
		return;
	}
	
	id<LNMarqueeLabel> titleLabel = (id)_titleLabel;
	id<LNMarqueeLabel> subtitleLabel = (id)_subtitleLabel;
	
	if(_popupBar.activeAppearance.coordinateMarqueeScroll == YES && _titleLabel != nil && _subtitleLabel != nil)
	{
		titleLabel.synchronizedLabels = @[_subtitleLabel];
		subtitleLabel.synchronizedLabels = @[_titleLabel];
	}
	else
	{
		titleLabel.synchronizedLabels = nil;
		subtitleLabel.synchronizedLabels = nil;
	}
	
	titleLabel.marqueeScrollEnabled = YES;
	subtitleLabel.marqueeScrollEnabled = YES;
	titleLabel.running = YES;
	subtitleLabel.running = YES;
}

- (void)setMarqueePaused:(BOOL)marqueePaused
{
	_marqueePaused = marqueePaused;
	
	if(marqueePaused)
	{
		[_titleLabel reset];
		_titleLabel.marqueeScrollEnabled = NO;
		[_titleLabel reset];
		_subtitleLabel.marqueeScrollEnabled = NO;
	}
	else
	{
		[self _recalculateCoordinatedMarqueeAndStartScrollIfNeeded];
	}
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	if(_needsTitleLayout)
	{
		[self layoutTitlesRemovingLabels:_needsTitleRemove];
	}
	
	CGFloat titlesHeight = self.heightFittingTitleLabel + self.heightFittingSubtitleLabel + (self.numberOfLabels > 1 ? 1 : 0) * self.spacing;
	
	__block CGRect currentFrame = self.titlesView.frame;
	CGRect targetFrame = _wrapperView.bounds;
	CGFloat dy = targetFrame.size.height - titlesHeight;
	
	[UIView performWithoutAnimation:^{
		currentFrame.size.height = titlesHeight;
		currentFrame.origin.y = targetFrame.origin.y + (dy / 2.0);
		self.titlesView.frame = currentFrame;
		
		[self.titlesView layoutIfNeeded];
	}];
	
	currentFrame.size.width = targetFrame.size.width;
	currentFrame.origin.x = targetFrame.origin.x;
	
	self.titlesView.frame = currentFrame;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@: %p title: “%@” subtitle: “%@”>", self.class, self, _titleLabel.text, _subtitleLabel.text];
}

@end
