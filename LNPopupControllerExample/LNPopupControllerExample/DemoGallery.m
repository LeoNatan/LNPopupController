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
#import "TOInsetGroupedTableView.h"
#endif

@interface DemoGalleryControllerTableView : TOInsetGroupedTableView @end
@implementation DemoGalleryControllerTableView

- (BOOL)canBecomeFocused
{
	return NO;
}

@end

@interface DemoGalleryController : UITableViewController <
#if LNPOPUP
UIContextMenuInteractionDelegate
#endif
>
@end

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
	
	if (@available(iOS 13.0, *))
	{
		self.navigationController.popupContentView.popupCloseButton.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
	}
	
	self.navigationController.view.tintColor = self.navigationController.navigationBar.tintColor;
	self.navigationController.popupBar.barStyle = LNPopupBarStyleFloating;
	[self.navigationController presentPopupBarWithContentViewController:_demoVC animated:NO completion:nil];
	
	if (@available(iOS 13.0, *))
	{
		UIContextMenuInteraction* i = [[UIContextMenuInteraction alloc] initWithDelegate:self];
		[self.navigationController.popupBar addInteraction:i];
	}
#endif
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	if(segue.destinationViewController.modalPresentationStyle != UIModalPresentationFullScreen)
	{
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
	}
}

#pragma mark UIContextMenuInteractionDelegate

#if LNPOPUP
- (nullable UIContextMenuConfiguration *)contextMenuInteraction:(UIContextMenuInteraction *)interaction configurationForMenuAtLocation:(CGPoint)location API_AVAILABLE(ios(13.0))
{
	return [UIContextMenuConfiguration configurationWithIdentifier:nil previewProvider:nil actionProvider:nil];
}

- (void)contextMenuInteraction:(UIContextMenuInteraction *)interaction willEndForConfiguration:(UIContextMenuConfiguration *)configuration animator:(nullable id<UIContextMenuInteractionAnimating>)animator API_AVAILABLE(ios(13.0))
{
	interaction.view.userInteractionEnabled = NO;
	
	[animator addCompletion:^{
		UIActivityViewController* avc = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL URLWithString:@"https://github.com/LeoNatan/LNPopupController"]] applicationActivities:nil];
		avc.modalPresentationStyle = UIModalPresentationFormSheet;
		avc.popoverPresentationController.sourceView = self.navigationController.popupBar;
		[self presentViewController:avc animated:YES completion:nil];
		
		interaction.view.userInteractionEnabled = YES;
	}];
}
#endif

@end
