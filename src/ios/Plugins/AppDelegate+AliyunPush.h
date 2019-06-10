//
//  AppDelegate+AliyunPush.h
//  SevenCordova
//
//  Created by ☺strum☺ on 2018/4/24.
//

#import "AppDelegate.h"

@interface AppDelegate (AliyunPush)

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler;


@end
