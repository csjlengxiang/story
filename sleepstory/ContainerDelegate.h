//
//  ContainerDelegate.h
//  sleepstory
//
//  Created by tianqi on 15/3/20.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#ifndef sleepstory_ContainerDelegate_h
#define sleepstory_ContainerDelegate_h
@protocol ContainerDelegate
-(void)nextStory;
-(void)prevStory;
-(void)playNext;
-(void)playPrev;
-(void)tolist;
@end
#endif
