//
//  SettingsTableViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "SettingsTableViewController.h"

@import LNTouchVisualizer;

NSString* const PopupSettingsBarStyle = @"PopupSettingsBarStyle";
NSString* const PopupSettingsInteractionStyle = @"PopupSettingsInteractionStyle";
NSString* const PopupSettingsProgressViewStyle = @"PopupSettingsProgressViewStyle";
NSString* const PopupSettingsCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
NSString* const PopupSettingsMarqueeStyle = @"PopupSettingsMarqueeStyle";
NSString* const PopupSettingsEnableCustomizations = @"PopupSettingsEnableCustomizations";
NSString* const PopupSettingsExtendBar = @"PopupSettingsExtendBar";
NSString* const PopupSettingsHidesBottomBarWhenPushed = @"PopupSettingsHidesBottomBarWhenPushed";
NSString* const PopupSettingsVisualEffectViewBlurEffect = @"PopupSettingsVisualEffectViewBlurEffect";
NSString* const PopupSettingsTouchVisualizerEnabled = @"PopupSettingsTouchVisualizerEnabled";
NSString* const PopupSettingsCustomBarEverywhereEnabled = @"PopupSettingsCustomBarEverywhereEnabled";

@interface SettingsTableViewController ()
{
	NSDictionary<NSNumber*, NSString*>* _sectionToKeyMapping;
	NSArray* _sectionsToSkip0xFFFF;
	
	IBOutlet UISwitch* _customizations;
	IBOutlet UISwitch* _extendBars;
	IBOutlet UISwitch* _hidesBottomBarWhenPushed;
	IBOutlet UISwitch* _touchVisualizer;
	IBOutlet UISwitch* _customBar;
}

@end

@implementation SettingsTableViewController

+ (void)load
{
	[NSUserDefaults.standardUserDefaults registerDefaults:@{PopupSettingsExtendBar: @YES, PopupSettingsHidesBottomBarWhenPushed: @YES}];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	_sectionToKeyMapping = @{
		@0: PopupSettingsBarStyle,
		@1: PopupSettingsInteractionStyle,
		@2: PopupSettingsProgressViewStyle,
		@3: PopupSettingsCloseButtonStyle,
		@4: PopupSettingsMarqueeStyle,
		@5: PopupSettingsVisualEffectViewBlurEffect,
		@6: PopupSettingsVisualEffectViewBlurEffect,
		@7: PopupSettingsVisualEffectViewBlurEffect,
		@8: PopupSettingsVisualEffectViewBlurEffect,
	};
	
	_sectionsToSkip0xFFFF = @[@0];
	
	[self _resetSwitchesAnimated:NO];
}

- (void)_resetSwitchesAnimated:(BOOL)animated
{
	[_customizations setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsEnableCustomizations] animated:animated];
	[_extendBars setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsExtendBar] animated:animated];
	[_hidesBottomBarWhenPushed setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsHidesBottomBarWhenPushed] animated:animated];
	[_touchVisualizer setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsTouchVisualizerEnabled] animated:animated];
	[_customBar setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsCustomBarEverywhereEnabled] animated:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	NSString* key = _sectionToKeyMapping[@(indexPath.section)];
	if(key != nil)
	{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.accessoryView = nil;
		cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
		if(key == PopupSettingsVisualEffectViewBlurEffect)
		{
			NSNumber* effectStyle = [NSUserDefaults.standardUserDefaults objectForKey:PopupSettingsVisualEffectViewBlurEffect];
			if((cell.tag == -1 && effectStyle == nil) || (effectStyle != nil && cell.tag == effectStyle.integerValue + 10))
			{
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
		else
		{
			NSUInteger lastIdxInSection = [tableView numberOfRowsInSection:indexPath.section] - 1;
			NSUInteger value = [[NSUserDefaults.standardUserDefaults objectForKey:key] unsignedIntegerValue];
			if(value == 0xFFFF)
			{
				value = lastIdxInSection;
			}
			
			if(indexPath.row == value)
			{
				cell.accessoryType = UITableViewCellAccessoryCheckmark;
			}
		}
	}
	
	return cell;
}

- (IBAction)_resetButtonTapped:(UIBarButtonItem *)sender
{
	[NSUserDefaults.standardUserDefaults setBool:NO forKey:PopupSettingsEnableCustomizations];
	[NSUserDefaults.standardUserDefaults setBool:YES forKey:PopupSettingsExtendBar];
	[NSUserDefaults.standardUserDefaults setBool:YES forKey:PopupSettingsHidesBottomBarWhenPushed];
	[NSUserDefaults.standardUserDefaults setBool:NO forKey:PopupSettingsTouchVisualizerEnabled];
	[NSUserDefaults.standardUserDefaults setBool:NO forKey:PopupSettingsCustomBarEverywhereEnabled];
	self.view.window.windowScene.touchVisualizerEnabled = [NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsTouchVisualizerEnabled];
	
	[NSUserDefaults.standardUserDefaults removeObjectForKey:PopupSettingsVisualEffectViewBlurEffect];
	
	[_sectionToKeyMapping enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
		if(obj == PopupSettingsVisualEffectViewBlurEffect)
		{
			return;
		}
		
		[NSUserDefaults.standardUserDefaults setObject:@0 forKey:obj];
	}];
	
	[self _resetSwitchesAnimated:YES];
	
	[self.tableView reloadData];
}

- (IBAction)_demoSwitchValueDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsEnableCustomizations];
}

- (IBAction)_extendBarsSwitchValueDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsExtendBar];
}

- (IBAction)_hidesBottomBarWhenPushedValueDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsHidesBottomBarWhenPushed];
}

- (IBAction)_touchVisualizerEnabledDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsTouchVisualizerEnabled];
	self.view.window.windowScene.touchVisualizerEnabled = sender.isOn;
}

- (IBAction)_customBarEnabledDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsCustomBarEverywhereEnabled];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* key = _sectionToKeyMapping[@(indexPath.section)];
	
	if(key == PopupSettingsVisualEffectViewBlurEffect)
	{
		NSNumber* previous = [NSUserDefaults.standardUserDefaults objectForKey:key];
		UITableViewCell* previousCell = nil;
		if(previous != nil)
		{
			previousCell = [tableView viewWithTag:previous.integerValue + 10];
		}
		else
		{
			previousCell = [tableView viewWithTag:-1];
		}
		previousCell.accessoryType = UITableViewCellAccessoryNone;
		
		UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		if(cell.tag == -1)
		{
			[NSUserDefaults.standardUserDefaults removeObjectForKey:key];
		}
		else
		{
			[NSUserDefaults.standardUserDefaults setObject:@(cell.tag - 10) forKey:key];
		}
	}
	else
	{
		NSUInteger lastIdxInSection = [tableView numberOfRowsInSection:indexPath.section] - 1;
		NSUInteger prevValue = [[NSUserDefaults.standardUserDefaults objectForKey:key] unsignedIntegerValue];
		if(prevValue == 0xFFFF)
		{
			prevValue = lastIdxInSection;
		}
		
		[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevValue inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryNone;
		[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
		
		NSUInteger value = indexPath.row;
		if(value == lastIdxInSection && [_sectionsToSkip0xFFFF containsObject:@(indexPath.section)] == NO)
		{
			value = 0xFFFF;
		}
		[NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
	}
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
