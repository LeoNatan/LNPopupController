//
//  _LNPopupUIBarAppearanceProxy.h
//  LNPopupController
//
//  Created by Leo Natan on 30/08/2023.
//  Copyright © 2023 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

#if ! LNPopupControllerEnforceStrictClean

NS_ASSUME_NONNULL_BEGIN

@interface _LNPopupUIBarAppearanceProxy : NSObject

- (instancetype)initWithProxiedObject:(id)obj shadowColorHandler:(BOOL(^)(void))shadowColorHandler;

@end

NS_ASSUME_NONNULL_END

#endif
