//
//  RandomColors.h
//  LNPopupControllerExample
//
//  Created by Leo Natan on 8/8/15.
//  Copyright © 2015 Leo Natan. All rights reserved.
//

@import UIKit;

extern UIColor* LNRandomSystemColor(void);

extern UIColor* LNSeedAdaptiveColor(NSString* seed) API_AVAILABLE(ios(13.0));
extern UIColor* LNSeedAdaptiveInvertedColor(NSString* seed) API_AVAILABLE(ios(13.0));
extern UIColor* LNRandomAdaptiveColor(void) API_AVAILABLE(ios(13.0));
extern UIColor* LNRandomAdaptiveInvertedColor(void) API_AVAILABLE(ios(13.0));

extern UIColor* LNSeedDarkColor(NSString* seed);
extern UIColor* LNSeedLightColor(NSString* seed);
extern UIColor* LNRandomDarkColor(void);
extern UIColor* LNRandomLightColor(void);
