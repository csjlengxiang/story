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
#import "SSZipArchive.h"
#import <Foundation/Foundation.h>

@interface StoryManager : NSObject
{
    
    sqlite3 *database;
}
+(StoryManager *)shareManager;
-(StoryModel*)get:(int)id;
-(void)createTable;
-(void)add:(StoryModel*)story;
-(NSMutableArray *)getAll;
-(NSMutableArray *)getAllASC;
-(StoryModel*)getPrev:(int)id;
-(StoryModel*)getNext:(int)id;
-(BOOL)hasZip:(int)ID;
-(void)getAllFromOnlineWithFirstID:(int)id success: (void (^)(NSMutableArray *storys))success;
-(void)getOneFromOnlineWithID:(int)id success:(void (^)(StoryModel *story)) success;

-(void)downloadZip:(NSString *)zipUrl storyID:(int)ID success:(void (^)(void))success error:(void (^)(void))error;
@end
