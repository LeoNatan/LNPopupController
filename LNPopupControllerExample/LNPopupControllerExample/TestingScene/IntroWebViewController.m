//
//  IntroWebViewController.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2020-10-28.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import "IntroWebViewController.h"
#import "SafeSystemImages.h"
#import "LNPopupControllerExample-Bridging-Header.h"
@import WebKit;
@import LNPopupController;

@interface IntroWebViewController ()
{
	WKWebView* _webView;
	UIView* _topColorView;
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
	
//	UIBlurEffectStyle style = UIBlurEffectStyleSystemThinMaterial;
//	_effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
	_topColorView = [UIView new];
	_topColorView.backgroundColor = [UIColor colorWithRed:0.12 green:0.14 blue:0.15 alpha:1.0];
	_topColorView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_topColorView];
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.topAnchor constraintEqualToAnchor:_webView.topAnchor],
		[self.view.bottomAnchor constraintEqualToAnchor:_webView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:_webView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:_webView.trailingAnchor],
		
		[self.view.topAnchor constraintEqualToAnchor:_topColorView.topAnchor],
		[self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:_topColorView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:_topColorView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:_topColorView.trailingAnchor],
	]];
	
	self.popupItem.image = [UIImage imageNamed:@"AppIconPopupBar"];
	self.popupItem.barButtonItems = @[
		[[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"suit.heart.fill", NO) style:UIBarButtonItemStylePlain target:self action:@selector(_navigate:)],
	];
	
	NSString* title = NSLocalizedString(@"Welcome to LNPopupController!", @"");
	
	NSMutableAttributedString* attribTitle = [[NSMutableAttributedString alloc] initWithString:title];
	[attribTitle addAttributes:@{
		NSFontAttributeName: [[UIFontMetrics metricsForTextStyle:UIFontTextStyleBody] scaledFontForFont:[UIFont systemFontOfSize:15 weight:UIFontWeightMedium]],
	} range:NSMakeRange(0, attribTitle.length)];
	[attribTitle addAttributes: @{
		NSFontAttributeName: [[UIFontMetrics metricsForTextStyle:UIFontTextStyleHeadline] scaledFontForFont:[UIFont systemFontOfSize:16 weight:UIFontWeightHeavy]],
	} range:[title rangeOfString:NSLocalizedString(@"LNPopupController", @"")]];
	
	self.popupItem.attributedTitle = attribTitle;
	
	[_webView addObserver:self forKeyPath:@"themeColor" options:NSKeyValueObservingOptionNew context:NULL];
	[_webView addObserver:self forKeyPath:@"underPageBackgroundColor" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//	_effectView.effect = nil;
	_topColorView.backgroundColor = _webView.themeColor;
}

- (IBAction)_navigate:(id)sender
{
	[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"] options:@{} completionHandler:nil];
}

- (void)viewSafeAreaInsetsDidChange
{
	[super viewSafeAreaInsetsDidChange];
	
	_webView.scrollView.scrollIndicatorInsets = self.view.safeAreaInsets;
}

@end
