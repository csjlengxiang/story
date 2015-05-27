//
//  FavManager.h
//  sleepstory
//
//  Created by yutou on 15/4/21.
//  Copyright (c) 2015年 html-js. All rights reserved.
//
#import "sqlite3.h"
#import "StoryModel.h"
#import "StoryManager.h"
#import <Foundation/Foundation.h>
#define kDatabaseName @"database.sqlite"
@interface FavManager : NSObject
{
    
        sqlite3 *database;
}
+(FavManager *)shareManager;
-(void)addFav:(int)id;
-(void)createTable;
-(NSMutableArray *)getAllFav;
-(void)delFav:(int)id;
-(BOOL)isFaved:(int)id;
@end
