//
//  DemoGallery.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 11/1/20.
//  Copyright © 2020 Leo Natan. All rights reserved.
//

#import "DemoGallery.h"

#if LNPOPUP
@import LNPopupController;
#import "IntroWebViewController.h"
#import "LNPopupDemoContextMenuInteraction.h"
#endif

@interface DemoGalleryToolbar : UIToolbar @end
@implementation DemoGalleryToolbar @end

@interface SizeClassGalleryCell : UITableViewCell

@property (nonatomic, getter=isEnabled) BOOL enabled;

@end

@implementation SizeClassGalleryCell

-(void)setEnabled:(BOOL)enabled
{
	if(enabled)
	{
		self.textLabel.textColor = UIColor.labelColor;
		self.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
	else
	{
		self.textLabel.textColor = UIColor.secondaryLabelColor;
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	}
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection
{
	[super traitCollectionDidChange:previousTraitCollection];
	
	[self setEnabled:self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassRegular];
}

@end

@import SafariServices;

@interface DemoGalleryController : UITableViewController@end
@implementation DemoGalleryController
{
#if LNPOPUP
	IntroWebViewController* _demoVC;
#endif
}

- (IBAction)unwindToGallery:(UIStoryboardSegue *)unwindSegue { }

- (void)viewDidLoad
{
	[super viewDidLoad];
	
#if LNPOPUP
	_demoVC = [IntroWebViewController new];
	
	self.navigationController.popupBar.barStyle = LNPopupBarStyleFloating;
	self.navigationController.popupBar.standardAppearance.marqueeScrollDelay = 0.0;
	self.navigationController.popupBar.standardAppearance.marqueeScrollEnabled = YES;

	self.navigationController.view.tintColor = self.navigationController.navigationBar.tintColor;
	[self.navigationController presentPopupBarWithContentViewController:_demoVC animated:NO completion:nil];
	
	[self.navigationController.popupBar addInteraction:[LNPopupDemoContextMenuInteraction new]];
#endif
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
	if([identifier hasPrefix:@"split"] && self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact)
	{
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
		
		return NO;
	}
	
	return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if(segue.destinationViewController.modalPresentationStyle != UIModalPresentationFullScreen)
	{
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
}

@end
