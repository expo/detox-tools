//
//  DetoxOverride.h
//  ExpoDetoxHook
//
//  Created by Quinlan Jung on 10/24/18.
//  Copyright © 2018 Quinlan Jung. All rights reserved.
//

#ifndef DetoxOverride_h
#define DetoxOverride_h
#import <Foundation/Foundation.h>

@interface DetoxOverride : NSObject

+ (void)registerOneTimeNotification:(NSNotificationName) name handler:(void (^)(void))handler;
@end

#endif /* DetoxOverride_h */
