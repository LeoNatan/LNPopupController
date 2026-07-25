//
//  IntroWebViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2020-10-28.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "IntroWebViewController.h"
#import "SafeSystemImages.h"
#import "LNPopupControllerExample-Bridging-Header.h"
@import WebKit;
@import LNPopupController;

@interface IntroWebViewController ()
{
	WKWebView* _webView;
#if !TARGET_OS_MACCATALYST
	UIView* _topColorView;
#endif
}

@end

@implementation IntroWebViewController

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_webView = [WKWebView new];
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]]];
	_webView.translatesAutoresizingMaskIntoConstraints = NO;
	_webView.allowsBackForwardNavigationGestures = YES;
//	_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	_webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
	[self.view addSubview:_webView];
	
#if !TARGET_OS_MACCATALYST
//	UIBlurEffectStyle style = UIBlurEffectStyleSystemThinMaterial;
//	_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
	_topColorView = [UIView new];
	_topColorView.backgroundColor = [UIColor colorWithRed:0.12 green:0.14 blue:0.15 alpha:1.0];
	_topColorView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_topColorView];
#endif
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.topAnchor constraintEqualToAnchor:_webView.topAnchor],
		[self.view.bottomAnchor constraintEqualToAnchor:_webView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:_webView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:_webView.trailingAnchor],
		
#if !TARGET_OS_MACCATALYST
		[self.view.topAnchor constraintEqualToAnchor:_topColorView.topAnchor],
		[self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:_topColorView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:_topColorView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:_topColorView.trailingAnchor],
#endif
	]];
	
	self.popupItem.image = [UIImage imageNamed:@"AppIconPopupBar"];
#if !TARGET_OS_MACCATALYST
	self.popupItem.barButtonItems = @[
		[[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"suit.heart.fill", LNSystemImageScaleNormal) style:UIBarButtonItemStylePlain target:self action:@selector(_navigate:)],
	];
#endif
	
	NSString* title = NSLocalizedString(@"Welcome to LNPopupController!", @"");
	
	UIFont* font;
	UIFont* emphasizedFont;
	
	if(self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomMac)
	{
		font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
		emphasizedFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	}
	else
	{
		font = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]];
		emphasizedFont = [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont systemFontOfSize:16 weight:UIFontWeightHeavy]];
	}
	
	NSMutableAttributedString* attribTitle = [[NSMutableAttributedString alloc] initWithString:title];
	[attribTitle addAttributes:@{
		NSFontAttributeName: font,
	} range:NSMakeRange(0, attribTitle.length)];
	[attribTitle addAttributes: @{
		NSFontAttributeName: emphasizedFont,
	} range:[title rangeOfString:NSLocalizedString(@"LNPopupController", @"")]];
	
	self.popupItem.attributedTitle = attribTitle;
	
	[_webView addObserver:self forKeyPath:@"themeColor" options:NSKeyValueObservingOptionNew context:NULL];
	[_webView addObserver:self forKeyPath:@"underPageBackgroundColor" options:NSKeyValueObservingOptionNew context:NULL];
	
#if !TARGET_OS_MACCATALYST
	if(@available(iOS 26.0, *))
	{
		_webView.scrollView.topEdgeEffect.hidden = YES;
		_webView.scrollView.bottomEdgeEffect.hidden = YES;
	}
#endif
}

#if TARGET_OS_MACCATALYST
- (void)viewDidMoveToPopupContainerContentView:(LNPopupContentView *)popupContentView
{
	[super viewDidMoveToPopupContainerContentView:popupContentView];
	
	LNPopupItemSetStandardMusicControls(self.popupItem, self.popupPresentationContainerViewController.popupBar, YES, NO, self.traitCollection, nil, nil, nil);
	[self setNeedsPopupButtonsUpdateAnimated:NO];
	self.popupItem.progress = (float) arc4random() / UINT32_MAX;
}

- (void)setNeedsPopupButtonsUpdateAnimated:(BOOL)animated
{
	[self.popupItem.leadingBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if([obj.accessibilityIdentifier isEqualToString:@"Shuffle"] || [obj.accessibilityIdentifier isEqualToString:@"Repeat"])
		{
			obj.hidden = self.popupPresentationContainerViewController.popupBar.effectiveContentSize.width < 600;
		}
	}];
	
	[self.popupItem.trailingBarButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if([obj.accessibilityIdentifier isEqualToString:@"Airplay"] || [obj.accessibilityIdentifier isEqualToString:@"Volume"])
		{
			obj.hidden = self.popupPresentationContainerViewController.popupBar.effectiveContentSize.width < 500;
		}
	}];
}

#endif

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//	_effectView.effect = nil;
#if !TARGET_OS_MACCATALYST
	_topColorView.backgroundColor = _webView.themeColor;
#endif
}

- (IBAction)_navigate:(id)sender
{
	[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"] options:@{} completionHandler:nil];
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
	
	_webView.scrollView.scrollIndicatorInsets = self.view.safeAreaInsets;
}

@end
