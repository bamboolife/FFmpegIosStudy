//
//  VideoViewController.m
//  FFmpegIosStudy
//
//  Created by 蒋建伟 on 2020/1/6.
//  Copyright © 2020 蒋建伟. All rights reserved.
//

#import "VideoViewController.h"
#import  <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <time.h>
@interface VideoViewController ()
@property (strong,nonatomic) AVPlayerViewController *moviePlayer;
@property (strong,nonatomic) AVPlayer *player;
@property (strong,nonatomic) AVPlayerItem *item;
@end

@implementation VideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor blackColor];
   
    //设置本地视频路径
    NSString *mpath=[[NSBundle mainBundle] pathForResource:@"res.bundle/sintel" ofType:@"mov"];
    NSURL *url=[NSURL fileURLWithPath:mpath];
    AVAsset *asset = [AVAsset assetWithURL:url];
    self.item=[AVPlayerItem playerItemWithAsset:asset];
   //-----------------------------------------------
    //NSString *videoUrl=@"http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4";
    //NSURL *movieURL=[NSURL URLWithString:videoUrl];
    //设置流媒体视频路径
    //self.item=[AVPlayerItem playerItemWithURL:movieURL];
    //-------------------------------------------------
    //设置AVPlayer中的AVPlayerItem
    self.player=[AVPlayer playerWithPlayerItem:self.item];

    //初始化AVPlayerViewController
    self.moviePlayer=[[AVPlayerViewController alloc]init];

    self.moviePlayer.player=self.player;
    
    [self.view addSubview:self.moviePlayer.view];

    //设置AVPlayerViewController的frame
    self.moviePlayer.view.frame=self.view.frame;

    //替换AVPlayer中的AVPlayerItem
    //[self.player replaceCurrentItemWithPlayerItem:self.item];

    //监听status属性，注意监听的是AVPlayerItem
    [self.item addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];

    //监听loadedTimeRanges属性
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];

    //设置监听函数，监听视频播放进度的变化，每播放一秒，回调此函数
        __weak __typeof(self) weakSelf = self;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        //当前播放的时间
        NSTimeInterval current = CMTimeGetSeconds(time);
        //视频的总时间
        NSTimeInterval total = CMTimeGetSeconds(weakSelf.player.currentItem.duration);

        //输出当前播放的时间
        NSLog(@"now %f",current);
        }];

    }

    //AVPlayerItem监听的回调函数
    - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
    {
        AVPlayerItem *playerItem = (AVPlayerItem *)object;

        if ([keyPath isEqualToString:@"loadedTimeRanges"]){
            double t=[self availableDurationWithplayerItem:self.item];
            NSLog(@"loadranges %f",t);

        }else if ([keyPath isEqualToString:@"status"]){
            if (playerItem.status == AVPlayerItemStatusReadyToPlay){
                NSLog(@"playerItem is ready");

                //如果视频准备好 就开始播放
                [self.player play];

                } else if(playerItem.status==AVPlayerStatusUnknown){
                NSLog(@"playerItem Unknown错误");
                }
            else if (playerItem.status==AVPlayerStatusFailed){
                NSLog(@"playerItem 失败");
            }
        }
    }

    //计算缓冲进度的函数
    - (NSTimeInterval)availableDurationWithplayerItem:(AVPlayerItem *)playerItem
    {
        NSArray *loadedTimeRanges = [playerItem loadedTimeRanges];
        CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
        NSTimeInterval startSeconds = CMTimeGetSeconds(timeRange.start);
        NSTimeInterval durationSeconds = CMTimeGetSeconds(timeRange.duration);
        NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
        return result;
    }
- (void)dealloc
{
    self.moviePlayer=nil;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
