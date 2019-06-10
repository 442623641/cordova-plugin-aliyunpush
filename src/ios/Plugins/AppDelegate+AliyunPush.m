//
//  AppDelegate+AliyunPush.m
//  SevenCordova
//
//  Created by ☺strum☺ on 2018/4/24.
//

#import "AppDelegate+AliyunPush.h"
#import "AliyunNotificationLauncher.h"
#import <objc/runtime.h>

@implementation AppDelegate (AliyunPush)

+(void)load{
    Method original, swizzled;
    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createNotificationChecker:)
                                                 name:@"UIApplicationDidFinishLaunchingNotification" object:nil];
    
    return [self swizzled_init];
}

- (void)createNotificationChecker:(NSNotification *)notification
{
    if (notification)
    {
        id obj = notification.object;
        UIApplication *application  = (UIApplication *)obj;
        NSDictionary *launchOptions = [notification userInfo];
        
        NSLog(@"category sharedAliyunNotificationLauncher ");
        
        [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] didFinishLaunchingWithOptions:launchOptions andApplication:application];
        
    }
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler{
    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] didReceiveRemoteNotification:userInfo andApplication:application];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    
}



@end
