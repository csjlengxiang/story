//
//  BookViewController.m
//  sleepstory
//
//  Created by yutou on 15/4/27.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "BookViewController.h"
#import "SSZipArchive.h"
@interface BookViewController ()
{
    NSMutableArray *imageArray;
    NSMutableArray *viewControllers;
    NSArray *timeArray;
    NSMutableArray *tempTimeArray;
    int nowPage ;
    
    UIView *progressBgView;
    UIView *progressTopView;
    NSTimeInterval totalTime;
}
@end

@implementation BookViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
}
-(void)initWithZipUrl:(NSString *)zipUrl id:(int)ID
{
    
    //    self.spineLocation = UIPageViewControllerSpineLocationMid;
    NSArray  *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *outputPath = [documentsDirectory stringByAppendingPathComponent:@"/136"];
//    
//    NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"136" ofType:@"zip"];
//    
//    [SSZipArchive unzipFileAtPath:zipPath toDestination:outputPath delegate:self];
//    
    
    NSError *error;
    NSData *filedata = [NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/storys/%d/data.json",documentsDirectory,ID]];
    
    
    NSArray *data = [NSJSONSerialization JSONObjectWithData:filedata options:kNilOptions error:&error];
    timeArray = data;
    tempTimeArray = [[NSMutableArray alloc] init];
    nowPage = 0;
    totalTime = 0;
    for( int i=0;i<[timeArray count];i++){
        [tempTimeArray addObject:[timeArray objectAtIndex:i]];
    }
    NSLog(@"bookdata:%@",data);
    
    imageArray = [[NSMutableArray alloc] init];
    
    for(int i=0;i<[data count]*2;i++){
        [imageArray addObject:([NSString stringWithFormat:@"%@/storys/%d/%d.jpg",documentsDirectory,ID,i+1])];
    }
    
    //    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    //
    self.dataSource = self;
    self.delegate = self;
    [[self view] setFrame:[[self view] bounds]];
    viewControllers = [[NSMutableArray alloc] init];
    for(int i=0;i<[imageArray count];i++){
        OneBookViewController *bookViewController = [self viewControllerAtIndex:0];
        [bookViewController setImage:[imageArray objectAtIndex:i]];
        [viewControllers addObject:bookViewController];
    }
    //    [self performSelector:@selector(nextPage) withObject:self afterDelay:0.6];
    [self nextPage];
    
    UIButton *close = [[UIButton alloc] init];
    [close setBackgroundImage:[UIImage imageNamed:@"close-red-256.png"] forState:UIControlStateNormal];
    
    close.frame = CGRectMake(5, 5, 30, 30);
    [self.view addSubview:close];
    close.opaque = 0.8f;
    close.layer.cornerRadius = 15;
    close.layer.shadowOffset = CGSizeMake(2, 2);
    close.layer.shadowOpacity = 1;
    close.layer.shadowRadius = 4;
    close.layer.shadowColor = [UIColor grayColor].CGColor;
    [close addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchDown];
    
    [UIViewController attemptRotationToDeviceOrientation];
    
    [self performSelector:@selector(onDeviceOrientationChange) withObject:self afterDelay:1];
}
-(void)createdProgress
{
    progressBgView = [[UIView alloc] init];
    progressTopView = [[UIView alloc] init];
    
    progressBgView.frame = CGRectMake(10,SCREEN_HEIGHT - 20,SCREEN_WIDTH-20,2);
    progressBgView.backgroundColor = [SYUtil colorWithHex:@"F1DBA6"];
    
    [self.view addSubview:progressBgView];
    
    
    progressTopView.frame = CGRectMake(10,SCREEN_HEIGHT - 20,0,2);
    progressTopView.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    
    [self.view addSubview:progressTopView];
    
}
-(void)onDeviceOrientationChange
{
    [self createdProgress];
}
/**
 *
 */
-(void)playTo:(NSTimeInterval)interval total:(NSTimeInterval)totalInterval
{
    if([tempTimeArray count]>0){
        int nowFirstTime = [[tempTimeArray objectAtIndex:0] intValue];
        if(interval>=nowFirstTime){
            //当前秒数大于时间数组第一个值，则启动翻页
            [self nextPage];
            [tempTimeArray removeObjectAtIndex:0];
        }
    }
    if(progressTopView!=nil){
        CGRect f = progressTopView.frame;
        f.size.width =  (SCREEN_WIDTH - 20)*interval/totalInterval;
        progressTopView.frame = f;
        if(totalTime==0&&totalInterval!=0){
            totalTime = totalInterval;
            [self createPoint];
        }
    }
    
    
    
}
-(void)createPoint
{
    for(int i=0;i< [timeArray count];i++){
        int time = [[timeArray objectAtIndex:i] intValue];
        UIView *point = [[UIView alloc] init];
        point.frame = CGRectMake(10+((SCREEN_WIDTH - 20)*time/totalTime),SCREEN_HEIGHT - 22.5f,7,7);
        point.backgroundColor = [SYUtil colorWithHex:@"e15151"];
        point.layer.cornerRadius = 3.5f;
        point.layer.shadowOffset = CGSizeMake(2, 2);
        point.layer.shadowOpacity = 1;
        point.layer.shadowRadius = 2;
        point.layer.shadowColor = [UIColor grayColor].CGColor;
        [self.view addSubview:point];
    }
}
-(void)nextPage
{
    if(nowPage>= [imageArray count]){
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }else{
        NSArray *nowControllers = [NSArray arrayWithObjects:[self viewControllerAtIndex:nowPage*2],[self viewControllerAtIndex:nowPage*2+1],nil];
        
        [self setViewControllers:nowControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
        nowPage++;
    }
    
}
-(IBAction)dismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (OneBookViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    OneBookViewController *childViewController = [[OneBookViewController alloc] init];
    childViewController.index = index;
    [childViewController setImage:[imageArray objectAtIndex:index]];
    return childViewController;
    
}
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(OneBookViewController *)viewController index];
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
    
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(OneBookViewController *)viewController index];
    
    
    index++;
    
    if (index == [imageArray count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
    
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    // The number of items reflected in the page indicator.
    return [viewControllers count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    // The selected item reflected in the page indicator.
    return 0;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    NSLog(@"aa");
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    NSLog(@"aa");
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}
- (UIPageViewControllerSpineLocation)pageViewController:(UIPageViewController *)pageViewController
                   spineLocationForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return UIPageViewControllerSpineLocationMid;
}
@end
