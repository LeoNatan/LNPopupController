//
//  LNPopupDebug.h
//  LNPopupController
//
//  Created by Léo Natan on 2025-04-04.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef DEBUG
CF_EXTERN_C_BEGIN
extern NSUserDefaults* __LNDebugUserDefaults(void);
CF_EXTERN_C_END
#endif

NS_ASSUME_NONNULL_END
