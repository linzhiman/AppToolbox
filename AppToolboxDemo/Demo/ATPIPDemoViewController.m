//
//  ATPIPDemoViewController.m
//  AppToolboxDemo
//
//  Created by linzhiman on 2022/7/4.
//  Copyright © 2022 AppToolbox. All rights reserved.
//

#import "ATPIPDemoViewController.h"
#import <AVKit/AVKit.h>
#import "ATGlobalMacro.h"

//#define Using_AVPlayerViewController

#ifndef Using_AVPlayerViewController

@interface ATAVPlayerView : UIView

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong, readonly) AVPlayerLayer *playerLayer;

@end

@implementation ATAVPlayerView

- (AVPlayer *)player
{
    return self.playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player
{
    self.playerLayer.player = player;
}

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVPlayerLayer *)playerLayer
{
    return (AVPlayerLayer *)self.layer;
}

@end

#endif

#ifdef Using_AVPlayerViewController

@interface ATPIPDemoViewController ()

@property (nonatomic, strong) AVPlayerViewController *avPlayerVC;

#else

@interface ATPIPDemoViewController ()<AVPictureInPictureControllerDelegate>

@property (nonatomic, strong) AVPictureInPictureController *avPIPVC;
@property (nonatomic, strong) ATAVPlayerView *avPlayerView;

#endif

@property (nonatomic, strong) AVPlayer *avPlayer;

@end

@implementation ATPIPDemoViewController

+ (void)load
{
    REGISTER_UI_DEMO(@"PictureInPicture", 500);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"PictureInPicture";
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    if ([AVPictureInPictureController isPictureInPictureSupported]) {
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        if (error) {
            NSLog(@"设置AVAudioSession.category失败：%@",error);
        }
    }
    else {
        NSLog(@"不支持画中画");
    }
    
#ifdef Using_AVPlayerViewController
    
    self.avPlayerVC.view.frame = CGRectMake(0, 100, self.view.bounds.size.width, 300);
    self.avPlayerVC.player = self.avPlayer;
    [self.view addSubview:self.avPlayerVC.view];
    
#else

    [self.view addSubview:self.avPlayerView];

#endif
    
    UIButton *playBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 420, 100, 50)];
    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [playBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [playBtn addTarget:self action:@selector(playVideo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playBtn];
    
#ifndef Using_AVPlayerViewController
    
    // 加按钮触发才可以，通过dispatch_after自动触发不行
    UIButton *pipBtn = [[UIButton alloc] initWithFrame:CGRectMake((self.view.bounds.size.width - 100) / 2, 480, 100, 50)];
    [pipBtn setTitle:@"画中画" forState:UIControlStateNormal];
    [pipBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pipBtn addTarget:self action:@selector(startPIP) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pipBtn];

#endif
}

#ifdef Using_AVPlayerViewController

- (AVPlayerViewController *)avPlayerVC
{
    if (_avPlayerVC) {
        return _avPlayerVC;
    }
    _avPlayerVC = [[AVPlayerViewController alloc] init];
    _avPlayerVC.showsPlaybackControls = YES;
    _avPlayerVC.allowsPictureInPicturePlayback = YES;
    return _avPlayerVC;
}

#else

- (AVPictureInPictureController *)avPIPVC
{
    if (_avPIPVC) {
        return _avPIPVC;
    }
    _avPIPVC = [[AVPictureInPictureController alloc] initWithPlayerLayer:self.avPlayerView.playerLayer];
    _avPIPVC.delegate = self;
    return _avPIPVC;
}

- (ATAVPlayerView *)avPlayerView
{
    if (_avPlayerView) {
        return _avPlayerView;
    }
    _avPlayerView = [[ATAVPlayerView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    _avPlayerView.player = self.avPlayer;
    return _avPlayerView;
}

#endif

- (AVPlayer *)avPlayer
{
    if (_avPlayer) {
        return _avPlayer;
    }
    _avPlayer = [[AVPlayer alloc] initWithURL:[NSURL URLWithString:@"https://hls.videocc.net/05714ecace/b/05714ecace60df265fe0f0f4df60d9fb_1.m3u8?pid=1529352573724X1532482"]];
    return _avPlayer;
}

- (void)playVideo
{
#ifdef Using_AVPlayerViewController
    
    [self.avPlayerVC.player play];
    
#else
    
    [self.avPlayerView.player play];
    
    AT_WEAKIFY_SELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weak_self startPIP];
    });
    
#endif
}

#ifndef Using_AVPlayerViewController

- (void)startPIP
{
    if (self.avPIPVC.pictureInPicturePossible) {
        [self.avPIPVC startPictureInPicture];
    }
    else {
        NSLog(@"不允许开启画中画功能");
    }
}

#pragma mark - AVPictureInPictureControllerDelegate

- (void)pictureInPictureControllerWillStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    NSLog(@"即将开启画中画功能");
}

- (void)pictureInPictureControllerDidStartPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    NSLog(@"已经开启画中画功能");
}

- (void)pictureInPictureControllerWillStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    NSLog(@"即将停止画中画功能");
}

- (void)pictureInPictureControllerDidStopPictureInPicture:(AVPictureInPictureController *)pictureInPictureController
{
    NSLog(@"已经停止画中画功能");
}

- (void)pictureInPictureController:(AVPictureInPictureController *)pictureInPictureController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"开启画中画功能失败，原因是%@", error);
}

#endif

@end
