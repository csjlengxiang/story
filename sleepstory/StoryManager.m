//
//  StoryManager.m
//  sleepstory
//
//  Created by yutou on 15/4/21.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "StoryManager.h"
#import "AFNetworking/AFNetworking.h"
@implementation StoryManager
static StoryManager * instance;
+(StoryManager *)shareManager
{
    if(instance!=nil){
        return instance;
    }else{
        instance = [[StoryManager alloc] init];
        [instance open];
        return instance;
    }
}
-(void)open
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [directoryPaths objectAtIndex:0];
    
    NSString *databaseFile = [NSString stringWithFormat:@"%@/database.sqlite",documentsDirectoryPath];
    
    int result = sqlite3_open([databaseFile UTF8String], &database);
    
}
-(void)createTable
{
    [self execSql:@"create table storys(id integer,num integer,title varchar(100),desc text,cover varchar(255),audio varchar(255),visit_count integer,time integer)"];
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(database, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(database);
        NSLog(@"数据库操作数据失败!");
    }
}
-(void)add:(StoryModel*)story
{
    
    //执行查询
    NSString *query =[NSString stringWithFormat:@"insert into storys (id,num,title,desc,cover,audio,visit_count,time) values (%d,%d,%@,%@,%@,%@,%d,%d)",
                      story.ID,story.num,story.title,story.desc,story.cover,story.audio,
                      story.visit_count,(int)[story.time timeIntervalSince1970]] ;
    
    NSLog(@"query:%@",query);
    [self execSql:query];
    
}

-(NSMutableArray *)getAll
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //执行查询
    NSString *query = @"SELECT id,num,title,desc,cover,audio,visit_count,time from storys order by num desc ";
    sqlite3_stmt *statement;
    
    
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            //获得数据
            int ID = sqlite3_column_int(statement,0);
            int num = sqlite3_column_int(statement,1);
            char *title = (char *)sqlite3_column_text(statement, 2);
            char *desc = (char *)sqlite3_column_text(statement, 3);
            char *cover = (char *)sqlite3_column_text(statement, 4);
            char *audio = (char *)sqlite3_column_text(statement, 5);
            int visit_count = sqlite3_column_int(statement, 6);
//            char *time = (char *)sqlite3_column_text(statement, 7);
            
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
            story.ID = ID;
            story.visit_count =visit_count;
            story.num = num;
            //            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            [result addObject:story];

            
        }
        sqlite3_finalize(statement);
    }
    return result;
    
}
-(void)del:(int)id
{
    //执行查询
    NSString *query =[NSString stringWithFormat:@"delete from favs where story_id=%d",id];
    NSLog(@"query:%@",query);
    [self execSql:query];
}
-(void)getAllFromOnlineWithFirstID:(int)id success: (void (^)(NSMutableArray *storys))success

{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.html-js.com/music.json?last_id=%d",id]];
    NSMutableArray *storys = [[NSMutableArray alloc] init];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSArray *responseObject) {
        
        for(int i=0;i<[responseObject count];i++){
            NSDictionary *dic = [responseObject objectAtIndex:i];
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [dic objectForKey:@"title"];
            story.desc  = [dic objectForKey:@"desc"];
            story.audio = [dic objectForKey:@"audio"];
            story.cover = [dic objectForKey:@"cover"];
            story.ID = [[dic objectForKey:@"id"] intValue];
            story.visit_count = [[dic objectForKey:@"visit_count"] intValue];
            story.num = [[dic objectForKey:@"index"] intValue];
//            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            [storys addObject:story];
        }
        success(storys);
        //                [self openbook];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}
@end
