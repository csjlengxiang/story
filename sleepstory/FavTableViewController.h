//
//  FavTableViewController.h
//  sleepstory
//
//  Created by yutou on 15/4/21.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerDelegate.h"
#import "FavStoryCell.h"
@interface FavTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property id<ContainerDelegate> containerDelegate;
@end
