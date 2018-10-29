//
//  TestOverride.h
//  Test
//
//  Created by Quinlan Jung on 10/24/18.
//  Copyright © 2018 Quinlan Jung. All rights reserved.
//

#ifndef TestOverride_h
#define TestOverride_h
#import <Foundation/Foundation.h>

@interface TestOverride : NSObject

+ (void)registerOneTimeNotification:(NSNotificationName) name handler:(void (^)(void))handler;
@end

#endif /* TestOverride_h */
