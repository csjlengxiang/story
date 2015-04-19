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

#import "UMSocialQQHandler.h"
#import "ContainerViewController.h"
@interface AppDelegate ()
{
    ContainerViewController *c;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"guize" ofType:@"jpg"];
    NSError *error = nil;
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains
    (NSCachesDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [directoryPaths objectAtIndex:0];
    NSLog(@"%@",documentsDirectoryPath);
    NSFileManager *filemanager = [[NSFileManager alloc] init];
    [filemanager removeItemAtPath:[NSString stringWithFormat:@"%@/guize.jpg",documentsDirectoryPath] error:&error];
    [filemanager copyItemAtPath:dataPath toPath:[NSString stringWithFormat:@"%@/guize.jpg",documentsDirectoryPath]  error:&error];
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    c = [story instantiateViewControllerWithIdentifier:@"container"];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    UINavigationController *n = [[UINavigationController alloc] initWithRootViewController:c];
    self.window.rootViewController = c ;
    
    
    [UMSocialData setAppKey:@"552fc46efd98c5cf6c0008bd"];
    
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeNone;
    //分享图文样式到微信朋友圈显示字数比较少，只显示分享标题
    //    [UMSocialData defaultData].extConfig.title = @"颜文字输入法ios版！全面支持iphone和ipad全平台，收录几千个颜文字，可自定义表情，查看最近使用的表情，太方便了！简直是卖萌利器！";
    //设置微信好友或者朋友圈的分享url,下面是微信好友，微信朋友圈对应wechatTimelineData
    //    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8";
    //    [UMSocialConfig setSupportSinaSSO:YES];
    
    [UMSocialSinaHandler openSSOWithRedirectURL:nil];
    
    
    [UMSocialWechatHandler setWXAppId:@"wx547036f9011b9dfe" appSecret:@"c34b5a32ddf18816dd20e051127eca8f" url:@"http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8"];
//    [UMSocialQQHandler setQQWithAppId:@"1102007075" appKey:@"g3M7AMNAoS1Ful43" url:@"http://www.html-js.com"];
    [UMSocialQQHandler setSupportWebView:NO];
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
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
