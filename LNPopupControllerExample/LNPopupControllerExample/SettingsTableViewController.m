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
NSString* const PopupSettingsCloseButtonStyle = @"PopupSettingsCloseButtonStyle";
NSString* const PopupSettingsMarqueeStyle = @"PopupSettingsMarqueeStyle";
NSString* const PopupSettingsEnableCustomizations = @"PopupSettingsEnableCustomizations";

@interface SettingsTableViewController ()
{
	NSDictionary<NSNumber*, NSString*>* _sectionToKeyMapping;
}

@end

@implementation SettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	_sectionToKeyMapping = @{@0: PopupSettingsBarStyle, @1: PopupSettingsInteractionStyle, @2: PopupSettingsCloseButtonStyle, @3: PopupSettingsMarqueeStyle};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.accessoryView = nil;
	cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	
	NSString* key = _sectionToKeyMapping[@(indexPath.section)];
	if(key == nil)
	{
		UISwitch* customizations = [UISwitch new];
		customizations.on = [[NSUserDefaults standardUserDefaults] boolForKey:PopupSettingsEnableCustomizations];
		[customizations addTarget:self action:@selector(_demoSwitchValueDidChange:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = customizations;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	else
	{
		NSUInteger value = [[[NSUserDefaults standardUserDefaults] objectForKey:key] unsignedIntegerValue];
		if(value == 0xFFFF)
		{
			value = 3;
		}
		
		if(indexPath.row == value)
		{
			cell.accessoryType = UITableViewCellAccessoryCheckmark;
		}
	}
	
	return cell;
}

- (IBAction)_resetButtonTapped:(UIBarButtonItem *)sender {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:PopupSettingsEnableCustomizations];
	[_sectionToKeyMapping enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
		[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:obj];
	}];
	
	[self.tableView reloadData];
}

- (void)_demoSwitchValueDidChange:(UISwitch*)sender
{
	[[NSUserDefaults standardUserDefaults] setBool:sender.isOn forKey:PopupSettingsEnableCustomizations];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString* key = _sectionToKeyMapping[@(indexPath.section)];
	NSUInteger prevValue = [[[NSUserDefaults standardUserDefaults] objectForKey:key] unsignedIntegerValue];
	if(prevValue == 0xFFFF)
	{
		prevValue = 3;
	}

	[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:prevValue inSection:indexPath.section]].accessoryType = UITableViewCellAccessoryNone;
	[tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
	
	NSUInteger value = indexPath.row;
	if(value == 3)
	{
		value = 0xFFFF;
	}
	[[NSUserDefaults standardUserDefaults] setObject:@(value) forKey:key];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
