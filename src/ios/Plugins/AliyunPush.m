/********* AliyunPush.m Cordova Plugin Implementation *******/

#import <Cordova/CDV.h>
#import "AliyunNotificationLauncher.h"

@interface AliyunPush : CDVPlugin {
    NSDictionary *_deathNotify;
}

@property (nonatomic,strong) CDVInvokedUrlCommand * messageCommand;
@property (nonatomic,strong) NSString *alertmsg;
@end

@implementation AliyunPush

- (void)pluginInitialize{
    
    [super pluginInitialize];
    
      NSLog(@"x-->pluginInitialize");
    
    // 推送通知 注册
    [[NSNotificationCenter defaultCenter] addObserver:self
                                            selector:@selector(onNotificationReceived:)
                                                 name:@"AliyunNotification"
                                               object:nil];
    
    // 推送消息 注册
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onMessageReceived:)
                                                 name:@"AliyunNotificationMessage"
                                               object:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self requireNotifyPermisssion:nil];
    });
}


/**
  弹出通知请求
 */
- (void)requireNotifyPermisssion:(NSString *)msg{
 
    self.alertmsg = msg?msg:@"建议你开启通知权限，第一时间收到提醒";
    
    if(![self judgeOneDate]){
        [self isUserNotificationEnable];
    }
}


- (void)showNotifyAlert:(NSString *) message{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"开启推送通知" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) { NSLog(@"点击取消");}]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0f) {

            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {}];
        }else{
             [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
        
    }]];
    
    [self.viewController presentViewController:alertController animated:YES completion:^{}];
}


- (BOOL)judgeOneDate{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *nowday = [formatter stringFromDate:[NSDate date]];
    
    NSString *saveday = [[NSUserDefaults standardUserDefaults] objectForKey:@"NOTIFY_DAY"];
    
    if(saveday && [saveday isEqualToString:nowday]){
        //是同一天
        return YES;
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:nowday forKey:@"NOTIFY_DAY"];
        return NO;
    }
}

 // 判断用户是否允许接收通知
- (BOOL)isUserNotificationEnable {
    __block BOOL isEnable = NO;
    __weak typeof(self) weakSelf = self;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0f) { // iOS版本 >=10.0 处理逻辑
        
        [[UNUserNotificationCenter currentNotificationCenter]getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusDenied) {
                isEnable = NO;
               
                //拒绝调用 且今天没调用过
                NSInteger x =( arc4random() % 11) ;
                if(x%3 == 0){
                    [weakSelf showNotifyAlert:self.alertmsg];
                }
                
            }else if (settings.authorizationStatus == UNAuthorizationStatusAuthorized) {
                isEnable = YES;
            }
        }];
        
    } else { // iOS版本 <8.0 处理逻辑
        if ([[UIApplication sharedApplication] currentUserNotificationSettings].types  == UIRemoteNotificationTypeNone) {
             isEnable = NO;
            //拒绝调用 且今天没调用过
            NSInteger x =( arc4random() % 11) ;
            if(x%3 == 0){
                [weakSelf showNotifyAlert:self.alertmsg];
            }
        }else {
            isEnable = YES;
        }
    }
    return isEnable;
}


#pragma mark AliyunNotification通知
- (void)onNotificationReceived:(NSNotification *)notification {
    
    NSDictionary * info = notification.object;
    
    if(!info){
        return;
    }
    
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] initWithDictionary:info];
    [extra removeObjectForKey:@"type"];
    [extra removeObjectForKey:@"body"];
    [extra removeObjectForKey:@"title"];
    
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setObject:extra forKey:@"extra"];
    [message setObject:info[@"type"] forKey:@"type"];
    [message setObject:info[@"title"] forKey:@"title"];
    [message setObject:info[@"body"] forKey:@"content"];
    [message setObject:@"" forKey:@"url"];
    
    NSLog(@"x----数据来了");
    NSLog(@"%@",info[@"body"]);
    
//    _deathNotify = message;
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
    
    
    NSString *requestData = [NSString stringWithFormat:@"sevenPushReceive(\"%@\")",info[@"body"]];
    
    [self.commandDelegate evalJs:requestData];
}

#pragma mark AliyunNotification消息

- (void)onMessageReceived:(NSNotification *)notification {
   
    NSDictionary * info = notification.object;
    if(!info){
        return;
    }
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setObject:@"" forKey:@"extra"];
    [message setObject:info[@"type"] forKey:@"type"];
    [message setObject:info[@"title"] forKey:@"title"];
    [message setObject:info[@"body"] forKey:@"content"];
    [message setObject:@"" forKey:@"url"];
    
//     _deathNotify = message;
    
    CDVPluginResult *result;
    result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:message];
    [result setKeepCallbackAsBool:true];
    [self.commandDelegate sendPluginResult:result callbackId:self.messageCommand.callbackId];
    
}


-(NSString *)NSStringToJson:(NSString *)str
{
    NSMutableString *s = [NSMutableString stringWithString:str];
    
    [s replaceOccurrencesOfString:@"\\" withString:@"\\\\" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    
    return [NSString stringWithString:s];
}

/**
 * 接收阿里云的消息
 */
- (void)onMessage:(CDVInvokedUrlCommand*)command{
    
    
    NSDictionary *remoteinfo =  [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] getRemoteInfo];
    
    if(!self.messageCommand && remoteinfo ){
        
        NSMutableDictionary *newContent = [[NSMutableDictionary alloc] initWithDictionary:remoteinfo];
        [newContent removeObjectForKey:@"aps"];
        [newContent removeObjectForKey:@"i"];
        [newContent removeObjectForKey:@"m"];
        [newContent setObject:@"notificationOpened" forKey:@"type"];

        CDVPluginResult *result;
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:newContent];
        [result setKeepCallbackAsBool:true];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
        
    self.messageCommand = command;
}

/**
 * 阿里云推送绑定账号名
 * 获取设备唯一标识deviceId，deviceId为阿里云移动推送过程中对设备的唯一标识（并不是设备UUID/UDID）
 */
- (void)getRegisterId:(CDVInvokedUrlCommand*)command{

    NSString *deviceId =  [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] getDeviceId];

    CDVPluginResult *result;
    
    if(deviceId.length != 0){
       result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:deviceId];
    }else{
        result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

/**
 * 阿里云推送绑定账号名
 */
- (void)bindAccount:(CDVInvokedUrlCommand*)command{
    
    NSString* account = [command.arguments objectAtIndex:0];
    
    if(account.length != 0){
     
        [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] bindAccountWithAccount:account andCallback:^(BOOL result) {
           
            CDVPluginResult *cdvresult;
            
            if(result){
                cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
            }else{
                cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            
            [self.commandDelegate sendPluginResult:cdvresult callbackId:command.callbackId];

        }];
    }

}

/**
 * 阿里云推送账号解绑
 */
- (void)unbindAccount:(CDVInvokedUrlCommand*)command{
    
    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] unbindAccountAndCallback:^(BOOL result) {
        
        CDVPluginResult *cdvresult;
        
        if(result){
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:cdvresult callbackId:command.callbackId];
        
    }];
    
}


/**
 *绑定标签
 */
- (void)bindTags:(CDVInvokedUrlCommand*)command{
    NSArray *tags = [command.arguments objectAtIndex:0];
    
    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] bindTagsWithTags:tags andCallback:^(BOOL result) {
      
        CDVPluginResult *cdvresult;
        
        if(result){
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:cdvresult callbackId:command.callbackId];
        
    }];
}

/**
 *解绑定标签
 */
- (void)unbindTags:(CDVInvokedUrlCommand*)command{
    NSArray *tags = [command.arguments objectAtIndex:0];

    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] unbindTagsWithTags:tags andCallback:^(BOOL result) {
        
        CDVPluginResult *cdvresult;
        
        if(result){
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        }else{
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }
        
        [self.commandDelegate sendPluginResult:cdvresult callbackId:command.callbackId];
        
    }];
    
}

/**
 *查询标签
 */
- (void)listTags:(CDVInvokedUrlCommand*)command{
    
    [[AliyunNotificationLauncher sharedAliyunNotificationLauncher] listTagsAndCallback:^(id result) {
       
        CDVPluginResult *cdvresult;
        
        if(result == [NSNull null] ){
            
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        }else{
            cdvresult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:(NSDictionary *)result];
        }
        
        [self.commandDelegate sendPluginResult:cdvresult callbackId:command.callbackId];
        
    }];
    
}




@end






