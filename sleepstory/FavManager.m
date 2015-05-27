//
//  FavManager.m
//  sleepstory
//
//  Created by yutou on 15/4/21.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "FavManager.h"
#import "math.h"

@implementation FavManager
static FavManager * instance;
+(FavManager *)shareManager
{
    if(instance!=nil){
        return instance;
    }else{
        instance = [[FavManager alloc] init];
        [instance open];
        return instance;
    }
}
-(void)open
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [directoryPaths objectAtIndex:0];
    
    NSString *databaseFile = [NSString stringWithFormat:@"%@/database.bin",documentsDirectoryPath];
    
    int result = sqlite3_open([databaseFile UTF8String], &database);
    
}
-(void)createTable
{
    [self execSql:@"create table favs(story_id integer,time integer)"];
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"数据库操作数据失败!");
    }
}
-(void)addFav:(int)id
{

    NSDate *date = [NSDate date];
    
    //执行查询
    NSString *query =[NSString stringWithFormat:@"insert into favs (story_id,time) values (%d,%d)",id,(int)ceilf(date.timeIntervalSince1970)] ;

    NSLog(@"query:%@",query);
    [self execSql:query];
    
}
-(NSMutableArray *)getAllFav
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //执行查询
    NSString *query = @"SELECT story_id from favs ";
    sqlite3_stmt *statement;
    
    

    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //获得数据
            
            char *story_id = (char *)sqlite3_column_text(statement, 0);
            
            [result addObject:[[NSString alloc] initWithUTF8String:story_id]];
            
        }
        sqlite3_finalize(statement);
    }
    NSMutableArray *storys = [[NSMutableArray alloc] init];
    for(int i=0;i<[result count];i++){
        NSString *id = [result objectAtIndex:i];
        StoryModel *story = [[StoryManager shareManager] get:[id intValue]];
        if(story!=nil){
            [storys addObject:story];
        }
    }
    return storys;

}
-(void)delFav:(int)id
{
    //执行查询
    NSString *query =[NSString stringWithFormat:@"delete from favs where story_id=%d",id];
    NSLog(@"query:%@",query);
    [self execSql:query];
}
-(BOOL)isFaved:(int)id
{
    //执行查询
    NSString *query =[NSString stringWithFormat: @"SELECT story_id from favs where story_id='%d'",id];
    sqlite3_stmt *statement;
    bool isFaved = NO;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //获得数据
            isFaved = YES;
            
        }
        sqlite3_finalize(statement);
    }

    return isFaved;
}
@end
