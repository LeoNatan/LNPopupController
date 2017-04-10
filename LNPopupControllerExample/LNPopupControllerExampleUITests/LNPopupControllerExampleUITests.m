//
//  LNPopupControllerExampleUITests.m
//  LNPopupControllerExampleUITests
//
//  Created by Leo Natan (Wix) on 10/04/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface XCUIElement (LNPopup)

- (void)forceTap;

@end

@implementation XCUIElement (LNPopup)

- (void)forceTap
{
	if(self.isHittable)
	{
		[self tap];
	}
	else
	{
		XCUICoordinate* coord = [self coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
		[coord tap];
	}
}

@end

@interface LNPopupControllerExampleUITests : XCTestCase
{
	XCUIApplication* app;
}

@end

@implementation LNPopupControllerExampleUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
	app = [XCUIApplication new];
	
    [app launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)_openCustomizationsAndReset
{
	[app.navigationBars[@"LNPopupController"].buttons[@"Item"] tap];
	
	XCUIElement *settingsNavigationBar = app.navigationBars[@"Settings"];
	[settingsNavigationBar.buttons[@"Reset"] tap];
}

- (void)_closeCustomizations
{
	XCUIElement *settingsNavigationBar = app.navigationBars[@"Settings"];
	[settingsNavigationBar.buttons[@"Done"] tap];
}

- (void)_resetCustomizations
{
	[self _openCustomizationsAndReset];
	 [self _closeCustomizations];
}

- (void)_openPopupWithSwipe
{
	[app.buttons[@"PopupBarView"] swipeUp];
}

- (void)_openPopupWithTap
{
	[app.buttons[@"PopupBarView"] forceTap];
}

- (void)_closePopupWithSwipe
{
	XCUICoordinate* coord1 = [app coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
	XCUICoordinate* coord2 = [coord1 coordinateWithOffset:CGVectorMake(0, 400)];
	[coord1 pressForDuration:0 thenDragToCoordinate:coord2];
}

- (void)_closePopupWithCloseButtonTap
{
	[app.buttons[@"Close"] tap];
}

- (void)_setupForSanityTesting
{
	[self _resetCustomizations];
	
	[app.tables.cells.staticTexts[@"Tab Bar Controller + Navigation Controller"] tap];
}

- (void)_makeFinalAssertion
{
	XCTAssert(app.buttons[@"Next ▸"].isHittable);
}

- (void)testPopupBarOpensBySwipeClosesBySwipe
{
	[self _setupForSanityTesting];
	
	[self _openPopupWithSwipe];
	[self _closePopupWithSwipe];
	
	[self _makeFinalAssertion];
}

- (void)testPopupBarOpensBySwipeClosesByButtonTap
{
	[self _setupForSanityTesting];
	
	[self _openPopupWithSwipe];
	[self _closePopupWithCloseButtonTap];
	
	[self _makeFinalAssertion];
}

- (void)testPopupBarOpensByTapClosesBySwipe
{
	[self _setupForSanityTesting];
	
	[self _openPopupWithTap];
	[self _closePopupWithSwipe];
	
	[self _makeFinalAssertion];
}

- (void)testPopupBarOpensByTapClosesByButtonTap
{
	[self _setupForSanityTesting];
	
	[self _openPopupWithTap];
	[self _closePopupWithCloseButtonTap];
	
	[self _makeFinalAssertion];
}

@end
