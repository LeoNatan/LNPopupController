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
	self.navigationController.popupContentView.popupCloseButton.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
#endif
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
#if LNPOPUP
	self.navigationController.view.tintColor = self.navigationController.navigationBar.tintColor;
	[self.navigationController presentPopupBarWithContentViewController:_demoVC animated:YES completion:nil];
	
	[self.navigationController.popupBar addInteraction:[LNPopupDemoContextMenuInteraction new]];
#endif
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if(segue.destinationViewController.modalPresentationStyle != UIModalPresentationFullScreen)
	{
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
#if !TARGET_OS_MACCATALYST
	if(((indexPath.section == 0 && indexPath.row > 3) || indexPath.section > 0) && NSProcessInfo.processInfo.operatingSystemVersion.majorVersion < 13)
	{
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
		
		UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"The “%@” scene requires iOS 13 and above.", cell.textLabel.text] preferredStyle:UIAlertControllerStyleAlert];
		[alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
		
		[self presentViewController:alert animated:YES completion:nil];
		
		return NO;
	}
#endif
	
	return YES;
}

@end
