//
//  IntroWebViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 10/28/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "IntroWebViewController.h"
@import WebKit;
@import LNPopupController;

extern UIImage* LNSystemImage(NSString* named);

@interface IntroWebViewController ()
{
	WKWebView* _webView;
}

@end

@implementation IntroWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	_webView = [WKWebView new];
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]]];
	_webView.translatesAutoresizingMaskIntoConstraints = NO;
//	_webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
	_webView.scrollView.automaticallyAdjustsScrollIndicatorInsets = NO;
	[self.view addSubview:_webView];
	
	UIBlurEffectStyle style = UIBlurEffectStyleSystemThinMaterial;
	UIVisualEffectView* effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:style]];
	effectView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:effectView];
	
	[NSLayoutConstraint activateConstraints:@[
		[self.view.topAnchor constraintEqualToAnchor:_webView.topAnchor],
		[self.view.bottomAnchor constraintEqualToAnchor:_webView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:_webView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:_webView.trailingAnchor],
		
		[self.view.topAnchor constraintEqualToAnchor:effectView.topAnchor],
		[self.view.safeAreaLayoutGuide.topAnchor constraintEqualToAnchor:effectView.bottomAnchor],
		[self.view.leadingAnchor constraintEqualToAnchor:effectView.leadingAnchor],
		[self.view.trailingAnchor constraintEqualToAnchor:effectView.trailingAnchor],
	]];
	
	NSString* title = @"Welcome to LNPopupController!";
	
	NSMutableAttributedString* attribTitle = [[NSMutableAttributedString alloc] initWithString:title];
	[attribTitle addAttributes: @{
		NSFontAttributeName: [UIFont systemFontOfSize:18 weight:UIFontWeightHeavy],
	} range:[title rangeOfString:@"LNPopupController"]];
	
	self.popupItem.attributedTitle = attribTitle;
	self.popupItem.image = [UIImage imageNamed:@"genre10"];
	self.popupItem.barButtonItems = @[
		[[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"suit.heart.fill") style:UIBarButtonItemStylePlain target:self action:@selector(_navigate:)],
	];
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
