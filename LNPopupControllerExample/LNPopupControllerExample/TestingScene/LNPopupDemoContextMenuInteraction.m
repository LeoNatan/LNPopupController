//
//  LNPopupDemoContextMenuInteraction.m
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2021-12-17.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "LNPopupDemoContextMenuInteraction.h"
#import "IntroWebViewController.h"

@interface LNPopupDemoContextMenuInteraction () <UIContextMenuInteractionDelegate>

@end

@implementation LNPopupDemoContextMenuInteraction
{
	BOOL _includeTitle;
}

- (instancetype)init
{
	return [self initWithTitle:NO];
}

- (instancetype)initWithTitle:(BOOL)title
{
	self = [super initWithDelegate:self];
	
	if(self)
	{
		_includeTitle = title;
	}
	
	return self;
}

+ (instancetype)new
{
	return [[self alloc] init];
}

#pragma mark UIContextMenuInteractionDelegate

- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
		return [UIMenu menuWithTitle: self->_includeTitle ? @"LNPopupController" : @"" children:@[
			[UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[
				[UIAction actionWithTitle:NSLocalizedString(@"Visit GitHub Page", @"") image:[UIImage systemImageNamed:@"safari"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
				 {
					[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"] options:@{} completionHandler:nil];
				}],
				[UIAction actionWithTitle:NSLocalizedString(@"Report an Issue…", @"") image:[UIImage systemImageNamed:@"ant.fill"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
				 {
					[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController/issues/new/choose"] options:@{} completionHandler:nil];
				}]
			]],
			[UIAction actionWithTitle:NSLocalizedString(@"Share…", @"") image:[UIImage systemImageNamed:@"square.and.arrow.up"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
			 {
				UIView* popupBar = [action valueForKeyPath:@"sender.view"];
				UIViewController* presentingController = [popupBar valueForKeyPath:@"viewControllerForAncestor"];
				UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]] applicationActivities:nil];
				avc.modalPresentationStyle = UIModalPresentationFormSheet;
				avc.popoverPresentationController.sourceView = popupBar;
				[presentingController presentViewController:avc animated:YES completion:nil];
			}],
		]];
	}];
}

@end
