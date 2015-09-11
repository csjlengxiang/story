//
//  MenuViewController.m
//  sleepstory
//
//  Created by yutou on 15/5/23.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()
{
    UIView *menuView;
    UIView *shadowView;
}
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createPopup];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)createPopup
{
   
    
    menuView = [[UIView alloc] init];
    float menuW = 240;
    float menuH = 290;
    menuView.frame = CGRectMake(0, 0, menuW, menuH);
    menuView.layer.cornerRadius = 8;
    menuView.clipsToBounds = YES;
    menuView.backgroundColor = [SYUtil colorWithHex:@"eeeeee"];
    menuView.layer.shadowOffset = CGSizeMake(2, 2);
    menuView.layer.shadowRadius = 15;
    
    menuView.layer.shadowColor = [SYUtil colorWithHex:@"111111"].CGColor;
    
    [self.view addSubview:menuView];
    
    UIButton *allButton = [[UIButton alloc] init];
    allButton.frame = CGRectMake(40, 40, 160, 40);
    allButton.backgroundColor = [SYUtil colorWithHex:@"444444"];
    [allButton setTitleColor:[SYUtil colorWithHex:@"ffffff"] forState:UIControlStateNormal];
    [allButton setTitle:@"所有绘本" forState:UIControlStateNormal];
    allButton.layer.cornerRadius = 8;
    [allButton addTarget:self action:@selector(toAll) forControlEvents:UIControlEventTouchDown];
    allButton.clipsToBounds = YES;
    UIImageView *allicon = [[UIImageView alloc] init];
    allicon.image = [UIImage imageNamed:@"bookmark-white-256.png"];
    allicon.frame = CGRectMake(11, 8, 25, 25);
    
    [allButton addSubview:allicon];
    
    [menuView addSubview:allButton];
    UIButton *favButton = [[UIButton alloc] init];
    favButton.frame = CGRectMake(40, 90, 160, 40);
    favButton.backgroundColor = [SYUtil colorWithHex:@"444444"];
    [favButton setTitleColor:[SYUtil colorWithHex:@"ffffff"] forState:UIControlStateNormal];
    [favButton setTitle:@"我的收藏" forState:UIControlStateNormal];
    favButton.layer.cornerRadius = 8;
    
    favButton.clipsToBounds = YES;
    [favButton addTarget:self action:@selector(toFav) forControlEvents:UIControlEventTouchDown];
    UIImageView *icon = [[UIImageView alloc] init];
    icon.image = [UIImage imageNamed:@"flower-white-256.png"];
    icon.frame = CGRectMake(13, 7, 25, 25);
    
    [favButton addSubview:icon];
    
    [menuView addSubview:favButton];
    
    UIButton *aboutButton = [[UIButton alloc] init];
    aboutButton.frame = CGRectMake(40, 150, 160, 40);
    aboutButton.backgroundColor = [SYUtil colorWithHex:@"444444"];
    [aboutButton setTitleColor:[SYUtil colorWithHex:@"ffffff"] forState:UIControlStateNormal];
    [aboutButton setTitle:@"关于二十一点" forState:UIControlStateNormal];
    aboutButton.layer.cornerRadius = 8;
    aboutButton.clipsToBounds = YES;
    
    //    [menuView addSubview:aboutButton];
    
    UIButton *copyButton = [[UIButton alloc] init];
    copyButton.frame = CGRectMake(40, 160, 160, 40);
    copyButton.backgroundColor = [SYUtil colorWithHex:@"999999"];
    [copyButton setTitleColor:[SYUtil colorWithHex:@"ffffff"] forState:UIControlStateNormal];
    [copyButton setTitle:@"版权声明" forState:UIControlStateNormal];
    copyButton.layer.cornerRadius = 8;
    copyButton.clipsToBounds = YES;
    [copyButton addTarget:self action:@selector(toAbout) forControlEvents:UIControlEventTouchDown];
    
    [menuView addSubview:copyButton];
    UIButton *fButton = [[UIButton alloc] init];
    fButton.frame = CGRectMake(40, 210, 160, 40);
    fButton.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    [fButton setTitleColor:[SYUtil colorWithHex:@"ffffff"] forState:UIControlStateNormal];
    [fButton setTitle:@"告诉朋友" forState:UIControlStateNormal];
    fButton.layer.cornerRadius = 8;
    fButton.clipsToBounds = YES;
    [fButton addTarget:self action:@selector(share) forControlEvents:UIControlEventTouchDown];
    
    [menuView addSubview:fButton];
    
    UIButton *cancel = [[UIButton alloc] init];
    [cancel setBackgroundImage:[UIImage imageNamed:@"cancel-gray-256.png"] forState:UIControlStateNormal];
    cancel.frame = CGRectMake(menuW - 45, 5, 40, 40);
    [cancel addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchDown];
    [menuView addSubview:cancel];
}

-(void)close
{
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{
        NSLog(@"Popin dismissed !");
    }];
}
-(void)toAll
{
    [self.containerDelegate toAllStoryList];
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{
        NSLog(@"Popin dismissed !");
    }];
}
-(void)toFav
{
    [self.containerDelegate toFavList];
    [self.presentingPopinViewController dismissCurrentPopinControllerAnimated:YES completion:^{
        NSLog(@"Popin dismissed !");
    }];
    
}
-(void)share
{
    [self.containerDelegate share:@"二十一点睡前故事，是卓老师个人维护的微信公众号，几个月来每天坚持更新一个儿童故事，现在我们有自己的App啦，背景播放自动连播，更有内置绘本预览功能，边看边听两不误，准爸妈的育儿小帮手，点击下载收听：http://www.html-js.com/music" url:@"http://www.html-js.com/music" image:@"http://htmljs.b0.upaiyun.com/uploads/1432657726207-7b78790a8a373eb68f08fae3db50c7af.png"];

}
-(void)toAbout
{
    [self.containerDelegate openWebView:@"http://www.html-js.com/static/story.html"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
