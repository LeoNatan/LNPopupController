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
		return [LNPopupDemoContextMenuInteraction menuWithTitle:self->_includeTitle sourceItemForShare:self.view];
	}];
}

+ (UIMenu*)menuWithTitle:(BOOL)includeTitle sourceItemForShare:(NSObject<UIPopoverPresentationControllerSourceItem>*)sourceItemForShare
{
	UIAction* link = [UIAction actionWithTitle:NSLocalizedString(@"Visit GitHub Page", @"") image:[UIImage systemImageNamed:@"safari"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"] options:@{} completionHandler:nil];
	}];
#if defined(__IPHONE_27_0)
	if(@available(iOS 27.0, *))
	{
		link.preferredImageVisibility = UIMenuElementImageVisibilityVisible;
	}
#endif
	
	UIAction* report = [UIAction actionWithTitle:NSLocalizedString(@"Report an Issue…", @"") image:[UIImage systemImageNamed:@"ladybug.fill"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		[UIApplication.sharedApplication openURL:[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController/issues/new/choose"] options:@{} completionHandler:nil];
	}];
#if defined(__IPHONE_27_0)
	if(@available(iOS 27.0, *))
	{
		report.preferredImageVisibility = UIMenuElementImageVisibilityVisible;
	}
#endif
	
	UIAction* share = [UIAction actionWithTitle:NSLocalizedString(@"Share…", @"") image:[UIImage systemImageNamed:@"square.and.arrow.up"] identifier:nil handler:^(__kindof UIAction * _Nonnull action) {
		UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]] applicationActivities:nil];
		avc.modalPresentationStyle = UIModalPresentationPopover;
		avc.popoverPresentationController.sourceItem = sourceItemForShare;
		
		UIViewController* presentingController;
		if([sourceItemForShare isKindOfClass:UIView.class])
		{
			presentingController = [sourceItemForShare valueForKeyPath:@"viewControllerForAncestor"];
		}
		else if([sourceItemForShare isKindOfClass:UIBarButtonItem.class])
		{
			UIView* view = [sourceItemForShare valueForKey:@"view"];
			presentingController = [view valueForKeyPath:@"viewControllerForAncestor"];
		}
		
		[presentingController presentViewController:avc animated:YES completion:nil];
	}];
#if defined(__IPHONE_27_0)
	if(@available(iOS 27.0, *))
	{
		report.preferredImageVisibility = UIMenuElementImageVisibilityVisible;
	}
#endif
	
	return [UIMenu menuWithTitle: includeTitle ? @"LNPopupController" : @"" children:@[
		[UIMenu menuWithTitle:@"" image:nil identifier:nil options:UIMenuOptionsDisplayInline children:@[
			link,
			report
		]],
		share,
	]];
}

@end
