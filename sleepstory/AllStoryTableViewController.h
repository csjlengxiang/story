//
//  AllStoryTableViewController.h
//  sleepstory
//
//  Created by yutou on 15/5/23.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContainerDelegate.h"
#import "FavStoryCell.h"
@interface AllStoryTableViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
@property id<ContainerDelegate> containerDelegate;
@end
