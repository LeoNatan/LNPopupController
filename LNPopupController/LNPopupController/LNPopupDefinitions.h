//
//  LNPopupDefinitions.h
//  LNPopupController
//
//  Created by Léo Natan on 2021-12-16.
//  Copyright © 2015-2025 Léo Natan. All rights reserved.
//

#ifndef LNPopupDefinitions_h
#define LNPopupDefinitions_h

#import <Foundation/Foundation.h>

#ifndef NS_SWIFT_UI_ACTOR
#define NS_SWIFT_UI_ACTOR
#endif

#ifndef NS_SWIFT_DISABLE_ASYNC
#define NS_SWIFT_DISABLE_ASYNC
#endif

#define LN_UNAVAILABLE_API(x) __attribute__((unavailable(x)))
#define LN_DEPRECATED_API(x) __attribute__((deprecated(x)))
#define LN_DEPRECATED_API_OS(...) API_DEPRECATED(__VA_ARGS__)

#define LN_DEPRECATED_API_OS_BEGIN(...) API_DEPRECATED_BEGIN(__VA_ARGS__)
#define LN_DEPRECATED_API_OS_END API_DEPRECATED_END

#endif /* LNPopupDefinitions_h */
