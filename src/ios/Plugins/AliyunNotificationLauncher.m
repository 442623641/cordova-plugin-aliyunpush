//
//  AliyunNotificationLauncher.m
//  SevenPush
//
//  Created by ☺strum☺ on 2018/4/10.
//  Copyright © 2018年 zpk. All rights reserved.
//

#import "AliyunNotificationLauncher.h"
#import <CloudPushSDK/CloudPushSDK.h>
@interface AliyunNotificationLauncher(){
    UNUserNotificationCenter* _notificationCenter;
    NSDictionary * _remoteinfo;
}

@end

@implementation AliyunNotificationLauncher

+ (id)sharedAliyunNotificationLauncher{
    
    static AliyunNotificationLauncher *notificationManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        notificationManager = [[self alloc] init];
    });
    return notificationManager;
    
}

#pragma mark  初始化推送设置sdk 获取token 注册消息
- (void)didFinishLaunchingWithOptions:(NSDictionary *)launchOptions andApplication:(UIApplication *)application{
    
    NSDictionary *remoteNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    // 如果​remoteNotification不为空，代表有推送发过来，以下类似
    if (remoteNotification) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;//infoDict是在AppDelegate的.h文件中申明的一个不可变字典
        _remoteinfo = remoteNotification;
        
       
    }
    
    
    // APNs注册，获取deviceToken并上报
    [self registerAPNS:application];
    
    // 初始化SDK
    [self initCloudPush];
    
    // 监听推送通道打开动作
    [self listenerOnChannelOpened];
    
    // 监听推送消息到达
    [self registerMessageReceive];
    
    // 点击通知将App从关闭状态启动时，将通知打开回执上报
    [CloudPushSDK sendNotificationAck:launchOptions];
    
}

#pragma mark APNs Register
/**
 *    向APNs注册，获取deviceToken用于推送
 *
 */
- (void)registerAPNS:(UIApplication *)application {
    
    float systemVersionNum = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if (systemVersionNum >= 10.0) {
        // iOS 10 notifications
        _notificationCenter = [UNUserNotificationCenter currentNotificationCenter];
        // 创建category，并注册到通知中心
        [self createCustomNotificationCategory];
        
        _notificationCenter.delegate = self;
        
        // 请求推送权限
        [_notificationCenter requestAuthorizationWithOptions:UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (granted) {
                // granted
                NSLog(@"User authored notification.");
                // 向APNs注册，获取deviceToken
                dispatch_async(dispatch_get_main_queue(), ^{
                    [application registerForRemoteNotifications];
                });
            } else {
                // not granted
                NSLog(@"User denied notification.");
            }
        }];
    }else if (systemVersionNum >= 8.0) {
        // iOS 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [application registerUserNotificationSettings:
         [UIUserNotificationSettings settingsForTypes:
          (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                           categories:nil]];
        [application registerForRemoteNotifications];
#pragma clang diagnostic pop
    } else {
        // iOS < 8 Notifications
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
#pragma clang diagnostic pop
    }
}

#pragma mark 创建并注册通知category
/**
 *  创建并注册通知category(iOS 10+)
 */
- (void)createCustomNotificationCategory {
    
    // 自定义`action1`和`action2`
    UNNotificationAction *action1 = [UNNotificationAction actionWithIdentifier:@"action1" title:@"test1" options: UNNotificationActionOptionNone];
    
    UNNotificationAction *action2 = [UNNotificationAction actionWithIdentifier:@"action2" title:@"test2" options: UNNotificationActionOptionNone];
    
    // 创建id为`test_category`的category，并注册两个action到category
    
    // UNNotificationCategoryOptionCustomDismissAction表明可以触发通知的dismiss回调
    UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:@"test_category" actions:@[action1, action2] intentIdentifiers:@[] options:
                                        UNNotificationCategoryOptionCustomDismissAction];
    // 注册category到通知中心
    [_notificationCenter setNotificationCategories:[NSSet setWithObjects:category, nil]];
}


- (NSDictionary *)getRemoteInfo{
    return _remoteinfo;
}


#pragma mark SDK Init AliyunEmasServices-Info.plist
- (void)initCloudPush {
    // 正式上线建议关闭
    [CloudPushSDK turnOnDebug];
    
    // SDK初始化，无需输入配置信息
    // 请从控制台下载AliyunEmasServices-Info.plist配置文件，并正确拖入工程
    [CloudPushSDK autoInit:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Push SDK init success, deviceId: %@.", [CloudPushSDK getDeviceId]);
        } else {
            NSLog(@"Push SDK init failed, error: %@", res.error);
        }
    }];
}

#pragma mark Channel Opened
/**
 *    注册推送通道打开监听
 */
- (void)listenerOnChannelOpened {
    
    //暂不设置
}

#pragma mark Receive Message
/**
 *    @brief    注册推送消息到来监听
 */
- (void)registerMessageReceive {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"CCPDidReceiveMessageNotification"
                                               object:nil];
}

#pragma mark 推送消息处理
/**
 *    处理到来推送消息
 *
 */
- (void)onMessageReceived:(NSNotification *)notification {
    NSLog(@"Receive one message!");
    
    CCPSysMessage *message = [notification object];
    NSString *title = [[NSString alloc] initWithData:message.title encoding:NSUTF8StringEncoding];
    NSString *body = [[NSString alloc] initWithData:message.body encoding:NSUTF8StringEncoding];
    NSLog(@"Receive message title: %@, content: %@.", title, body);
   
    //发送通知给cordova
    NSDictionary *dict = @{@"body":body,@"title":title?title:@"",@"messageType":[NSString stringWithFormat:@"%hhu",message.messageType],@"type":@"message"};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AliyunNotificationMessage" object:dict];

}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

#pragma mark - notification application delegate
- (void)didReceiveRemoteNotification:(NSDictionary *)userInfo andApplication:(UIApplication *)application{

    NSLog(@"didReceiveRemoteNotification. ");
    // 取得APNS通知内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    // 内容
    NSDictionary *content = [aps valueForKey:@"alert"];
   
    //去除 aps i m 添加 自定义value 
    NSMutableDictionary *newContent = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
   
    [newContent removeObjectForKey:@"aps"];
    [newContent removeObjectForKey:@"i"];
    [newContent removeObjectForKey:@"m"];
    [newContent addEntriesFromDictionary:content];
    
    if(content){
        [newContent setObject:@"notificationReceived" forKey:@"type"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AliyunNotification" object:newContent];
    }
    // badge数量
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue];
    // 播放声音
    NSString *sound = [aps valueForKey:@"sound"];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *Extras = [userInfo valueForKey:@"Extras"]; //服务端中Extras字段，key是自己定义的
    NSLog(@"content = [%@], badge = [%ld], sound = [%@], Extras = [%@]", content, (long)badge, sound, Extras);
    // iOS badge 清0
    application.applicationIconBadgeNumber = 0;
    // 同步通知角标数到服务端
    // [self syncBadgeNum:0];
    // 通知打开回执上报
    // [CloudPushSDK handleReceiveRemoteNotification:userInfo];(Deprecated from v1.8.1)
    [CloudPushSDK sendNotificationAck:userInfo];
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    
    [CloudPushSDK registerDevice:deviceToken withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Register deviceToken success, deviceToken: %@", [CloudPushSDK getApnsDeviceToken]);
        } else {
            NSLog(@"Register deviceToken failed, error: %@", res.error);
        }
    }];
}

#pragma mark -触发通知动作回调 、、 点击、删除通知
/**
 *  触发通知动作时回调，比如点击(iOS 10+)
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSLog(@"userNotificationCenter");
    NSString *userAction = response.actionIdentifier;
    // 点击通知打开
    if ([userAction isEqualToString:UNNotificationDefaultActionIdentifier]) {
        NSLog(@"User opened the notification.");
        // 处理iOS 10通知，并上报通知打开回执
        [self handleiOS10Notification:response.notification withType:@"notificationOpened"];
    }
    // 通知dismiss，category创建时传入UNNotificationCategoryOptionCustomDismissAction才可以触发
    if ([userAction isEqualToString:UNNotificationDismissActionIdentifier]) {
        NSLog(@"User dismissed the notification.");
    }
    NSString *customAction1 = @"action1";
    NSString *customAction2 = @"action2";
    // 点击用户自定义Action1
    if ([userAction isEqualToString:customAction1]) {
        NSLog(@"User custom action1.");
    }
    // 点击用户自定义Action2
    if ([userAction isEqualToString:customAction2]) {
        NSLog(@"User custom action2.");
    }
    completionHandler();
}

#pragma mark - UNUserNotificationCenterDelegate 前台收到通知

/**
 *  App处于前台时收到通知(iOS 10+)
 */

- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    NSLog(@"userNotificationCenter2");
    // 处理iOS 10通知，并上报通知打开回执
    [self handleiOS10Notification:notification withType:@"notificationReceived"];
    
    // 通知弹出
    completionHandler(UNNotificationPresentationOptionAlert);
}

/**
 * ( 处理iOS 10通知(iOS 10+)
 */
- (void)handleiOS10Notification:(UNNotification *)notification withType:(NSString *)type{
    
    NSLog(@"handleiOS10Notification");
    
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    NSDictionary *userInfo = content.userInfo;
    NSLog(@"userInfo %@",userInfo);
    // 通知时间
    NSDate *noticeDate = notification.date;
    // 标题
    NSString *title = content.title;
    // 副标题
    NSString *subtitle = content.subtitle;
    // 内容
    NSString *body = content.body;
    
    // 角标
    int badge = [content.badge intValue];
    // 取得通知自定义字段内容，例：获取key为"Extras"的内容
    NSString *extras = [userInfo valueForKey:@"Extras"];
    // 通知角标数清0
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // 同步角标数到服务端
    // [self syncBadgeNum:0];
    // 通知打开回执上报
    [CloudPushSDK sendNotificationAck:userInfo];
    NSLog(@"Notification, date: %@, title: %@, subtitle: %@, body: %@, badge: %d, extras: %@.", noticeDate, title, subtitle, body, badge, extras);
 
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        //发送通知给cordova
        NSDictionary *dict = @{@"body":body?body:@"",@"title":title?title:@""};
        
        NSMutableDictionary *newContent = [[NSMutableDictionary alloc] initWithDictionary:userInfo];
        [newContent removeObjectForKey:@"aps"];
        [newContent removeObjectForKey:@"i"];
        [newContent removeObjectForKey:@"m"];
        [newContent addEntriesFromDictionary:dict];
        
        [newContent setObject:type forKey:@"type"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AliyunNotification" object:newContent];
    });
   
}


/* 同步通知角标数到服务端 */
- (void)syncBadgeNum:(NSUInteger)badgeNum {
    [CloudPushSDK syncBadgeNum:badgeNum withCallback:^(CloudPushCallbackResult *res) {
        if (res.success) {
            NSLog(@"Sync badge num: [%lu] success.", (unsigned long)badgeNum);
        } else {
            NSLog(@"Sync badge num: [%lu] failed, error: %@", (unsigned long)badgeNum, res.error);
        }
    }];
}

#pragma mark - 获取设备 id
- (NSString *)getDeviceId{
    return  [CloudPushSDK getDeviceId];
}

#pragma mark - 绑定账号
- (void)bindAccountWithAccount:(NSString *)account andCallback:(void (^)(BOOL result))callback{
    [CloudPushSDK bindAccount:account withCallback:^(CloudPushCallbackResult *res) {
        callback(res.success);
    }];
}

#pragma mark - 绑定标签
- (void)bindTagsWithTags:(NSArray *)tags andCallback:(void (^)(BOOL result))callback{
    
    [CloudPushSDK bindTag:2 withTags:tags
                withAlias:@""
             withCallback:^(CloudPushCallbackResult *res) {

        callback(res.success);
    }];
    
}

#pragma mark - 解除绑定
- (void)unbindAccountAndCallback:(void (^)(BOOL result))callback{
    [CloudPushSDK unbindAccount:^(CloudPushCallbackResult *res) {
        callback(res.success);
    }];
}
//+ (void)unbindAccount:(CallbackHandler)callback;


#pragma mark - 解除标签
- (void)unbindTagsWithTags:(NSArray *)tags andCallback:(void (^)(BOOL result))callback{
    
    [CloudPushSDK unbindTag:2 withTags:tags withAlias:@"" withCallback:^(CloudPushCallbackResult *res) {
        callback(res.success);
    }];
}

#pragma mark - 查询绑定
- (void)listTagsAndCallback:(void (^)(id result))callback{
    [CloudPushSDK listTags:1 withCallback:^(CloudPushCallbackResult *res) {
        callback(res.data);
    }];
}



@end
