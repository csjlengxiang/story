//
//  StoryManager.h
//  sleepstory
//
//  Created by yutou on 15/4/21.
//  Copyright (c) 2015年 html-js. All rights reserved.
//
//
#import "sqlite3.h"
#import "StoryModel.h"
#import <Foundation/Foundation.h>

@interface StoryManager : NSObject
{
    
    sqlite3 *database;
}
+(StoryManager *)shareManager;

-(void)createTable;
-(void)add:(StoryModel*)story;
-(NSMutableArray *)getAll;
-(void)getAllFromOnlineWithFirstID:(int)id success: (void (^)(NSMutableArray *storys))success;
@end
