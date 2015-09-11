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
    
    NSString *databaseFile = [NSString stringWithFormat:@"%@/database.bin",documentsDirectoryPath];
    
    int result = sqlite3_open([databaseFile UTF8String], &database);
    
}
-(void)createTable
{
    [self execSql:@"create table storys(id integer,num integer,title varchar(100),desc text,cover varchar(255),audio varchar(255),visit_count integer,time integer,zip varchar(500))"];
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
    StoryModel *s = [self get:story.ID];
    if(s!=nil){
        //执行查询
        NSString *query =[NSString stringWithFormat:@"update storys set(id,num,title,desc,cover,audio,visit_count,time,zip) values (%d,%d,'%@','%@','%@','%@',%d,%d,'%@') where id=%d",
                          story.ID,story.num,story.title,story.desc,story.cover,story.audio,
                          story.visit_count,(int)[story.time timeIntervalSince1970],story.ID,story.zip] ;
        
//        NSLog(@"query:%@",query);
        [self execSql:query];
    }else{
        //执行查询
        NSString *query =[NSString stringWithFormat:@"insert into storys (id,num,title,desc,cover,audio,visit_count,time,zip) values (%d,%d,'%@','%@','%@','%@',%d,%d,'%@')",
                          story.ID,story.num,story.title,story.desc,story.cover,story.audio,
                          story.visit_count,(int)[story.time timeIntervalSince1970],story.zip] ;
        
//        NSLog(@"query:%@",query);
        [self execSql:query];
    }
    
    
    
}
-(StoryModel*)get:(int)id
{
    StoryModel *story ;
    //执行查询
    NSString *query =[NSString stringWithFormat:@"SELECT id,num,title,desc,cover,audio,visit_count,time,zip from storys where id=%d",id] ;
    sqlite3_stmt *statement;
    
    
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            story = [[StoryModel alloc] init];
            //获得数据
            int ID = sqlite3_column_int(statement,0);
            int num = sqlite3_column_int(statement,1);
            char *title = (char *)sqlite3_column_text(statement, 2);
            char *desc = (char *)sqlite3_column_text(statement, 3);
            char *cover = (char *)sqlite3_column_text(statement, 4);
            char *audio = (char *)sqlite3_column_text(statement, 5);
            int visit_count = sqlite3_column_int(statement, 6);
           
            //            int *time = sqlite3_column_int(statement, 7);
            
            
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
             char *zip = (char *)sqlite3_column_text(statement, 8);
            story.zip = [[NSString alloc] initWithUTF8String:zip];
            story.ID = ID;
            story.visit_count =visit_count;
            story.num = num;
            //            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            
            
        }
        sqlite3_finalize(statement);
    }
    return story;
}
-(StoryModel*)getNext:(int)id
{
    StoryModel *story ;
    //执行查询
    NSString *query =[NSString stringWithFormat:@"SELECT id,num,title,desc,cover,audio,visit_count,time,zip from storys where id<%d order by id desc limit 0,1",id] ;
    sqlite3_stmt *statement;
    
    
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            story = [[StoryModel alloc] init];
            //获得数据
            int ID = sqlite3_column_int(statement,0);
            int num = sqlite3_column_int(statement,1);
            char *title = (char *)sqlite3_column_text(statement, 2);
            char *desc = (char *)sqlite3_column_text(statement, 3);
            char *cover = (char *)sqlite3_column_text(statement, 4);
            char *audio = (char *)sqlite3_column_text(statement, 5);
            int visit_count = sqlite3_column_int(statement, 6);
            //            int *time = sqlite3_column_int(statement, 7);
            
            
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
            char *zip = (char *)sqlite3_column_text(statement, 8);
            story.zip = [[NSString alloc] initWithUTF8String:zip];
            story.ID = ID;
            story.visit_count =visit_count;
            story.num = num;
            //            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            
            
        }
        sqlite3_finalize(statement);
    }
    return story;
}
-(StoryModel*)getPrev:(int)id
{
    StoryModel *story ;
    //执行查询
    NSString *query =[NSString stringWithFormat:@"SELECT id,num,title,desc,cover,audio,visit_count,time,zip from storys where id>%d  order by id  limit 0,1",id] ;
    sqlite3_stmt *statement;
    
    
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK) {
        //依次读取数据库表格FIELDS中每行的内容，并显示在对应的TextField
        while (sqlite3_step(statement) == SQLITE_ROW) {
            story = [[StoryModel alloc] init];
            //获得数据
            int ID = sqlite3_column_int(statement,0);
            int num = sqlite3_column_int(statement,1);
            char *title = (char *)sqlite3_column_text(statement, 2);
            char *desc = (char *)sqlite3_column_text(statement, 3);
            char *cover = (char *)sqlite3_column_text(statement, 4);
            char *audio = (char *)sqlite3_column_text(statement, 5);
            int visit_count = sqlite3_column_int(statement, 6);
            //            int *time = sqlite3_column_int(statement, 7);
            
            
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
            char *zip = (char *)sqlite3_column_text(statement, 8);
            story.zip = [[NSString alloc] initWithUTF8String:zip];
            story.ID = ID;
            story.visit_count =visit_count;
            story.num = num;
            //            story.time = [NSDate dateWithTimeIntervalSinceNow:(int)[storys count]*-86400];
            
            
        }
        sqlite3_finalize(statement);
    }
    return story;
}
-(NSMutableArray *)getAll
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //执行查询
    NSString *query = @"SELECT id,num,title,desc,cover,audio,visit_count,time,zip from storys order by num desc ";
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
//            int *time = sqlite3_column_int(statement, 7);
            
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
            char *zip = (char *)sqlite3_column_text(statement, 8);
            story.zip = [[NSString alloc] initWithUTF8String:zip];
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
-(NSMutableArray *)getAllASC
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    //执行查询
    NSString *query = @"SELECT id,num,title,desc,cover,audio,visit_count,time,zip from storys order by num asc ";
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
            //            int *time = sqlite3_column_int(statement, 7);
            
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [[NSString alloc] initWithUTF8String:title];
            story.desc  = [[NSString alloc] initWithUTF8String:desc];
            story.audio = [[NSString alloc] initWithUTF8String:audio];
            story.cover = [[NSString alloc] initWithUTF8String:cover];
            char *zip = (char *)sqlite3_column_text(statement, 8);
            story.zip = [[NSString alloc] initWithUTF8String:zip];
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
    NSString *query =[NSString stringWithFormat:@"delete from storys where id=%d",id];
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

            if([dic objectForKey:@"zip"]!=nil&&!([dic objectForKey:@"zip"]== [NSNull null])){
                story.zip = [dic objectForKey:@"zip"];
            }
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
-(void)getOneFromOnlineWithID:(int)id success:(void (^)(StoryModel *story)) success
{
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.html-js.com/music/%d.json",id]];
    NSLog(@"request:%@",URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFJSONRequestOperation *op = [[AFJSONRequestOperation alloc] initWithRequest:request];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *dic) {
            StoryModel *story = [[StoryModel alloc] init];
            story.title = [dic objectForKey:@"title"];
            story.desc  = [dic objectForKey:@"desc"];
            story.audio = [dic objectForKey:@"audio"];
            story.cover = [dic objectForKey:@"cover"];
            story.ID = [[dic objectForKey:@"id"] intValue];
            story.visit_count = [[dic objectForKey:@"visit_count"] intValue];
            story.num = [[dic objectForKey:@"index"] intValue];
        if([dic objectForKey:@"zip"]!=nil&&!([dic objectForKey:@"zip"]== [NSNull null])){
            story.zip = [dic objectForKey:@"zip"];
        }
        
//            [self add:story];
            success(story);
        //                [self openbook];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}
/**
 * 某个故事是否有存在于本地的解压后的文件夹
 */
-(BOOL)hasZip:(int)ID
{
    //    self.spineLocation = UIPageViewControllerSpineLocationMid;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/storys/%d",ID ]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    return [fileManager fileExistsAtPath:outputPath isDirectory:&isDir];;
}

-(void)downloadZip:(NSString *)zipUrl storyID:(int)ID success:(void (^)(void))success error:(void (^)(void))error
{
//    AFHTTPClient    *_httpClient;
    NSURL *url = [NSURL URLWithString:zipUrl];
//    _httpClient = [[AFHTTPClient alloc] init];
    // 1. 建立请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 2. 操作
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
//    _downloadOperation = op;
    
    // 下载
    // 指定文件保存路径，将文件保存在沙盒中
    //    self.spineLocation = UIPageViewControllerSpineLocationMid;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *storyFold = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/storys" ]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = YES;
    if(![fileManager fileExistsAtPath:storyFold isDirectory:&isDir]){
        [fileManager createDirectoryAtPath:storyFold withIntermediateDirectories:YES attributes:nil error:nil];
    }

    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/storys/%d.zip",ID ]];
    NSString *outputFold = [documentsDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"/storys/%d",ID ]];
    op.outputStream = [NSOutputStream outputStreamToFileAtPath:outputPath append:NO];
    
    // 设置下载进程块代码
    /*
     bytesRead                      当前一次读取的字节数(100k)
     totalBytesRead                 已经下载的字节数(4.9M）
     totalBytesExpectedToRead       文件总大小(5M)
     */
    [op setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        
        // 设置进度条的百分比
        CGFloat precent = (CGFloat)totalBytesRead / totalBytesExpectedToRead;
        NSLog(@"downloading zip:%f", precent);
        

    }];
    
    // 设置下载完成操作
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {

        [SSZipArchive unzipFileAtPath:outputPath toDestination:outputFold];
        
        [[NSFileManager defaultManager] removeItemAtPath:outputPath error:nil];
        success();
        // 下一步可以进行进一步处理，或者发送通知给用户。
        NSLog(@"下载成功");
    } failure:^(AFHTTPRequestOperation *operation, NSError *_error) {
        error();
        NSLog(@"下载失败");
    }];
    
    // 启动下载
    [[NSOperationQueue mainQueue] addOperation:op];
}
@end
