//
//  ModernObjCSupport.h
//  LNPopupController
//
//  Created by Leo Natan on 7/25/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

#ifndef __MODERN_OBJC_SUPPORT_H
#define __MODERN_OBJC_SUPPORT_H

#ifndef _Nonnull
#define _Nonnull
#endif

#ifndef _Nullable
#define _Nullable
#endif

#if __has_feature(objc_generics)
#define LNObjectKindOfType(type) __kindof type
#define LNArrayOfType(type) NSArray<type>
#define LNDictionaryOfType(t1,t2) NSDictionary<t1, t2>
#else
#define LNObjectKindOfType(type) type
#define LNArrayOfType(type) NSArray
#define LNDictionaryOfType(t1,t2) NSDictionary
#endif

#endif