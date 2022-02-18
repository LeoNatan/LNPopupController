//
//  _LNPopupBarBackgroundView.m
//  LNPopupController
//
//  Created by Leo Natan on 6/26/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import "_LNPopupBarBackgroundView.h"

@implementation _LNPopupBarBackgroundView
{
	UIView* _colorView;
	UIImageView* _imageView;
}

- (instancetype)initWithEffect:(UIVisualEffect *)effect
{
	self = [super initWithEffect:effect];
	
	if(self)
	{
		_colorView = [UIView new];
		_imageView = [UIImageView new];
		
		[self.contentView addSubview:_colorView];
		[self.contentView addSubview:_imageView];
	}
	
	return self;
}

- (UIView *)colorView
{
	return _colorView;
}

- (UIImageView *)imageView
{
	return _imageView;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	_imageView.frame = self.contentView.bounds;
	_colorView.frame = self.contentView.bounds;
	
	[self.contentView sendSubviewToBack:_imageView];
	[self.contentView sendSubviewToBack:_colorView];
}

@end
