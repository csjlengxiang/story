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
#import "SVProgressHUD.h"
#import "StoryManager.h"
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
}
@end

@implementation ContainerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [SYUtil colorWithHex:@"e15151"];
    self.navigationController.navigationBar.translucent = NO;
    [self setNeedsStatusBarAppearanceUpdate];
    storys = [[NSMutableArray alloc] init];
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //生成两个界面，用来翻页的切换
    viewController1 = [story instantiateViewControllerWithIdentifier:@"main"];
    viewController2 = [story instantiateViewControllerWithIdentifier:@"main"];
    viewController1.containerDelegate = self;
    viewController2.containerDelegate = self;
    //把页面添加到容器中
    [self addChildViewController:viewController1];
    [self addChildViewController:viewController2];
    [self.view addSubview:viewController1.view];
    [self.view addSubview:viewController2.view];
    nowIndex = 0;
    nowPage = 1;
    hasNoMore = false;
    //开始请求故事的信息
//    [self requestList:nowPage];
    
    coverView = [[UIImageView alloc] init];
    coverView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    coverView.image = [UIImage imageNamed:@"cover.png"];
    [self.view addSubview:coverView];
    
    NSMutableArray *localStorys = [[StoryManager shareManager] getAll];
    storys = localStorys;
    
    int firstId = 0;
    if([localStorys count]>0){
        StoryModel *s = [localStorys objectAtIndex:0];
        firstId = s.ID;
        [self initView];
    }else{
        
    }
    [[StoryManager shareManager] getAllFromOnlineWithFirstID:firstId success:^(NSMutableArray *storys) {
        for(int i=0;i<[storys count];i++){
            [[StoryManager shareManager] add:[storys objectAtIndex:i]];
        }
        NSMutableArray *localStorys = [[StoryManager shareManager] getAll];
        storys = localStorys;
        [self initView];
    }];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)initView
{

    if([storys count]>0){
        viewController1.story = storys[nowIndex];
        
        
        [self.view bringSubviewToFront:viewController1.view];
        
        //        viewController2.story = storys[nowIndex+1];
        //        [self addChildViewController:viewController2];
        //        [self.view addSubview:viewController2.view];
        //        [self.view bringSubviewToFront:viewController2.view];
        
        [viewController1  reinit];
        activeStoryController = viewController1;
        [self.view bringSubviewToFront:coverView];
        [self performSelector:@selector(openbook) withObject:self afterDelay:1];
    }else{
        
    }
    
//    [viewController2 reinit];
}
- (void)requestList:(int)page{
    [SVProgressHUD showWithStatus:@"加载中"];
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
        
        [SVProgressHUD showSuccessWithStatus:@"加载成功"];
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
    nowIndex++;
    [viewController2 stop];
    [viewController1 stop];
    if(nowIndex%2==1){
        viewController2.story = storys[nowIndex];
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
        viewController1.story = storys[nowIndex];
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

    
    if(nowIndex>=[storys count]-3){
        nowPage++;
        [self requestList:nowPage];
    }
}
-(void)prevStory
{
    
    if(nowIndex<=0){
        nowIndex = 0;
        [SVProgressHUD showErrorWithStatus:@"已经是最新啦！" duration:1];
        return;
    }
    nowIndex--;
    [viewController2 stop];
    [viewController1 stop];
    if(nowIndex%2==1){
        viewController2.story = storys[nowIndex];
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
        viewController1.story = storys[nowIndex];
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
-(void)tolist
{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *c = [story instantiateViewControllerWithIdentifier:@"list"];
    [self presentViewController:c  animated:YES completion:^{
        
    }];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
