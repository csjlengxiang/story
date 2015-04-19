//
//  StoryView.m
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "StoryView.h"

@implementation StoryView
{
    UIView *navView;
    UIView *contentView;
    UIImageView *blurCoverView;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)draw{
    navView = [[UIView alloc] init];
    navView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
    
    blurCoverView = [[UIImageView alloc] init];
    blurCoverView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    
//            UIImage* image = nil;
//    
//            UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT));
//    
//            CGContextRef resizedContext = UIGraphicsGetCurrentContext();
//            CGContextTranslateCTM(resizedContext, 0, - self.scrollView.contentOffset.y);
//            [ mainView.layer renderInContext:resizedContext];
//            image = UIGraphicsGetImageFromCurrentImageContext();
//    
//            UIGraphicsEndImageContext();
//    
//            GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
//            GPUImageGaussianBlurFilter *stillImageFilter = [[GPUImageGaussianBlurFilter alloc] init];
//    
//            [stillImageSource addTarget:stillImageFilter];
//    
//            [stillImageFilter useNextFrameForImageCapture];
//            [stillImageSource processImage];
//    
//            UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
//    _sideFilterView.hidden = NO;
    //        _sideFilterView.image = currentFilteredVideoFrame;

}

@end
