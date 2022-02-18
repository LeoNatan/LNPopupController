//
//  LNPopupDemoContextMenuInteraction.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 12/17/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "LNPopupDemoContextMenuInteraction.h"
@import SafariServices;

@interface LNPopupDemoContextMenuInteraction () <UIContextMenuInteractionDelegate>

@end

@implementation LNPopupDemoContextMenuInteraction

- (instancetype)init
{
	return [super initWithDelegate:self];
}

+ (instancetype)new
{
	return [[self alloc] init];
}

#pragma mark UIContextMenuInteractionDelegate

- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil  actionProvider:^UIMenu * _Nullable(NSArray<UIMenuElement *> * _Nonnull suggestedActions) {
		return [UIMenu menuWithTitle:@"" children:@[
			[UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[
				[UIAction actionWithTitle:@"Visit GitHub Page" image:[UIImage systemImageNamed:@"safari"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
				 {
					[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"] options:@{} completionHandler:nil];
				}],
				[UIAction actionWithTitle:@"Report an Issue…" image:[UIImage systemImageNamed:@"ant.fill"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
				 {
					[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController/issues/new/choose"] options:@{} completionHandler:nil];
				}]
			]],
			[UIAction actionWithTitle:@"Share…" image:[UIImage systemImageNamed:@"square.and.arrow.up"] identifier:nil handler:^(__kindof UIAction * _Nonnull action)
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
