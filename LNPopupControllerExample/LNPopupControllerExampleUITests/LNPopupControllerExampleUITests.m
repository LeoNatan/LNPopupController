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

@end

@implementation LNPopupControllerExampleUITests

- (void)setUp {
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // In UI tests it is usually best to stop immediately when a failure occurs.
    self.continueAfterFailure = NO;
    // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
    [[[XCUIApplication alloc] init] launch];
    
    // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)_openCustomizationsAndRestForApp:(XCUIApplication*)app
{
	[app.navigationBars[@"LNPopupController"].buttons[@"Item"] tap];
	
	XCUIElement *settingsNavigationBar = app.navigationBars[@"Settings"];
	[settingsNavigationBar.buttons[@"Reset"] tap];
}

- (void)_closeCustomizationsForApp:(XCUIApplication*)app
{
	XCUIElement *settingsNavigationBar = app.navigationBars[@"Settings"];
	[settingsNavigationBar.buttons[@"Done"] tap];
}

- (void)_resetCustomizationsForApp:(XCUIApplication*)app
{
	[self _openCustomizationsAndRestForApp:app];
	[self _closeCustomizationsForApp:app];
}

- (void)_openPopupWithSwipeForApp:(XCUIApplication*)app
{
	[app.buttons[@"PopupBarView"] swipeUp];
}

- (void)_openPopupWithTapForApp:(XCUIApplication*)app
{
	[app.buttons[@"PopupBarView"] forceTap];
}

- (void)_closePopupWithSwipeForApp:(XCUIApplication*)app
{
	XCUICoordinate* coord1 = [app coordinateWithNormalizedOffset:CGVectorMake(0.5, 0.5)];
	XCUICoordinate* coord2 = [coord1 coordinateWithOffset:CGVectorMake(0, 400)];
	[coord1 pressForDuration:0 thenDragToCoordinate:coord2];
}

- (void)_closePopupWithCloseButtonTapForApp:(XCUIApplication*)app
{
	[app.buttons[@"Close"] tap];
}

- (void)_setupForSanityTestingForApp:(XCUIApplication*)app
{
	[self _resetCustomizationsForApp:app];
	
	[app.tables.cells.staticTexts[@"Tab Bar Controller + Navigation Controller"] tap];
}

- (void)testPopupBarOpensBySwipeClosesBySwipe
{
	XCUIApplication *app = [[XCUIApplication alloc] init];
	
	[self _setupForSanityTestingForApp:app];
	
	[self _openPopupWithSwipeForApp:app];
	[self _closePopupWithSwipeForApp:app];
	
	XCTAssert(app.buttons[@"Gallery"].isHittable);
}

- (void)testPopupBarOpensBySwipeClosesByButtonTap
{
	XCUIApplication *app = [[XCUIApplication alloc] init];
	
	[self _setupForSanityTestingForApp:app];
	
	[self _openPopupWithSwipeForApp:app];
	[self _closePopupWithCloseButtonTapForApp:app];
	
	XCTAssert(app.buttons[@"Gallery"].isHittable);
}

- (void)testPopupBarOpensByTapClosesBySwipe
{
	XCUIApplication *app = [[XCUIApplication alloc] init];
	
	[self _setupForSanityTestingForApp:app];
	
	[self _openPopupWithTapForApp:app];
	[self _closePopupWithSwipeForApp:app];
	
	XCTAssert(app.buttons[@"Gallery"].isHittable);
}

- (void)testPopupBarOpensByTapClosesByButtonTap
{
	XCUIApplication *app = [[XCUIApplication alloc] init];
	
	[self _setupForSanityTestingForApp:app];
	
	[self _openPopupWithTapForApp:app];
	[self _closePopupWithCloseButtonTapForApp:app];
	
	XCTAssert(app.buttons[@"Gallery"].isHittable);
}

@end
