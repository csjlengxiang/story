//
//  OneBookViewController.m
//  sleepstory
//
//  Created by yutou on 15/4/27.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "OneBookViewController.h"
#import "UIImageView+WebCache.h"
@interface OneBookViewController ()
{
    UIImageView *imageview;
    NSString *imageUrl;
}
@end

@implementation OneBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imageview = [[UIImageView alloc] init];
    float _w = SCREEN_WIDTH;
    float _h = SCREEN_HEIGHT;
    if(SCREEN_WIDTH<SCREEN_HEIGHT){
        _w = SCREEN_HEIGHT;
        _h = SCREEN_WIDTH;
    }
    imageview.frame = CGRectMake(0, 0,_w/2, _h);
//    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:imageview];
    imageview.image = [UIImage imageWithContentsOfFile:imageUrl];
//    [imageview sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    // Do any additional setup after loading the view.
}
-(void)setImage:(NSString *)url
{
    NSString *encodeURI = [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    imageUrl = encodeURI;
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    if(fromInterfaceOrientation == UIDeviceOrientationPortrait){
//        imageview.frame = CGRectMake(0, 0,SCREEN_WIDTH/2, SCREEN_HEIGHT);
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
