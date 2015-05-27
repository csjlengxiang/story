//
//  StoryModel.h
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StoryModel : NSObject
@property NSString *title; //标题
@property NSString *desc; //故事简介
@property NSString *cover; //故事封面
@property NSString *audio; //故事音频的在线地址
@property int num; //故事期数
@property int visit_count; //故事被播放的次数
@property int ID; //故事的id
@property NSDate *time; //这个故事的日期
@property NSString *zip;//故事包的zip地址
@end
