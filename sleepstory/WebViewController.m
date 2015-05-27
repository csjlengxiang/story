//
//  WebViewController.m
//  sleepstory
//
//  Created by yutou on 15/5/23.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
{
   IBOutlet UIWebView *webview;
    IBOutlet UIView *navBar;
}
@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    navBar.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)cancel:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(IBAction)hover:(id)sender
{
    [self rotate360DegreeWithImageView:sender];
}
- (UIButton *)rotate360DegreeWithImageView:(UIButton *)imageView{
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.3;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 6;
    
    //    //在图片边缘添加一个像素的透明区域，去图片锯齿
    //    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    //    UIGraphicsBeginImageContext(imageRrect.size);
    //    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    //    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    [imageView.layer addAnimation:animation forKey:nil];
    return imageView;
}
-(void)load:(NSString *)url
{

    if(url!=nil){
        NSURLRequest *request =[NSURLRequest requestWithURL:[NSURL URLWithString:url ]];
        [webview loadRequest:request];
        
    }
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
