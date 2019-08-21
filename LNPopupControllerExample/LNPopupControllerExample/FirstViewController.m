//
//  FirstViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 7/16/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import LNPopupController;
#import "FirstViewController.h"
#import "DemoPopupContentViewController.h"
#import "LoremIpsum.h"
#import "RandomColors.h"
#import "SettingsTableViewController.h"
@import UIKit;

@interface TabBar : UITabBar @end
@implementation TabBar

- (void)setFrame:(CGRect)frame
{
//	NSLog(@"🤦‍♂️ frame: %@ safe area: %@", @(frame), [self valueForKey:@"safeAreaInsets"]);

	[super setFrame:frame];
}

@end

@interface UIViewController ()

- (id)_segueTemplateWithIdentifier:(id)arg1;

@end

@interface NSObject ()

- (id)instantiateOrFindDestinationViewControllerWithSender:(id)arg1;

@end

@interface DemoGalleryController : UITableViewController @end
@implementation DemoGalleryController

- (IBAction)unwindToGallery:(UIStoryboardSegue *)unwindSegue { }

- (nullable UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point API_AVAILABLE(ios(13.0))
{
	return [UIContextMenuConfiguration configurationWithIdentifier:@"Preview" previewProvider:^ UIViewController* {
		NSString* cellIdentifier = [tableView cellForRowAtIndexPath:indexPath].reuseIdentifier;
		id segueTemplate = [self _segueTemplateWithIdentifier:cellIdentifier];
		return [segueTemplate instantiateOrFindDestinationViewControllerWithSender:self];;
	} actionProvider:nil];
}

- (void)tableView:(UITableView *)tableView willPerformPreviewActionForMenuWithConfiguration:(UIContextMenuConfiguration *)configuration animator:(id<UIContextMenuInteractionCommitAnimating>)animator API_AVAILABLE(ios(13.0))
{
	UIViewController* vc = animator.previewViewController;
	
	[animator addCompletion:^{
		[self presentViewController:vc animated:YES completion:nil];
	}];
}

@end

@interface FirstViewController () <UIContextMenuInteractionDelegate>

@end

@implementation FirstViewController
{
	__weak IBOutlet UIButton *_galleryButton;
	__weak IBOutlet UIButton *_nextButton;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if (@available(iOS 13.0, *)) {
		self.view.backgroundColor = LNRandomAdaptiveColor();
	} else {
		self.view.backgroundColor = LNRandomLightColor();
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	//Ugly hack to fix tab bar tint color.
	self.tabBarController.view.tintColor = self.view.tintColor;
	//Ugly hack to fix split view controller tint color.
	self.splitViewController.view.tintColor = self.view.tintColor;
	
	_galleryButton.hidden = [self.parentViewController isKindOfClass:[UINavigationController class]];
	_nextButton.hidden = self.splitViewController != nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	[self _presentBar:nil];
}

- (IBAction)_changeBarStyle:(id)sender
{
	self.navigationController.toolbar.barStyle = 1 - self.navigationController.toolbar.barStyle;
	
	UIColor* adaptiveColor;
	if (@available(iOS 13.0, *)) {
		adaptiveColor = LNRandomAdaptiveInvertedColor();
	} else {
		adaptiveColor = LNRandomDarkColor();
	}
	
	self.navigationController.toolbar.tintColor = self.navigationController.toolbar.barStyle ? LNRandomLightColor() : adaptiveColor;
	[self.navigationController.toolbar.items enumerateObjectsUsingBlock:^(UIBarButtonItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		obj.tintColor = self.navigationController.toolbar.tintColor;
	}];
	self.navigationController.navigationBar.barStyle = self.navigationController.toolbar.barStyle;
	self.navigationController.navigationBar.tintColor = self.navigationController.toolbar.tintColor;
	
	[self.navigationController updatePopupBarAppearance];
}

- (IBAction)_presentBar:(id)sender
{
	//All this logic is just so I can use the same controllers over and over in all examples. :-)
	
	if(sender == nil &&
	   self.navigationController == nil &&
	   self.splitViewController != nil &&
	   self != self.splitViewController.viewControllers.firstObject)
	{
		return;
	}
	
	UIViewController* targetVC = self.navigationController == nil ? self.splitViewController : nil;
	
	if(targetVC == nil)
	{
		targetVC = self.tabBarController;
		if(targetVC == nil)
		{
			targetVC = self.navigationController;
			
			if(targetVC == nil)
			{
				targetVC = self;
			}
		}
	}
	
	if(targetVC.popupContentViewController != nil)
	{
		return;
	}
	
	if(targetVC == self.navigationController && self.navigationController.viewControllers.count > 1 && self.splitViewController == nil)
	{
		return;
	}
	
//	UIViewController* demoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsTableViewController"];
	UIViewController* demoVC = [DemoPopupContentViewController new];
	
	if (@available(iOS 13.0, *)) {
		demoVC.view.backgroundColor = LNRandomAdaptiveInvertedColor();
	} else {
		demoVC.view.backgroundColor = LNRandomDarkColor();
	}
	
	if([NSUserDefaults.standardUserDefaults boolForKey:@"NSForceRightToLeftWritingDirection"])
	{
		demoVC.popupItem.title = @"עברית";//[LoremIpsum sentence];
		demoVC.popupItem.subtitle = @"עברית";//[LoremIpsum sentence];
	}
	else
	{
		demoVC.popupItem.title = [LoremIpsum sentence];
		demoVC.popupItem.subtitle = [LoremIpsum sentence];
	}
	demoVC.popupItem.image = [UIImage imageNamed:@"genre7"];
	demoVC.popupItem.progress = (float) arc4random() / UINT32_MAX;
	
	UILabel* topLabel = [UILabel new];
	topLabel.text = NSLocalizedString(@"Top", @"");
	if (@available(iOS 13.0, *)) {
		topLabel.textColor = [UIColor systemBackgroundColor];
	} else {
		topLabel.textColor = [UIColor whiteColor];
	}
	topLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	topLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[demoVC.view addSubview:topLabel];
	[NSLayoutConstraint activateConstraints:@[[topLabel.topAnchor constraintEqualToAnchor:demoVC.topLayoutGuide.bottomAnchor],
											  [topLabel.centerXAnchor constraintEqualToAnchor:demoVC.view.centerXAnchor constant:40]]];
	
	UILabel* bottomLabel = [UILabel new];
	bottomLabel.text = NSLocalizedString(@"Bottom", @"");
	if (@available(iOS 13.0, *)) {
		bottomLabel.textColor = [UIColor systemBackgroundColor];
	} else {
		bottomLabel.textColor = [UIColor whiteColor];
	}
	bottomLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
	bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[demoVC.view addSubview:bottomLabel];
	[NSLayoutConstraint activateConstraints:@[[bottomLabel.bottomAnchor constraintEqualToAnchor:demoVC.bottomLayoutGuide.topAnchor],
											  [bottomLabel.centerXAnchor constraintEqualToAnchor:demoVC.view.centerXAnchor]]];
	
	demoVC.popupItem.accessibilityLabel = NSLocalizedString(@"Custom popup bar accessibility label", @"");
	demoVC.popupItem.accessibilityHint = NSLocalizedString(@"Custom popup bar accessibility hint", @"");
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
//	targetVC.popupBar.previewingDelegate = self;
	targetVC.popupBar.progressViewStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsProgressViewStyle] unsignedIntegerValue];
	targetVC.popupBar.barStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsBarStyle] unsignedIntegerValue];
	targetVC.popupInteractionStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsInteractionStyle] unsignedIntegerValue];
	targetVC.popupContentView.popupCloseButtonStyle = [[[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsCloseButtonStyle] unsignedIntegerValue];
	
	NSNumber* marqueeEnabledSetting = [[NSUserDefaults standardUserDefaults] objectForKey:PopupSettingsMarqueeStyle];
	if(marqueeEnabledSetting && [marqueeEnabledSetting isEqualToNumber:@0] == NO)
	{
		targetVC.popupBar.marqueeScrollEnabled = [marqueeEnabledSetting unsignedIntegerValue] - 1;
	}
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:PopupSettingsEnableCustomizations])
	{
		NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
		paragraphStyle.alignment = NSTextAlignmentRight;
		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
		
		[targetVC.popupBar setTitleTextAttributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:14], NSForegroundColorAttributeName: [UIColor yellowColor]}];
		[targetVC.popupBar setSubtitleTextAttributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:12], NSForegroundColorAttributeName: [UIColor greenColor]}];
		[targetVC.popupBar setBackgroundStyle:UIBlurEffectStyleDark];
		[targetVC.popupBar setTintColor:[UIColor yellowColor]];
	}
	
	if (@available(iOS 13.0, *))
	{
		UIContextMenuInteraction* i = [[UIContextMenuInteraction alloc] initWithDelegate:self];
		[targetVC.popupBar addInteraction:i];
	}

	[targetVC presentPopupBarWithContentViewController:demoVC animated:YES completion:nil];
}

- (IBAction)_dismissBar:(id)sender
{
	__kindof UIViewController* targetVC = self.tabBarController;
	if(targetVC == nil)
	{
		targetVC = self.navigationController;
		
		if(targetVC == nil)
		{
			targetVC = self;
		}
	}
	
	[targetVC dismissPopupBarAnimated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	[segue.destinationViewController setHidesBottomBarWhenPushed:YES];
}

#pragma mark UIContextMenuInteractionDelegate

- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location API_AVAILABLE(ios(13.0))
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:nil];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willEndForConfiguration:(UIContextMenuConfiguration *)configuration animator:(nullable id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(13.0))
{
	[animator addCompletion:^{
		UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]] applicationActivities:nil];
		avc.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:avc animated:YES completion:nil];
	}];
}

@end
