//
//  StoryView.h
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryModel.h"

@interface StoryView : UIView
@property StoryModel *data;
-(void)draw;
@end
