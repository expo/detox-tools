//
//  TestOverride.m
//  Test
//
//  Created by Quinlan Jung on 10/24/18.
//  Copyright © 2018 Quinlan Jung. All rights reserved.
//

#import "TestOverride.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

//static void registerOneTimeNotification(NSNotificationName name, void (*handler)(void))
//{
//    __block __weak id observer;
//
//    observer = [[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//
//        if(handler)
//        {
//            handler();
//        }
//
//        [[NSNotificationCenter defaultCenter] removeObserver:observer];
//    }];
//}

static void (*__orig_waitForReactNativeLoadWithCompletionHandler)(id self, SEL _cmd, id handler);


static void __QUIN_waitForReactNativeLoadWithCompletionHandler(id self, SEL _cmd, id handler){
    NSLog(@"QUIN handler");
    
    NSString *notification = @"RCTJavaScriptDidLoadNotification";
    
    Class exVersions = NSClassFromString(@"EXVersions");
    if(exVersions == nil)
    {
        return;
    }
    
    SEL sharedInstance =NSSelectorFromString(@"sharedInstance");
    NSMethodSignature *signature = [exVersions methodSignatureForSelector:sharedInstance];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = exVersions;
    [invocation setSelector:sharedInstance];
    [invocation invoke];
    id __unsafe_unretained tempResultSet;
    [invocation getReturnValue:&tempResultSet];
    id exVersionsInstance = tempResultSet;
    
    SEL valueForKey =NSSelectorFromString(@"valueForKey:");
    NSMethodSignature *signature2 = [exVersionsInstance  methodSignatureForSelector:valueForKey];
    NSInvocation *invocation2 = [NSInvocation invocationWithMethodSignature:signature2];
    invocation2.target = exVersionsInstance;
    [invocation2 setSelector:valueForKey];
    NSString * key =@"versions";
    [invocation2 setArgument:&key atIndex:2];
    [invocation2 invoke];
    
    id __unsafe_unretained tempResultSet2;
    [invocation2 getReturnValue:&tempResultSet2];
    NSDictionary * versions = tempResultSet2;
    
    //NSDictionary *versions=[[exVersions sharedInstance] valueForKey:@"versions"];
    NSArray *sdkVersions = versions[@"sdkVersions"];
    for (NSString *supportedVersion in sdkVersions) {
        NSString *underscoredVersion = [supportedVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        [TestOverride registerOneTimeNotification:[NSString stringWithFormat: @"ABI%@%@", underscoredVersion, notification] handler:handler];
        //registerOneTimeNotification([NSString stringWithFormat: @"ABI%@%@", underscoredVersion, notification], handler);
    }
    __orig_waitForReactNativeLoadWithCompletionHandler(self, _cmd, handler);
}

@implementation TestOverride

+ (void) registerOneTimeNotification:(NSNotificationName) name handler:(void (^)(void))handler
{
    __block __weak id observer;
    
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:name object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        if(handler)
        {
            handler();
        }
        
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
    }];
}
@end

__attribute__((constructor(102)))
static void testOverrideMain() {
    NSLog(@"Hello from Test Override priority 102");
    //Class greyConfiguration1 = NSClassFromString(@"TestOverride");
    //NSLog(@"%@", greyConfiguration1);
    NSUserDefaults* options = [NSUserDefaults standardUserDefaults];
    
    NSArray *blacklistRegex = [options arrayForKey:@"detoxURLBlacklistRegex"];
    if (blacklistRegex){
        //NSArray *blacklistRegex = @[@".*/onchange"];
        Class greyConfiguration = NSClassFromString(@"GREYConfiguration"); // waitForReactNativeLoadWithCompletionHandler
        if(greyConfiguration == nil)
        {
            return;
        }
        SEL sharedInstance =NSSelectorFromString(@"sharedInstance");
        NSMethodSignature *signature = [greyConfiguration methodSignatureForSelector:sharedInstance];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = greyConfiguration;
        [invocation setSelector:sharedInstance];
        [invocation invoke];
        NSString *type = [NSString stringWithUTF8String:invocation.methodSignature.methodReturnType];
        id __unsafe_unretained tempResultSet;
        [invocation getReturnValue:&tempResultSet];
        id greyConfigInstance = tempResultSet;
        
        SEL setValue =NSSelectorFromString(@"setValue:forConfigKey:");
        NSMethodSignature *signature2 = [greyConfigInstance  methodSignatureForSelector:setValue];
        NSInvocation *invocation2 = [NSInvocation invocationWithMethodSignature:signature2];
        invocation2.target = greyConfigInstance;
        [invocation2 setSelector:setValue];
        [invocation2 setArgument:&blacklistRegex atIndex:2];
        NSString * configKey =@"GREYConfigKeyURLBlacklistRegex";
        [invocation2 setArgument:&configKey atIndex:3];
        [invocation2 invoke];
    }
    
    Class cls = NSClassFromString(@"ReactNativeSupport"); // waitForReactNativeLoadWithCompletionHandler
    if(cls == nil)
    {
        return;
    }
    
    Method m = class_getClassMethod(cls, NSSelectorFromString(@"waitForReactNativeLoadWithCompletionHandler:"));
    if(m == NULL)
    {
        return;
    }
    __orig_waitForReactNativeLoadWithCompletionHandler = (void*)method_getImplementation(m);
    method_setImplementation(m, (void*)__QUIN_waitForReactNativeLoadWithCompletionHandler);
}
