//
//  ViewController.h
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDLabelView.h"
#import "EMAsyncImageView.h"
#import "NCMusicEngine.h"
#import "StoryModel.h"
#import "ContainerDelegate.h"
#import "YDSlider.h"
#import "NSObject+VCLReachabilitySubscriber.h"
@interface StoryViewController : UIViewController<NCMusicEngineDelegate,VCLReachabilitySubscriber>
@property StoryModel *story;
@property id<ContainerDelegate> containerDelegate;

-(void)reinit;
-(IBAction)stop;
-(IBAction)playOrStop;
-(void)stopAll;
@end

