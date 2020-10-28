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
	[self.view addSubview:_webView];
	
	UIBlurEffectStyle style;
	if (@available(iOS 13.0, *)) {
		style = UIBlurEffectStyleSystemChromeMaterial;
	} else {
		style = UIBlurEffectStyleProminent;
	}
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
	
	self.popupItem.title = @"Welcome to LNPopupController!";
	self.popupItem.image = [UIImage imageNamed:@"genre10"];
	self.popupItem.barButtonItems = @[
		[[UIBarButtonItem alloc] initWithImage:LNSystemImage(@"suit.heart.fill") style:UIBarButtonItemStylePlain target:nil action:nil],
	];
}

@end
