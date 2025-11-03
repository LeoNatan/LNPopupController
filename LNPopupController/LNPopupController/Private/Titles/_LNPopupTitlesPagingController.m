//
//  _LNPopupTitlesPagingController.m
//  LNPopupController
//
//  Created by Léo Natan on 16/10/25.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import "_LNPopupTitlesPagingController.h"
#import "_LNPopupTitlesController.h"
#import "LNPopupBar+Private.h"

@interface _LNPopupTitlesPagingController (PagingSupport) <UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIScrollViewDelegate>

@end

@implementation _LNPopupTitlesPagingController
{
	__weak LNPopupBar* _popupBar;
	__weak UIScrollView* _scrollView;
}

- (instancetype)initWithPopupBar:(LNPopupBar *)popupBar
{
	self = [super initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey: @8}];
	if(self)
	{
		self.delegate = self;
		_popupBar = popupBar;
		
		self.view.autoresizingMask = UIViewAutoresizingNone;
	}
	return self;
}

- (UINavigationController *)navigationController
{
	return nil;
}

- (UISplitViewController *)splitViewController
{
	return nil;
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
	_pagingEnabled = pagingEnabled;
	
	self.dataSource = pagingEnabled ? self : nil;
}

- (void)viewDidLayoutSubviews
{
	[super viewDidLayoutSubviews];
	
	_scrollView = [self valueForKey:@"scrollView"];
	
	_scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
	if(@available(iOS 26.0, *))
	{
		_scrollView.topEdgeEffect.hidden = YES;
		_scrollView.leftEdgeEffect.hidden = YES;
		_scrollView.bottomEdgeEffect.hidden = YES;
		_scrollView.rightEdgeEffect.hidden = YES;
	}
	_scrollView.delegate = self;
}

@end

@implementation _LNPopupTitlesPagingController (PagingSupport)

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	if(decelerate == NO)
	{
		[_popupBar._barDelegate _generatePagingFeedbackForPopupBar:_popupBar];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
	[_popupBar._barDelegate _generatePagingFeedbackForPopupBar:_popupBar];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	//This will allow next swipe to re-query the data source.
	self.dataSource = nil;
	if(_pagingEnabled)
	{
		self.dataSource = self;
	}
}

- (_LNPopupTitlesController*)titlesControllerBeforeAfterTitlesController:(_LNPopupTitlesController*)viewController sel:(SEL)sel
{
	__strong id<LNPopupBarDataSource> dataSource = _popupBar.dataSource;
	if(dataSource == nil)
	{
		self.pagingEnabled = NO;
		return nil;
	}
	
	LNPopupItem* prevNextItem = [dataSource performSelector:sel withObject:_popupBar withObject:_popupBar.popupItem];
	if(prevNextItem == nil)
	{
		return nil;
	}
	
	_LNPopupTitlesController* prevNextController = [[_LNPopupTitlesController alloc] initWithPopupBar:_popupBar popupItem:prevNextItem];
	prevNextController.spacing = viewController.spacing;
	[prevNextController setNeedsTitleLayoutRemovingLabels:NO];
	return prevNextController;
}

- (_LNPopupTitlesController*)pageViewController:(_LNPopupTitlesPagingController*)pageViewController viewControllerBeforeViewController:(_LNPopupTitlesController*)viewController
{
	_LNPopupTitlesController* rv = [self titlesControllerBeforeAfterTitlesController:viewController sel:@selector(popupBar:popupItemBeforePopupItem:)];
	rv.marqueePaused = YES;
	return rv;
}

- (_LNPopupTitlesController*)pageViewController:(_LNPopupTitlesPagingController*)pageViewController viewControllerAfterViewController:(_LNPopupTitlesController*)viewController
{
	_LNPopupTitlesController* rv = [self titlesControllerBeforeAfterTitlesController:viewController sel:@selector(popupBar:popupItemAfterPopupItem:)];
	rv.marqueePaused = YES;
	return rv;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<_LNPopupTitlesController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
	_LNPopupTitlesController* newCurrent = self.viewControllers.firstObject;
	_LNPopupTitlesController* old = previousViewControllers.firstObject;
	newCurrent.marqueePaused = old.marqueePaused;
	[_popupBar._barDelegate _popupBar:_popupBar setPagedPopupItem:newCurrent.popupItem];
}

@end
