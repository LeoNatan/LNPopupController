//
//  DemoPopupContentViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 6/8/16.
//  Copyright © 2016 Leo Natan. All rights reserved.
//

#import "DemoPopupContentViewController.h"

@import LNPopupController;

@interface DemoPopupContentViewController ()
{
	BOOL _hidden;
}

@end

@implementation DemoPopupContentViewController

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
	[coordinator animateAlongsideTransitionInView:self.popupPresentationContainerViewController.view animation:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
		[self _setPopupItemButtonsWithTraitCollection:newCollection];
	} completion:nil];
	
	[super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
}

- (void)_setPopupItemButtonsWithTraitCollection:(UITraitCollection*)collection
{
	UIBarButtonItem* play = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"play"] style:UIBarButtonItemStylePlain target:nil action:NULL];
	play.accessibilityLabel = NSLocalizedString(@"Play", @"");
	play.accessibilityIdentifier = @"PlayButton";
	play.accessibilityTraits = UIAccessibilityTraitButton;
	UIBarButtonItem* next = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"nextFwd"] style:UIBarButtonItemStylePlain target:nil action:NULL];
	next.accessibilityLabel = NSLocalizedString(@"Next Track", @"");
	next.accessibilityIdentifier = @"NextButton";
	next.accessibilityTraits = UIAccessibilityTraitButton;
	
	self.popupItem.leftBarButtonItems = @[ play ];
	self.popupItem.rightBarButtonItems = @[ next ];
}

- (BOOL)prefersStatusBarHidden
{
		return _hidden || self.traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		_hidden = !_hidden;
		
		[self setNeedsStatusBarAppearanceUpdate];
	});
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
	return UIStatusBarStyleLightContent;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
	return UIStatusBarAnimationFade;//Slide;
}

@end
