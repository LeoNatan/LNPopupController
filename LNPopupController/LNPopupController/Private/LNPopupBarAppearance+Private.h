//
//  LNPopupBarAppearance+Private.h
//  LNPopupController
//
//  Created by Leo Natan on 6/9/21.
//  Copyright © 2021 Leo Natan. All rights reserved.
//

#import <LNPopupController/LNPopupBarAppearance.h>

NS_ASSUME_NONNULL_BEGIN

@protocol _LNPopupBarAppearanceDelegate <NSObject>

- (void)popupBarAppearanceDidChange:(LNPopupBarAppearance*)popupBarAppearance;

@end

@interface LNPopupBarAppearance ()

@property (nonatomic, weak) id<_LNPopupBarAppearanceDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
