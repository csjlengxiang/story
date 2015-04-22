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
    
    IBOutlet RoundIconButton *modeButton;
    IBOutlet UIButton *favButton;
    IBOutlet RoundLabel *viewCountLabel;
    IBOutlet RoundLabel *dayInfoLabel;
    
    YDSlider *progressSlider;
    
    DOUAudioStreamer *streamer;
    NSTimer *_timer;
    ATMHud * hud;
}
@end

@implementation StoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isPlaying = NO;
    totalDuration = 0;
    [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    self.view.backgroundColor = [SYUtil colorWithHex:@"ffffff"];
    descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    descLabel.numberOfLines = 4;
    descLabel.preferredMaxLayoutWidth = self.view.frame.size.width;
    // Override point for customization after application launch.
    
    [swipeGR addTarget:self action:@selector(nextStory)];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    navBar.backgroundColor = [SYUtil colorWithHex:@"e15151"];
    [coverView.layer setCornerRadius:10];
    [coverView.layer setMasksToBounds:YES];
    hud = [[ATMHud alloc] initWithDelegate:self];
    [self.view addSubview:hud.view];
    
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
    descLabel.text =self.story.desc;
    titleLabel.text = self.story.title;
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init] ;
//    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
[dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    dayInfoLabel.text  = [NSString stringWithFormat:@"  %@·第%d期  ",[dateFormatter stringFromDate:self.story.time],self.story.num];
    
    viewCountLabel.text =[NSString stringWithFormat:@"  浏览次数:%d  ",self.story.visit_count] ;
    NSString *encodeURI = [self.story.cover stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [coverView sd_setImageWithURL:[NSURL URLWithString:encodeURI]];
    
//    numTitleLabel.text = [NSString stringWithFormat:@"第%d期",self.story.num];
    coverView.bounds =CGRectMake(0, 0, 100, 100);
    //故事封面的弹性效果
    [self performSelector:@selector(animPic)
               withObject:nil
               afterDelay:0.5];
    [self setPlayProgress:0];
    [self setDowloadProgress:0];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play-256.png"] forState:UIControlStateNormal];

    nowTimeLabel.text = @"00:00";
    totalTimeLabel.text = @"00:00";
    [modeButton drawIcon:[UIImage imageNamed:@"repeat-256.png"] text:@"全部循环"];
    [self checkFavStatus];
    [self configPlayingInfo];
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
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width-60, [UIScreen mainScreen].bounds.size.width-60)];
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
        NSLog(@"[streamer receivedLength]:%f",(float)[streamer receivedLength]/(float)[streamer expectedLength]);
        [self setDowloadProgress:(float)[streamer receivedLength]/(float)[streamer expectedLength]];
        

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
    downloadPercent.constant = bgwidth - bgwidth*v;
}
-(void)setPlayProgress:(float)v
{

    float bgwidth = progressBg.frame.size.width;
    progressPercent.constant = bgwidth - bgwidth*v;
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
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:@"53536f8056240bac64008793"
                                      shareText:@"推荐个很棒的【颜文字】APP，简直把我萌化了，从此成为卖萌小能手 http://itunes.apple.com/cn/app/yan-wen-zi/id866753915?ls=1&mt=8"
                                     shareImage:[UIImage imageNamed:@"shot.png"]
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
@end
