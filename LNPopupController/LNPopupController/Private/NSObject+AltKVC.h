//
//  NSObject+AltKVC.h
//  LNPopupController
//
//  Created by Leo Natan (Wix) on 6/8/19.
//  Copyright © 2019 Leo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AltKVC)

- (id)__ln_valueForKey:(NSString *)key;

@end
