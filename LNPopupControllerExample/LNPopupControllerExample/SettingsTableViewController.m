//
//  SettingsTableViewController.m
//  LNPopupControllerExample
//
//  Created by Leo Natan on 18/03/2017.
//  Copyright © 2017 Leo Natan. All rights reserved.
//

#import "SettingsTableViewController.h"

NSString* const PopupSettingsBarStyle = @"PopupSettingsBarStyle";
NSString* const PopupSettingsInteractionStyle = @"PopupSettingsInteractionStyle";
NSString* const PopupSettingsProgressViewStyle = @"PopupSettingsProgressViewStyle";
NSString* const PopupSettingsCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
NSString* const PopupSettingsExtendBar = @"PopupSettingsExtendBar";
NSString* const PopupSettingsHidesBottomBarWhenPushed = @"PopupSettingsHidesBottomBarWhenPushed";

@interface SettingsTableViewController ()
{
	NSDictionary<NSNumber*, NSString*>* _sectionToKeyMapping;
	
	IBOutlet UISwitch* _extendBars;
	IBOutlet UISwitch* _hidesBottomBarWhenPushed;
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
		@2: PopupSettingsCloseButtonStyle,
		@3: PopupSettingsProgressViewStyle,
	};
	
	[self _resetSwitchesAnimated:NO];
}

- (void)_resetSwitchesAnimated:(BOOL)animated
{
	[_extendBars setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsExtendBar] animated:animated];
	[_hidesBottomBarWhenPushed setOn:[NSUserDefaults.standardUserDefaults boolForKey:PopupSettingsHidesBottomBarWhenPushed] animated:animated];
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
		
		NSUInteger value = [[NSUserDefaults.standardUserDefaults objectForKey:key] unsignedIntegerValue];
		if(value == 0xFFFF)
		{
			value = [tableView numberOfRowsInSection:indexPath.section] - 1;
		}
		
		if(indexPath.row == value)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	
	return cell;
}

- (IBAction)_resetButtonTapped:(UIBarButtonItem *)sender
{
	[NSUserDefaults.standardUserDefaults setBool:YES forKey:PopupSettingsExtendBar];
	[NSUserDefaults.standardUserDefaults setBool:YES forKey:PopupSettingsHidesBottomBarWhenPushed];
	
	[_sectionToKeyMapping enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
		[NSUserDefaults.standardUserDefaults setObject:@0 forKey:obj];
	}];
	
	[self _resetSwitchesAnimated:YES];
	
	[self.tableView reloadData];
}

- (IBAction)_extendBarsSwitchValueDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsExtendBar];
}

- (IBAction)_hidesBottomBarWhenPushedValueDidChange:(UISwitch*)sender
{
	[NSUserDefaults.standardUserDefaults setBool:sender.isOn forKey:PopupSettingsHidesBottomBarWhenPushed];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* key = _sectionToKeyMapping[@(indexPath.section)];
	
	if(key == nil)
	{
		return;
	}
	
	NSUInteger prevValue = [[NSUserDefaults.standardUserDefaults objectForKey:key] unsignedIntegerValue];
	if(prevValue == 0xFFFF)
	{
		prevValue = [tableView numberOfRowsInSection:indexPath.section] - 1;
	}
	
	[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevValue inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryNone;
	[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
	
	NSUInteger countInSection = [tableView numberOfRowsInSection:indexPath.section];
	
	NSUInteger value = indexPath.row;
	if(indexPath.section != 0 && countInSection - 1 == indexPath.row)
	{
		value = 0xFFFF;
	}
	[NSUserDefaults.standardUserDefaults setObject:@(value) forKey:key];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
