//
//  BookViewController.h
//  sleepstory
//
//  Created by yutou on 15/4/27.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OneBookViewController.h"
@interface BookViewController : UIPageViewController<UIPageViewControllerDataSource,UIPageViewControllerDelegate>
@property NSString *zipPath;
-(void)playTo:(NSTimeInterval)interval total:(NSTimeInterval)totalInterval;
-(void)initWithZipUrl:(NSString *)zipUrl id:(int)ID;
@end
