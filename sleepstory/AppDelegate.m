//
//  AppDelegate.m
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "AppDelegate.h"
#import "UMSocial.h"
#import "WXApi.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialSinaHandler.h"
#import "MobClick.h"
#import "UMSocialQQHandler.h"
#import "ContainerViewController.h"
#import "FavManager.h"
#import "StoryManager.h"
#import "APService.h"
@interface AppDelegate ()
{
    ContainerViewController *c;
     sqlite3 *database;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //创建sqlite文件
    NSError *error = nil;
    NSString *name = @"database";
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [directoryPaths objectAtIndex:0];
    
    NSString *databaseFile = [NSString stringWithFormat:@"%@/database.bin",documentsDirectoryPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if(![fileManager fileExistsAtPath:databaseFile]){
        NSLog(@"create database:%@",databaseFile);
//        [[NSData data] writeToFile:databaseFile options:NSDataWritingAtomic error:&error];
//        [[FavManager shareManager] createTable];
//        [[StoryManager shareManager] createTable];
        NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"database" ofType:@"bin"];
         [fileManager copyItemAtPath:dataPath toPath:databaseFile  error:&error];
    }else{
        NSLog(@"use database:%@",databaseFile);
    }
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    NSString *storyName = @"Main";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        storyName = @"ipad";
    }

    
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
    c = [story instantiateViewControllerWithIdentifier:@"container"];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
   
    self.window.rootViewController = c ;
    
    
    [UMSocialData setAppKey:@"552fc46efd98c5cf6c0008bd"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    //分享图文样式到微信朋友圈显示字数比较少，只显示分享标题
    //    [UMSocialData defaultData].extConfig.title = @"颜文字输入法ios版！全面支持iphone和ipad全平台，收录几千个颜文字，可自定义表情，查看最近使用的表情，太方便了！简直是卖萌利器！";
    //设置微信好友或者朋友圈的分享url,下面是微信好友，微信朋友圈对应wechatTimelineData
    //    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8";
    //    [UMSocialConfig setSupportSinaSSO:YES];
    
    [UMSocialSinaHandler openSSOWithRedirectURL:nil];
    
    
    [UMSocialWechatHandler setWXAppId:@"wx74cd71df371f37f2" appSecret:@"5fe39efd8f0071b460b6ef584d346db9" url:@"https://itunes.apple.com/cn/app/er-shi-yi-dian-shui-qian-gu-shi/id998079819"];
//    [UMSocialQQHandler setQQWithAppId:@"1102007075" appKey:@"g3M7AMNAoS1Ful43" url:@"http://www.html-js.com"];
    [UMSocialQQHandler setSupportWebView:NO];
    
   
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
    [APService setupWithOption:launchOptions];
    [application registerForRemoteNotificationTypes:
     UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge
     | UIRemoteNotificationTypeSound];
    
    [MobClick startWithAppkey:@"552fc46efd98c5cf6c0008bd" reportPolicy:SEND_INTERVAL   channelId:@"Web"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [c updateStoryData];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
//    if([@"update" isEqualToString:[userInfo objectForKey:@"type"]]){
//        updateUrl = @"http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[userInfo objectForKey:@"title"] message:[userInfo objectForKey:@"content"] delegate:self cancelButtonTitle:@"给我退下" otherButtonTitles:@"好的大王！", nil];
//        alert.delegate = self;
//        alert.tag = 1;
//        [alert show];
//        
//    }else if([@"open" isEqualToString:[userInfo objectForKey:@"type"]]){
//        updateUrl = [userInfo objectForKey:@"url"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[userInfo objectForKey:@"title"] message:[userInfo objectForKey:@"content"] delegate:self cancelButtonTitle:@"不理不睬" otherButtonTitles:@"去看看！", nil];
//        alert.delegate = self;
//        alert.tag = 2;
//        [alert show];
//        
//    }
    // Required
    [APService handleRemoteNotification:userInfo];
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
//    if([@"update" isEqualToString:[userInfo objectForKey:@"type"]]){
//        updateUrl = @"http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8";
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[userInfo objectForKey:@"title"] message:[userInfo objectForKey:@"content"] delegate:self cancelButtonTitle:@"给我退下" otherButtonTitles:@"好的大王！", nil];
//        alert.delegate = self;
//        alert.tag = 1;
//        [alert show];
//        
//    }else if([@"open" isEqualToString:[userInfo objectForKey:@"type"]]){
//        updateUrl = [userInfo objectForKey:@"url"];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[userInfo objectForKey:@"title"] message:[userInfo objectForKey:@"content"] delegate:self cancelButtonTitle:@"不理不睬" otherButtonTitles:@"去看看！", nil];
//        alert.delegate = self;
//        alert.tag = 2;
//        [alert show];
//        
//    }
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    NSLog(@"%@", [url host]);
    
    return   [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSLog(@"%@", [url host]);
    
    // 在 host 等于 item.taobao.com 时，说明一个宝贝详情的 url，
    
    // 那么就使用本地的 TBItemDetailViewController 来显示
//    
//    if ([[url host] isEqualToString:@"donate"]) {
//        showPay=YES;
//        if(showPay){
//            [list showBuyAlert];
//        }
//        
//    }
    return   [UMSocialSnsService handleOpenURL:url wxApiDelegate:nil];
}
@end
