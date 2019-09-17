#import "EasemobPluPlugin.h"
#import <HyphenateLite/HyphenateLite.h>
#import <UserNotifications/UserNotifications.h>
#import "EasemobResponseHandler.h"

@interface EasemobPluPlugin()

@property (strong, nonatomic)EasemobResponseHandler *handler;

@end

@implementation EasemobPluPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"easemob_plu"
            binaryMessenger:[registrar messenger]];
  EasemobPluPlugin* instance = [[EasemobPluPlugin alloc] init];
    instance.handler = [[EasemobResponseHandler alloc]init];
    instance.handler.channel = channel;
  [registrar addMethodCallDelegate:instance channel:channel];
    
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"getPlatformVersion" isEqualToString:call.method]) {
    result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
  } else {
    result(FlutterMethodNotImplemented);
  }

    if ([@"initEaseMob" isEqualToString:call.method]) {

        //初始化
        [self.handler initEaseMob:call result:result];
        
    } else if([@"EMLogin" isEqualToString:call.method]){
        //登录
        [self.handler login:call];
    } else if([@"EMLogout" isEqualToString:call.method]){
        //退出登录
        [self.handler logout:call];
    }
    
}


- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
    
    NSDictionary *userInfo = notification.request.content.userInfo;
    UIApplication *application = [UIApplication sharedApplication];
     [[EMClient sharedClient] application:application  didReceiveRemoteNotification:userInfo];
    if (@available(iOS 10.0, *)) {
        completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert);
    } else {
        // Fallback on earlier versions
    }
    
}

#pragma 环信
// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}

// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];
}


@end
