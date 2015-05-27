//
//  AllStoryTableViewController.m
//  sleepstory
//
//  Created by yutou on 15/5/23.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "AllStoryTableViewController.h"
#import "StoryManager.h"
@interface AllStoryTableViewController ()
{
    NSMutableArray *favs;
    IBOutlet UITableView *favTableView;
    IBOutlet UIView *navBar;
}
@end

@implementation AllStoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    navBar.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    favTableView.delegate = self;
    favTableView.dataSource = self;
    [self loadAllFavs];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)loadAllFavs
{
    favs = [[StoryManager shareManager] getAll];
    [favTableView reloadData];
    
}
-(IBAction)cancel:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
-(IBAction)hover:(id)sender
{
    [self rotate360DegreeWithImageView:sender];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"FAVS COUNT:%lu",(unsigned long)[favs count]);
    // Return the number of rows in the section.
    return [favs count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FavStoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allcell" forIndexPath:indexPath];
    StoryModel *story = [favs objectAtIndex:indexPath.row];
    [cell setStory:story];
    return cell;
}
- (UIButton *)rotate360DegreeWithImageView:(UIButton *)imageView{
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.3;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 6;
    
    //    //在图片边缘添加一个像素的透明区域，去图片锯齿
    //    CGRect imageRrect = CGRectMake(0, 0,imageView.frame.size.width, imageView.frame.size.height);
    //    UIGraphicsBeginImageContext(imageRrect.size);
    //    [imageView.image drawInRect:CGRectMake(1,1,imageView.frame.size.width-2,imageView.frame.size.height-2)];
    //    imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //
    [imageView.layer addAnimation:animation forKey:nil];
    return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 115;
}
- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoryModel *story = [favs objectAtIndex:indexPath.row];
    [self.containerDelegate toStory:story.ID];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
