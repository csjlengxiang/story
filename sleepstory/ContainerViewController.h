//
//  ContainerViewController.h
//  sleepstory
//
//  Created by tianqi on 15/3/19.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerDelegate.h"
#import "FavTableViewController.h"
#import "NSObject+VCLReachabilitySubscriber.h"
@interface ContainerViewController : UIViewController<ContainerDelegate,VCLReachabilitySubscriber>
-(void)updateStoryData;
@end
