//
//  ContainerViewController.m
//  sleepstory
//
//  Created by tianqi on 15/3/19.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "ContainerViewController.h"
#import "StoryViewController.h"
#import "AFNetworking/AFNetworking.h"

#import "StoryManager.h"
#import "ATMHud.h"
#import "UMSocial.h"
#import "MenuViewController.h"
#import "AllStoryTableViewController.h"
#import "WebViewController.h"
#import "PMParentalGateQuestion.h"
@interface ContainerViewController ()
{
    StoryViewController *viewController1;
    StoryViewController *viewController2;
    int nowIndex;
    int nowPage;
    BOOL hasNoMore;
    NSMutableArray *storys;
    StoryViewController *activeStoryController;
    UIImageView *coverView;
    StoryModel *nowStory;
    ATMHud *hud;
    int firstId;
    MenuViewController *menuView;
    NetworkStatus lastNetStatus;
}
@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    hud = [[ATMHud alloc] initWithDelegate:self];
    
    self.navigationController.navigationBar.barTintColor = [SYUtil colorWithHex:@"e15151"];
    self.navigationController.navigationBar.translucent = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    storys = [[NSMutableArray alloc] init];
    NSString *storyName = @"Main";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        storyName = @"ipad";
    }
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
    //生成两个界面，用来翻页的切换
    viewController1 = [story instantiateViewControllerWithIdentifier:@"main"];
    viewController2 = [story instantiateViewControllerWithIdentifier:@"main"];
    viewController1.containerDelegate = self;
    viewController2.containerDelegate = self;
    
    [self.view addSubview:viewController1.view];
    [self.view addSubview:viewController2.view];
    //把页面添加到容器中
    [self addChildViewController:viewController1];
    [self addChildViewController:viewController2];
    nowIndex = 0;
    nowPage = 1;
    hasNoMore = false;
    //开始请求故事的信息
//    [self requestList:nowPage];
    
    coverView = [[UIImageView alloc] init];
    coverView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    coverView.image = [UIImage imageNamed:@"cover.png"];
    if(SCREEN_HEIGHT<500){
        coverView.image = [UIImage imageNamed:@"c-4.png"];
    }
    if(SCREEN_HEIGHT == 1024){
        coverView.image = [UIImage imageNamed:@"c-ipad.png"];
    }
    [self.view addSubview:coverView];
    
    NSMutableArray *localStorys = [[StoryManager shareManager] getAll];
    storys = localStorys;
    
    firstId = 0;
    if([localStorys count]>0){
        StoryModel *s = [localStorys objectAtIndex:0];
        nowStory = s;
        firstId = s.ID;
        [self initView];
    }else{
        
    }
    [self.view addSubview:hud.view];
    [hud setCaption:@"初始化数据中，请稍候"];
    [hud show];
//    [hud hideAfter:2.0];
    [[StoryManager shareManager] getAllFromOnlineWithFirstID:firstId success:^(NSMutableArray *_storys) {
        for(int i=0;i<[_storys count];i++){
            [[StoryManager shareManager] add:[_storys objectAtIndex:i]];
        }
        NSMutableArray *localStorys = [[StoryManager shareManager] getAll];
        storys = localStorys;
        [hud hide];
        if([localStorys count]>0){
            
            StoryModel *s = [localStorys objectAtIndex:0];
            nowStory = s;
            int lastId = s.ID;
            if(lastId!=firstId){
                [self initView];
                
//                [self openbook];
                firstId = lastId;
            }
        }else{
            
        }
    }];
    lastNetStatus = ReachableViaWiFi;
    [self bindNetEvent];
    
//    [self addChildViewController:bookview];
//        [[self view] addSubview:[bookview view]];
//        [bookview didMoveToParentViewController:self];
//    
//
//    [self performSelector:@selector(showBookView) withObject:self afterDelay:1.0f];
//    

}

-(void)updateStoryData
{
    NSLog(@"唤醒，重新请求");
    
    [[StoryManager shareManager] getAllFromOnlineWithFirstID:firstId success:^(NSMutableArray *_storys) {
        for(int i=0;i<[_storys count];i++){
            [[StoryManager shareManager] add:[_storys objectAtIndex:i]];
        }
        if([_storys count]>0){
            NSMutableArray *localStorys = [[StoryManager shareManager] getAll];
            storys = localStorys;
            //        [hud hide];
            if(localStorys!=nil&&[localStorys count]>0){
                
                StoryModel *s = [localStorys objectAtIndex:0];
                if(s!=nil){
                    NSLog(@"now:%d",s.ID);
                    NSLog(@"firstId:%d",firstId);
                    nowStory = s;
                    int lastId = s.ID;
                    if(lastId!=firstId){
                        [self initView];
                        
//                        [self openbook];
                        firstId = lastId;
                    }
                }
                
            }else{
                
            }
        }
        
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initView
{
    viewController1.story = nowStory;
    
        [self.view bringSubviewToFront:viewController1.view];
        
        //        viewController2.story = storys[nowIndex+1];
        //        [self addChildViewController:viewController2];
        //        [self.view addSubview:viewController2.view];
        //        [self.view bringSubviewToFront:viewController2.view];
        [viewController1  reinit];
    
        activeStoryController = viewController1;
        [self.view bringSubviewToFront:coverView];
        [self performSelector:@selector(openbook) withObject:self afterDelay:1];
    
//    [viewController2 reinit];
}
- (void)requestList:(int)page{
//    [SVProgressHUD showWithStatus:@"加载中"];
    if(!hasNoMore){
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.html-js.com/music.json?page=%d",page]];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        if([responseObject count]<=0){
            hasNoMore = YES;
        }
        for(int i=0;i<[responseObject count];i++){
            NSDictionary *dic = [responseObject objectAtIndex:i];
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [dic objectForKey:@"title"];
            story.desc  = [dic objectForKey:@"desc"];
            story.audio = [dic objectForKey:@"audio"];
            story.cover = [dic objectForKey:@"cover"];
            story.ID = [[dic objectForKey:@"id"] intValue];
            story.visit_count = [[dic objectForKey:@"visit_count"] intValue];
            story.num = [[dic objectForKey:@"index"] intValue];


            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            [storys addObject:story];
        }
        
//        [SVProgressHUD showSuccessWithStatus:@"加载成功"];
        if(page==1){
           [self initView];
        }
        
//                [self openbook];
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
    }
}
// Add this Method
//- (BOOL)prefersStatusBarHidden
//{
//    return YES;
//}
-(void)openbook
{
    CATransition *  tran=[CATransition animation];
    tran.type = @"pageCurl";
    tran.subtype = kCATransitionFromRight;
    tran.fillMode = kCAFillModeForwards;
    [tran setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [tran setRemovedOnCompletion:NO];
    tran.duration=1.5f;
    tran.delegate=self;
    [self.view.layer addAnimation:tran forKey:@"cover"];
    [coverView removeFromSuperview];
}
-(void)nextStory
{
   StoryModel *tempStory = [[StoryManager shareManager] getNext:nowStory.ID];
    
    if(tempStory==nil){
        [hud setCaption:@"已经是最新啦！"];
        [hud show];
        [hud hideAfter:1];

        return;
    }else{
        nowStory = tempStory;
    }
    
    [self nextPage];
}
-(void)prevStory
{
    StoryModel *tempStory = [[StoryManager shareManager] getPrev:nowStory.ID];
    
    if(tempStory==nil){
        [hud setCaption:@"已经是最新啦！"];
        [hud show];
        [hud hideAfter:1];
        return;
    }else{
        nowStory = tempStory;
    }
    nowIndex--;
    
    [self prevPage];
}
-(void)nextPage
{
    [viewController2 stop];
    [viewController1 stop];
    if(nowIndex%2==1){
        viewController2.story = nowStory;
        [viewController2 reinit];
        CATransition *  tran=[CATransition animation];
        tran.type = @"pageCurl";
        tran.subtype = kCATransitionFromRight;
        tran.fillMode = kCAFillModeForwards;
        [tran setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [tran setRemovedOnCompletion:NO];
        tran.duration=1.0f;
        tran.delegate=self;
        [self.view.layer addAnimation:tran forKey:@"dd"];
        [self.view bringSubviewToFront:viewController2.view];
        [viewController1 stopAll];
        activeStoryController = viewController2;
    }else{
        viewController1.story = nowStory;
        [viewController1  reinit];
        CATransition *  tran=[CATransition animation];
        tran.type = @"pageCurl";
        tran.subtype = kCATransitionFromRight;
        tran.fillMode = kCAFillModeForwards;
        [tran setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [tran setRemovedOnCompletion:NO];
        tran.duration=1.0f;
        tran.delegate=self;
        [self.view.layer addAnimation:tran forKey:@"dd"];
        [self.view bringSubviewToFront:viewController1.view];
        [viewController2 stopAll];
        activeStoryController = viewController1;
    }
}
-(void)prevPage
{
    [viewController2 stop];
    [viewController1 stop];
    if(nowIndex%2==1){
        viewController2.story = nowStory;
        [viewController2 reinit];
        CATransition *  tran=[CATransition animation];
        tran.type = @"pageUnCurl";
        tran.subtype = kCATransitionFromRight;
        tran.fillMode = kCAFillModeBackwards;
        [tran setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [tran setRemovedOnCompletion:NO];
        tran.duration=1.0f;
        tran.delegate=self;
        [self.view.layer addAnimation:tran forKey:@"dd"];
        [self.view bringSubviewToFront:viewController2.view];
        [viewController1 stopAll];
        activeStoryController = viewController2;
    }else{
        viewController1.story = nowStory ;
        [viewController1  reinit];
        CATransition *  tran=[CATransition animation];
        tran.type = @"pageUnCurl";
        tran.subtype = kCATransitionFromRight;
        tran.fillMode = kCAFillModeBackwards;
        [tran setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [tran setRemovedOnCompletion:NO];
        tran.duration=1.0f;
        tran.delegate=self;
        [self.view.layer addAnimation:tran forKey:@"dd"];
        [self.view bringSubviewToFront:viewController1.view];
        [viewController2 stopAll];
        activeStoryController = viewController1;
    }

}
-(IBAction)next:(id)sender
{
    [self nextStory];
}
-(IBAction)prev:(id)sender
{
    [self prevStory];
}

-(void)playNext
{
    [self nextStory];
    if(activeStoryController!=nil){
        [activeStoryController playOrStop];
    }
}
-(void)playPrev
{
    [self prevStory];
    if(activeStoryController!=nil){
        [activeStoryController playOrStop];
    }
}
-(void)toStory:(int)ID
{
    nowStory = [[StoryManager shareManager] get:ID];
    if(nowStory!=nil){
        [self nextPage];
    }
}
-(void)tolist
{
//    NSString *storyName = @"Main";
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//    {
//        storyName = @"ipad";
//    }
//
//    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
//    FavTableViewController *c = [story instantiateViewControllerWithIdentifier:@"fav"];
//    c.containerDelegate = self;
//    [self presentViewController:c  animated:YES completion:^{
//        
//    }];
//
    [self showMenu];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



-(void)showMenu{
    if(menuView==nil){
        menuView  = [[MenuViewController alloc] init];
        [menuView setPopinTransitionStyle:BKTPopinTransitionStyleSpringySlide];
        float menuW = 240;
        float menuH = 290;
        menuView.containerDelegate = self;
        [menuView setPreferedPopinContentSize:CGSizeMake(menuW, menuH)];
        [menuView setPopinTransitionDirection:BKTPopinTransitionDirectionTop];
    }
    
    
    [self presentPopinController:menuView animated:YES completion:^{
        NSLog(@"Popin presented !");
    }];
}
-(void)toAllStoryList{
        NSString *storyName = @"Main";
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            storyName = @"ipad";
        }
    
        UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
        AllStoryTableViewController *c = [story instantiateViewControllerWithIdentifier:@"all"];
        c.containerDelegate = self;
        [self presentViewController:c  animated:YES completion:^{
            
        }];
}
-(void)toFavList{
    NSString *storyName = @"Main";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        storyName = @"ipad";
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
    FavTableViewController *c = [story instantiateViewControllerWithIdentifier:@"fav"];
    c.containerDelegate = self;
    [self presentViewController:c  animated:YES completion:^{
        
    }];
}

-(void)share:(NSString *)text url:(NSString *)url image:(NSString *)image
{
    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:image];

    [UMSocialData defaultData].urlResource = urlResource;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = url;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = url;
    if([url isEqualToString:@"http://www.html-js.com/music"]){
         [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeText;
    }else{
        [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
    }
    
    [[PMParentalGateQuestion sharedGate] presentGateWithText:@"分享到第三方需要证明你是孩子家长，请回答以下问题" timeout:14.0f finishedBlock:^(BOOL allowPass, GateResult result) {
        if (allowPass) {
            NSLog(@"It's not a kid");
        } else {
            NSLog(@"Something's not right!");
        }
        
        if(!allowPass){
            [[[UIAlertView alloc] initWithTitle:@"家长保护验证失败"
                                        message:[NSString stringWithFormat:@"家长保护验证失败！"]
                                       delegate:nil
                              cancelButtonTitle:@"好吧"
                              otherButtonTitles: nil] show];
        }else{
            [UMSocialSnsService presentSnsIconSheetView:self
                                                 appKey:@"552fc46efd98c5cf6c0008bd"
                                              shareText:text
                                             shareImage:nil
                                        shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToRenren,UMShareToDouban,UMShareToSms,UMShareToFacebook,UMShareToTwitter,nil]
                                               delegate:nil];
        }
        
    }];
    
}
-(void)openWebView:(NSString *)url
{
    NSString *storyName = @"Main";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        storyName = @"ipad";
    }
    
    UIStoryboard *story = [UIStoryboard storyboardWithName:storyName bundle:nil];
    WebViewController *webview = [story instantiateViewControllerWithIdentifier:@"webview"];
   
    [self presentViewController:webview  animated:YES completion:^{
         [webview load:url];
    }];
}
-(void)bindNetEvent
{

    [VCLReachability subscribeToReachabilityNotificationsWithDelegate:self];
    if(lastNetStatus==ReachableViaWWAN){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"流量提示" message:@"播放故事会耗费一定的流量，请在WIFI环境下播放！" delegate:self cancelButtonTitle:@"知道啦，卓老师~" otherButtonTitles:nil];
        [alert show];

    }
}

/*
 Broadcast based on reachability object to update UI
 */
- (void)updateWithReachability:(VCLReachability *)reachability forType:(NSString*)type
{
    NetworkStatus netStatus = [reachability currentReachabilityStatus];
    NSLog(@"netStatus:%ld",(long)netStatus);
    if (netStatus == NotReachable) {
        [hud setCaption:@"请连接网络才能使用!"];
        [hud show];
        lastNetStatus= NotReachable;
    }else if(lastNetStatus == NotReachable){
        
        [hud hide];
    }
}
@end
