//
//  FavStoryCell.h
//  sleepstory
//
//  Created by yutou on 15/4/25.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StoryModel.h"
#import "EMAsyncImageView.h"
#import "UIImageView+WebCache.h"
@interface FavStoryCell : UITableViewCell
-(void)setStory:(StoryModel *)_story;
@end
