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

@interface DemoGalleryController : UITableViewController @end
@implementation DemoGalleryController

- (IBAction)unwindToGallery:(UIStoryboardSegue *)unwindSegue
{
	//No-op
}

@end

@interface FirstViewController () <LNPopupBarPreviewingDelegate>

@end

@implementation FirstViewController
{
	__weak IBOutlet UIButton *_galleryButton;
	__weak IBOutlet UIButton *_nextButton;
}

// TODO: Uncomment this code to demonstrate popup bar customization

//+ (void)load
//{
//	static dispatch_once_t onceToken;
//	dispatch_once(&onceToken, ^{
//		NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//		paragraphStyle.alignment = NSTextAlignmentRight;
//		paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
//		
//		[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UIViewController class]]] setTitleTextAttributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:14], NSForegroundColorAttributeName: [UIColor yellowColor]}];
//		[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UIViewController class]]] setSubtitleTextAttributes:@{NSParagraphStyleAttributeName: paragraphStyle, NSFontAttributeName: [UIFont fontWithName:@"Chalkduster" size:12], NSForegroundColorAttributeName: [UIColor greenColor]}];
//		[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UIViewController class]]] setBackgroundStyle:UIBlurEffectStyleDark];
//		[[LNPopupBar appearanceWhenContainedInInstancesOfClasses:@[[UIViewController class]]] setTintColor:[UIColor yellowColor]];
//	});
//}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.view.backgroundColor = LNRandomLightColor();

// TODO: Uncomment this code to demonstrate disabling the popup close button.
	
//	self.navigationController.popupContentView.popupCloseButtonStyle = LNPopupCloseButtonStyleNone;
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
	self.navigationController.toolbar.tintColor = self.navigationController.toolbar.barStyle ? LNRandomLightColor() : self.view.tintColor;
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
	
	DemoPopupContentViewController* demoVC = [DemoPopupContentViewController new];
	demoVC.view.backgroundColor = LNRandomDarkColor();
	demoVC.popupItem.title = [LoremIpsum sentence];
	demoVC.popupItem.subtitle = [LoremIpsum sentence];
	demoVC.popupItem.image = [UIImage imageNamed:@"genre7"];
	demoVC.popupItem.progress = (float) arc4random() / UINT32_MAX;
	
	demoVC.popupItem.accessibilityLabel = NSLocalizedString(@"Custom popup bar accessibility label", @"");
	demoVC.popupItem.accessibilityHint = NSLocalizedString(@"Custom popup bar accessibility hint", @"");
	
	targetVC.popupContentView.popupCloseButton.accessibilityLabel = NSLocalizedString(@"Custom popup button accessibility label", @"");
	targetVC.popupContentView.popupCloseButton.accessibilityHint = NSLocalizedString(@"Custom popup button accessibility hint", @"");
	
	targetVC.popupBar.previewingDelegate = self;
	
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

#pragma mark LNPopupBarPreviewingDelegate

- (UIViewController *)previewingViewControllerForPopupBar:(LNPopupBar*)popupBar
{
	UIBlurEffect* blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
	
	UIViewController* vc = [UIViewController new];
	vc.view = [[UIVisualEffectView alloc] initWithEffect:blur];
	vc.view.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.0];
	vc.preferredContentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height / 2);
	
	UILabel* label = [UILabel new];
	label.text = @"Hello from\n3D Touch!";
	label.numberOfLines = 0;
	label.textColor = [UIColor blackColor];
	label.font = [UIFont systemFontOfSize:50 weight:UIFontWeightBlack];
	[label sizeToFit];
	label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
	
	UIVisualEffectView* vib = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:blur]];
	vib.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	[vib.contentView addSubview:label];
	
	[[(UIVisualEffectView*)vc.view contentView] addSubview:vib];
	
	return vc;
}

@end
