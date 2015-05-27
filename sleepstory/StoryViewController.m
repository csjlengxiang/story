//
//  ViewController.m
//  sleepstory
//
//  Created by tianqi on 15/2/14.
//  Copyright (c) 2015年 html-js. All rights reserved.
//

#import "StoryViewController.h"
#import "UIImageView+WebCache.h"
#import "RoundIconButton.h"
#import "RoundLabel.h"
#import "UMSocial.h"
#import <pop/POP.h>
#import "NSDate+TimeAgo.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Track.h"
#import "DOUAudioStreamer.h"
#import "FavManager.h"
#import "ATMHud.h"
#import "BookViewController.h"
static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;
@interface StoryViewController ()
{
    IBOutlet  UILabel *numTitleLabel;
    IBOutlet  UILabel *titleLabel;
    IBOutlet UIImageView *coverView;
    IBOutlet UILabel *descLabel;

    NSTimer *progressTimer;
    
    IBOutlet UIView *progressInner;
    IBOutlet UIView *progressBg;
    IBOutlet UIView *downloadProgressBar;
    int totalDuration;
    IBOutlet NSLayoutConstraint *progressPercent;
    IBOutlet NSLayoutConstraint *downloadPercent;
     NCMusicEngine *_player;
    IBOutlet UISwipeGestureRecognizer *swipeGR;
    
    IBOutlet UIButton *playButton;
    IBOutlet UIView *navBar;
    BOOL isPlaying;
    IBOutlet UILabel *nowTimeLabel;
    IBOutlet UILabel *totalTimeLabel;
    
    IBOutlet UIButton *modeButton;
    IBOutlet UIButton *favButton;
    IBOutlet RoundLabel *viewCountLabel;
    IBOutlet RoundLabel *dayInfoLabel;
    
    YDSlider *progressSlider;
    
    DOUAudioStreamer *streamer;
    NSTimer *_timer;
    ATMHud * hud;
    
    BookViewController *bookview;
    IBOutlet NSLayoutConstraint *coverLeft;
    IBOutlet NSLayoutConstraint *coverRight;
    IBOutlet NSLayoutConstraint *coverTop;
}
@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPlaying = NO;
    totalDuration = 0;
    
    self.view.backgroundColor = [SYUtil colorWithHex:@"ffffff"];
    descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descLabel.numberOfLines = 4;

    descLabel.preferredMaxLayoutWidth = self.view.frame.size.width;
    // Override point for customization after application launch.
    
    [swipeGR addTarget:self action:@selector(nextStory)];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    [self setNeedsStatusBarAppearanceUpdate];
    navBar.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    [coverView.layer setCornerRadius:10];
    [coverView.layer setMasksToBounds:YES];    hud = [[ATMHud alloc] initWithDelegate:self];
    [self.view addSubview:hud.view];
  if(SCREEN_HEIGHT<500){
      descLabel.hidden = YES;

  }
//    progressSlider = [[YDSlider alloc] init];
//    progressSlider.frame = CGRectMake(0, 0, downloadProgressBar.frame.size.width, 3);
//    
//    
//    [self reinit];
    // Music link is temporarily searched from internet just for demo.
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)reinit
{
    if(streamer!=nil){
        [streamer removeObserver:self forKeyPath:@"status"];
        [streamer removeObserver:self forKeyPath:@"duration"];
        [streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        
        streamer = nil;
    }
    
    
    [[StoryManager shareManager] getOneFromOnlineWithID:self.story.ID success:^(StoryModel *_story) {
        self.story = _story;
        [self updateVisit];
    }];
    bookview = nil;
    descLabel.text =self.story.desc;
    titleLabel.text = self.story.title;
//    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
////    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
//[dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    dayInfoLabel.text  = [NSString stringWithFormat:@"  第%d期  ",self.story.num];
    
    viewCountLabel.text =[NSString stringWithFormat:@"  浏览次数:%d  ",self.story.visit_count] ;
    NSString *encodeURI = [self.story.cover stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [coverView sd_setImageWithURL:[NSURL URLWithString:encodeURI] placeholderImage:[UIImage imageNamed:@"loading.png"]];
    
//    numTitleLabel.text = [NSString stringWithFormat:@"第%d期",self.story.num];
//    coverView.bounds =CGRectMake(0, 0, 100, 100);
    //故事封面的弹性效果
    [self performSelector:@selector(animPic)
               withObject:nil
               afterDelay:0.5];
    [self setPlayProgress:0];
    [self setDowloadProgress:0];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-256.png"] forState:UIControlStateNormal];

    nowTimeLabel.text = @"00:00";
    totalTimeLabel.text = @"00:00";
    if(self.story.zip==nil||[@"(null)" isEqualToString:self.story.zip]){
        
        [modeButton setBackgroundImage:[UIImage imageNamed:@"bookmark-gray.png"] forState:UIControlStateNormal];
        modeButton.tag = 2;
    }else{
        [modeButton setBackgroundImage:[UIImage imageNamed:@"bookmark-256.png"] forState:UIControlStateNormal];
        modeButton.tag = 1;
    }
//    [modeButton drawIcon:[UIImage imageNamed:@"repeat-256.png"] text:@"全部循环"];
    [self checkFavStatus];
    [self configPlayingInfo];
    [self.view bringSubviewToFront:hud.view];
    
}
-(void)updateVisit
{
    viewCountLabel.text =[NSString stringWithFormat:@"  浏览次数:%d  ",self.story.visit_count] ;
}
-(void)showBookView
{
    
        NSDictionary * options = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:UIPageViewControllerSpineLocationMid] forKey:UIPageViewControllerOptionSpineLocationKey];
        
        //    UIPageViewController *pageViewController = [[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
        bookview = [[BookViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStylePageCurl navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
        [bookview initWithZipUrl:@"" id:self.story.ID];
        [self presentViewController:bookview animated:YES completion:^{
            
        }];
    
    
}
-(IBAction)showBookView:(UIButton *)sender
{
    if(sender.tag == 1){
        if([[StoryManager shareManager] hasZip:self.story.ID]){
            if(bookview!=nil){
                [self presentViewController:bookview animated:YES completion:^{
                    
                }];
            }else{
                [self showBookView];
            }
        }else{
        //开始下载
        [hud setCaption:@"下载绘本中"];
        [hud show];
        [hud hideAfter:2];
        [[StoryManager shareManager] downloadZip:self.story.zip storyID:self.story.ID success:^{
            [hud setCaption:@"绘本下载完成"];
            [hud show];
            [hud hideAfter:2];
        } error:^{
            
        }];
        }
    }else{
        
            [hud setCaption:@"此绘本暂时没有预览"];
            [hud show];
            [hud hideAfter:2];
        

    }
    
}
-(void)hideBookView
{
    if(bookview!=nil){
        [bookview dismissViewControllerAnimated:YES completion:^{
            
            
        }];
    }
}
-(void)checkFavStatus
{
    if([[FavManager shareManager] isFaved:self.story.ID]){
        [favButton setBackgroundImage:[UIImage imageNamed:@"flower-2-256.png"] forState:UIControlStateNormal];
    }else{
        [favButton setBackgroundImage:[UIImage imageNamed:@"flower-256.png"] forState:UIControlStateNormal];
    }
}
- (void)configPlayingInfo
{
    if (NSClassFromString(@"MPNowPlayingInfoCenter")) {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
        [dict setObject:self.story.title forKey:MPMediaItemPropertyTitle];
        [dict setObject:@"二十一点·睡前故事" forKey:MPMediaItemPropertyArtist];
        [dict setObject:[NSNumber numberWithInt:totalDuration] forKey:MPMediaItemPropertyPlaybackDuration];
        if(coverView.image){
            [dict setObject:[[MPMediaItemArtwork alloc] initWithImage:coverView.image] forKey:MPMediaItemPropertyArtwork];
        }
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    }
}
-(void)animPic
{ POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.delegate = self;
    anim.springSpeed = 6;
    anim.springBounciness = 20;
    //    anim.velocity = CGRectMake(0, 0, 1, 1);
    //    anim.completionBlock = ^(POPAnimation *__strong anim, BOOL hi){
    //        POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    //        anim2.springSpeed = 5;
    //        anim2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 100, 100)];
    //        [coverView pop_addAnimation:anim2 forKey:@"size2"];
    //    };
    anim.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-100, [UIScreen mainScreen].bounds.size.width-100)];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.width-40)];
    NSLog(@"SCREEN_HEIGHT:%f",SCREEN_HEIGHT);
    if(SCREEN_HEIGHT<500){
        anim.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-120, [UIScreen mainScreen].bounds.size.width-120)];
       anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, -50, [UIScreen mainScreen].bounds.size.width-90, [UIScreen mainScreen].bounds.size.width-90)];
          coverTop.constant = 0;
    }
   
    [coverView pop_addAnimation:anim forKey:@"size2"];
    
}
-(void)playOrStop
{
    //如果正在播放就暂停播放，否则就开始播放。
    if(streamer!=nil&&streamer.status==DOUAudioStreamerPlaying){
        [streamer pause];
        [playButton setBackgroundImage:[UIImage imageNamed:@"play-256.png"] forState:UIControlStateNormal];
        isPlaying = NO;
    }else{
        if(streamer==nil){
            //生成一个播放对象
            //音频的在线地址
            NSString *encodeURI = [self.story.audio stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            Track *track = [[Track alloc] init];
            [track setArtist:dayInfoLabel.text];
            [track setTitle:self.story.title];
            [track setAudioFileURL:[NSURL URLWithString:encodeURI]];

            streamer = [DOUAudioStreamer streamerWithAudioFile:track];
            [streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
            [streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
            [streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
            
            [streamer play];

            
//            //开始播放
//            [_player playUrl:[NSURL URLWithString:encodeURI]];
            //设置背景播放，关闭屏幕后仍然可以播放
            [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
            [[AVAudioSession sharedInstance] setActive: YES error: nil];
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            [self performSelector:@selector(configPlayingInfo) withObject:self afterDelay:1.0f];
            _timer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
            if([[StoryManager shareManager] hasZip:self.story.ID]){
            [self showBookView];
            }
        }else{
            [streamer play];

        }
        isPlaying = YES;
        [playButton setBackgroundImage:[UIImage imageNamed:@"pause-256.png"] forState:UIControlStateNormal];
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)_timerAction:(id)timer
{
    @try {
        if([streamer duration]>0&&[streamer expectedLength]>0){
            //设置播放进度条的进度
            [self setPlayProgress:[streamer currentTime] / [streamer duration]];
            totalDuration = [streamer duration];
            int minute = [streamer currentTime]/60;
            int secend = (int)[streamer currentTime]%60;
            //当前播放到得秒数
            nowTimeLabel.text = [NSString stringWithFormat:@"%@:%@",[self getTwoTimeString:minute],[self getTwoTimeString:secend]];
            int duration_m = [streamer duration]/60;
            int duration_s = (int)[streamer duration]%60;
            //总共需要播放的秒数
            totalTimeLabel.text =[NSString stringWithFormat:@"%@:%@",[self getTwoTimeString:duration_m],[self getTwoTimeString:duration_s]];
            NSLog(@"nowtime:%f",(float)[streamer currentTime]);
            [self setDowloadProgress:(float)[streamer receivedLength]/(float)[streamer expectedLength]];
            if(bookview!=nil){
                [bookview playTo:[streamer currentTime] total:[streamer duration]];
            }
            
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
       }
- (void)_updateBufferingStatus
{
    
    
}
-(void)_updateStatus
{
    if(streamer.status==DOUAudioStreamerPlaying){
        [playButton setBackgroundImage:[UIImage imageNamed:@"pause-256.png"] forState:UIControlStateNormal];
    }
    else{
        [playButton setBackgroundImage:[UIImage imageNamed:@"play-256.png"] forState:UIControlStateNormal];
    }
    if(streamer.status == DOUAudioStreamerFinished){
        [self hideBookView];
        [self.containerDelegate playNext];
    }
}
//播放
- (IBAction)play:(id)sender
{
//    [progressTimer fire];
    [self playOrStop];
    
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.delegate = self;
    anim.springSpeed = 20;
    anim.springBounciness = 10;
//    anim.velocity = CGRectMake(0, 0, 1, 1);
    anim.completionBlock = ^(POPAnimation *__strong anim, BOOL hi){
        POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
        anim2.springSpeed = 5;
        anim2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 70, 70)];
        [playButton pop_addAnimation:anim2 forKey:@"size2"];
    };
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, 100, 100)];
    [sender pop_addAnimation:anim forKey:@"size"];
    
}
-(IBAction)stop
{
    [streamer stop];
}


-(NSString *)getTwoTimeString:(int)time
{
    if(time<10){
        return [NSString stringWithFormat:@"0%d",time];
    }else{
        return [NSString stringWithFormat:@"%d",time];
    }
}

-(void)playPrev{
    [self.containerDelegate playPrev];
}
-(void)playNext{
    [self.containerDelegate playNext];
}
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    if (event.type == UIEventTypeRemoteControl) {
        switch (event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
                [self playOrStop]; // 切换播放、暂停按钮
                break;
            case UIEventSubtypeRemoteControlPause:
                [self playOrStop]; // 切换播放、暂停按钮
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self playPrev]; // 播放上一曲按钮
                break;
                
            case UIEventSubtypeRemoteControlNextTrack:
                [self playNext]; // 播放下一曲按钮
                break;
                
            default:
                break;
        }
    }
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
     [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
     [self becomeFirstResponder];
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
}

-(void)stopAll{
    [self setPlayProgress:0];
    [self setDowloadProgress:0];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-256.png"] forState:UIControlStateNormal];

    [_timer invalidate];
    _timer = nil;
        isPlaying = NO;
    [streamer removeObserver:self forKeyPath:@"status"];
    [streamer removeObserver:self forKeyPath:@"duration"];
    [streamer removeObserver:self forKeyPath:@"bufferingRatio"];
    streamer = nil;
}
-(void)setDowloadProgress:(float)v
{

    float bgwidth = progressBg.frame.size.width;
    if(bgwidth!=0){
        downloadPercent.constant = bgwidth - bgwidth*v;
    }else{
        
    }
    
}
-(void)setPlayProgress:(float)v
{

    float bgwidth = progressBg.frame.size.width;
    if(bgwidth!=0){
        progressPercent.constant = bgwidth - bgwidth*v;
    }else{
        
    }
    
}
-(IBAction)next:(id)sender
{
    [self.containerDelegate nextStory];
}
-(IBAction)prev:(id)sender
{
    [self.containerDelegate prevStory];
}
-(IBAction)showList:(id)sender
{
    [self.containerDelegate tolist];
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
-(IBAction)share:(id)sender
{
    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:self.story.cover];
    [UMSocialData defaultData].urlResource = urlResource;
    [UMSocialData defaultData].extConfig.wechatSessionData.url = [NSString stringWithFormat:@"http://www.html-js.com/music/%d",self.story.ID];
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = [NSString stringWithFormat:@"http://www.html-js.com/music/%d",self.story.ID];
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"552fc46efd98c5cf6c0008bd"
                                      shareText:[NSString stringWithFormat:@"二十一点·睡前故事 第%d期《%@》点击收听 http://www.html-js.com/music/%d",self.story.num,self.story.title,self.story.ID ]
                                     shareImage:nil
                                shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToSina,UMShareToQQ,UMShareToQzone,UMShareToRenren,UMShareToDouban,UMShareToSms,UMShareToFacebook,UMShareToTwitter,nil]
                                       delegate:nil];
}
-(IBAction)fav:(UIButton *)sender
{
    [self animButton:sender];
    if([[FavManager shareManager] isFaved:self.story.ID]){
        [[FavManager shareManager] delFav:self.story.ID];
        
    }else{
        [[FavManager shareManager] addFav:self.story.ID];
        
        [hud setCaption:@"收藏成功！"];
        [hud show];
        [hud hideAfter:2.0];
    }
    [self checkFavStatus];
}
-(void)animButton:(UIButton *)button
{
    CGRect frame = button.frame;
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
    anim.delegate = self;
    anim.springSpeed = 20;
    anim.springBounciness = 10;
    //    anim.velocity = CGRectMake(0, 0, 1, 1);
    anim.completionBlock = ^(POPAnimation *__strong anim, BOOL hi){
        POPSpringAnimation *anim2 = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerBounds];
        anim2.springSpeed = 20;
        anim2.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, frame.size.width, frame.size.width)];
        [button pop_addAnimation:anim2 forKey:@"size2"];
    };
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, frame.size.width*1.5f, frame.size.height*1.5f)];
    [button pop_addAnimation:anim forKey:@"size"];
}
-(IBAction)menuPress:(id)sender
{
//    [self rotate360DegreeWithImageView:sender];
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


@end
