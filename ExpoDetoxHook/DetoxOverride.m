//
//  DetoxOverride.m
//  ExpoDetoxHook
//
//  Created by Quinlan Jung on 10/24/18.
//  Copyright © 2018 Quinlan Jung. All rights reserved.
//

#import "DetoxOverride.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// call an arbitrary fn on a target with args
static id call(id target, NSString * selector, NSArray *args){
    SEL sel = NSSelectorFromString(selector);
    NSMethodSignature *signature = [target methodSignatureForSelector:sel];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = target;
    [invocation setSelector:sel];
    
    int argPos = 2;
    for (id arg in args){
        [invocation setArgument:&arg atIndex:argPos];
        argPos++;
    }
    
    [invocation invoke];
    id tempResultSet;
    [invocation getReturnValue:&tempResultSet];
    return tempResultSet;
}

static void (*__orig_waitForReactNativeLoadWithCompletionHandler)(id self, SEL _cmd, id handler);


// Registers a one-time notification on the Expo versioned RCTJavascriptDidLoadNotifications
static void __EXPO_waitForReactNativeLoadWithCompletionHandler(id self, SEL _cmd, id handler){
    NSString *notification = @"RCTJavaScriptDidLoadNotification";
    
    Class exVersions = NSClassFromString(@"EXVersions");
    if(exVersions == nil)
    {
        return;
    }
    
    id exVersionsInstance = call(exVersions, @"sharedInstance", @[]);
    NSDictionary *versions = call(exVersionsInstance, @"valueForKey:", @[@"versions"]);
    
    NSArray *sdkVersions = versions[@"sdkVersions"];
    for (NSString *supportedVersion in sdkVersions) {
        NSString *underscoredVersion = [supportedVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
        [DetoxOverride registerOneTimeNotification:[NSString stringWithFormat: @"ABI%@%@", underscoredVersion, notification] handler:handler];
    }
    __orig_waitForReactNativeLoadWithCompletionHandler(self, _cmd, handler);
}

@implementation DetoxOverride

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

__attribute__((constructor()))
static void __setupOverride() {
    Class cls = NSClassFromString(@"ReactNativeSupport");
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
    method_setImplementation(m, (void*)__EXPO_waitForReactNativeLoadWithCompletionHandler);
}
