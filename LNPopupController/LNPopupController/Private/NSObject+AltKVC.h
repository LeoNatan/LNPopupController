//
//  NSObject+AltKVC.h
//  LNPopupController
//
//  Created by Leo Natan on 6/8/19.
//  Copyright © 2015-2021 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AltKVC)

- (id)__ln_valueForKey:(NSString *)key;

@end
