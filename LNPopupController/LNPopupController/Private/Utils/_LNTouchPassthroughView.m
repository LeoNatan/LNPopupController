//
//  _LNTouchPassthroughView.m
//  LNPopupController
//
//  Created by Léo Natan on 7/7/26.
//  Copyright © 2026 Léo Natan. All rights reserved.
//

#import "_LNTouchPassthroughView.h"

@implementation _LNTouchPassthroughView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView* rv = [super hitTest:point withEvent:event];
	
	if(rv == self)
	{
		return nil;
	}
	
	return rv;
}

@end
