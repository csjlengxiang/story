//
//  MenuViewController.h
//  sleepstory
//
//  Created by yutou on 15/5/23.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIViewController+MaryPopin.h"
#import "ContainerDelegate.h"
@interface MenuViewController : UIViewController
    @property id<ContainerDelegate> containerDelegate;
@end
