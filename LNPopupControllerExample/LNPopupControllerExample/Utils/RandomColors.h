//
//  RandomColors.h
//  LNPopupControllerExample
//
//  Created by Léo Natan on 2015-08-23.
//  Copyright © 2015-2024 Léo Natan. All rights reserved.
//

@import UIKit;

extern UIColor* LNRandomSystemColor(void);

extern UIColor* LNSeedAdaptiveColor(NSString* seed);
extern UIColor* LNSeedAdaptiveInvertedColor(NSString* seed);
extern UIColor* LNRandomAdaptiveColor(void);
extern UIColor* LNRandomAdaptiveInvertedColor(void);

extern UIColor* LNSeedDarkColor(NSString* seed);
extern UIColor* LNSeedLightColor(NSString* seed);
extern UIColor* LNRandomDarkColor(void);
extern UIColor* LNRandomLightColor(void);
