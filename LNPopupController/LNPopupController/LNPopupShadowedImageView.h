//
//  LNPopupShadowedImageView.h
//  LNPopupController
//
//  Created by Léo Natan on 2023-09-25.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// A specialized `UIImageView` subclass, allowing setting a shadow and corner radius.
///
/// When used inside a popup content view, instances of this class are especially suited as image transition targets.
///
/// See `UIViewController.viewForPopupTransition(from:to:)`.
@interface LNPopupShadowedImageView : UIImageView

/// The corner radius of the image view.
@property (nonatomic, assign) CGFloat cornerRadius;
/// The shadow displayed underneath the image view.
@property (nonatomic, copy) NSShadow* shadow;

@end

NS_ASSUME_NONNULL_END
