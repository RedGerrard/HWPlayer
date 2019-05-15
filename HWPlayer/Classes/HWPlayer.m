//
//  HWPlayer.m
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/4/29.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import "HWPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "HWResourceLoaderDelegate.h"


@interface HWPlayer()<NSCopying, NSMutableCopying>
@property (nonatomic, strong) AVPlayer *player;
/**
 定时器，用来更新状态
 */
@property (nonatomic, strong) dispatch_source_t timer;

@property (nonatomic, strong) HWResourceLoaderDelegate *resourceLoaderDelegate;
@end

@implementation HWPlayer{
    float _progress;
    float _volume;
    BOOL _muted;
    BOOL _isPause;
}
#pragma mark - 懒加载
-(dispatch_source_t)timer{
    if (_timer == nil) {
        // 获得队列
        dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
        // 创建一个定时器（dispatch_source_t timer 本质是个oc对象）
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
        // 设置定时器的各种属性 （几时开始任务，每隔多久执行一次）
        // GCD 的时间参数 ，一般是纳秒 （1秒 = 10的9次方纳秒）
        // dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)); 比当前时间晚 3 秒
        //    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)); // 现在 + 1 秒后
        dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 0); // 现在 0 秒后，也就是立即开始i
        dispatch_time_t interval = 1 * NSEC_PER_SEC;
        
        dispatch_source_set_timer(_timer, start, interval, (int64_t)(0 * NSEC_PER_SEC));
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self next];
            });
        });
        
    }
    return _timer;
}

#pragma mark - 单例
static HWPlayer *_shareInstance;
+ (instancetype)shareInstance {
    if (_shareInstance == nil) {
        _shareInstance = [[self alloc] init];
    }
    return _shareInstance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    if (!_shareInstance) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _shareInstance = [super allocWithZone:zone];
        });
    }
    return _shareInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _shareInstance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _shareInstance;
}

#pragma mark - set方法
- (void)setState:(HWPlayerState)state {
    _state = state;
    
    // 如果需要告知外界相关的事件
    // block
    // 代理
    // 发通知
    
}
/**
 静音
 
 @param muted 静音
 */
- (void)setMuted:(BOOL)muted {
    self.player.muted = muted;
}

/**
 设置音量
 
 @param volume 音量
 */
-(void)setVolume:(float)volume{
    
    if (volume < 0 || volume > 1) {
        return;
    }
    
    _volume = volume;
    
    if (volume > 0) {
        [self setMuted:NO];
    }
    
    self.player.volume = volume;
}

/**
 跳转到某一进度
 
 @param progress 进度
 */
-(void)setProgress:(float)progress{
    
    if (progress < 0 || progress > 1) {
        return;
    }
    
    _progress = progress;
    
    // 可以指定时间节点去播放
    // 时间: CMTime : 影片时间
    // 影片时间 -> 秒
    // 秒 -> 影片时间
    
    // 1. 当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    // 2. 当前音频, 已经播放的时长
    //    self.player.currentItem.currentTime
    
    NSTimeInterval totalSec = CMTimeGetSeconds(totalTime);
    NSTimeInterval playTimeSec = totalSec * progress;
    CMTime currentTime = CMTimeMake(playTimeSec, 1);
    
    [self.player seekToTime:currentTime completionHandler:^(BOOL finished) {
        if (finished) {
            NSLog(@"确定加载这个时间点的音频资源");
        }else {
            NSLog(@"取消加载这个时间点的音频资源");
        }
    }];
}

/**设置地址*/
-(void)setUrl:(NSURL *)url isCache:(BOOL)isCache{
    
    NSURL *currentURL = [(AVURLAsset *)self.player.currentItem.asset URL];
    if ([url isEqual:currentURL]) {
        NSLog(@"当前播放任务已经存在");
        [self play];
        return;
    }
    
    _url = url;
    if (isCache) {
    //如果需要缓存，得先要把http协议的URL转为sreaming协议的流媒体资源，才能分为一段一段的流来获取
        NSURLComponents *compents = [NSURLComponents componentsWithString:url.absoluteString];
        compents.scheme = @"sreaming";
        url = compents.URL;
    }
    
    if (self.player.currentItem) {
        // 暂停定时器
        [self stopTimer];
        [self removeObserver];
    }
    
    // 创建一个播放器对象
    // 如果我们使用这样的方法, 去播放远程音频
    // 这个方法, 已经帮我们封装了三个步骤
    // 1. 资源的请求
    // 2. 资源的组织
    // 3. 给播放器, 资源的播放
    // 如果资源加载比较慢, 有可能, 会造成调用了play方法, 但是当前并没有播放音频
    // 1. 资源的请求
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    // 关于网络音频的请求, 是通过这个对象, 调用代理的相关方法, 进行加载的
    // 拦截加载的请求, 只需要, 重新修改它的代理方法就可以
    self.resourceLoaderDelegate = [HWResourceLoaderDelegate new];
    [asset.resourceLoader setDelegate:self.resourceLoaderDelegate queue:dispatch_get_main_queue()];
    // 2. 资源的组织
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:asset];
    // 当资源的组织者, 告诉我们资源准备好了之后, 我们再播放
    // AVPlayerItemStatus status
    [item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playEnd) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playInterupt) name:AVPlayerItemPlaybackStalledNotification object:nil];
    // 3. 资源的播放
    self.player = [AVPlayer playerWithPlayerItem:item];
    
    
    // 启动定时器
    [self startTimer];
}


-(void)startTimer{
    
    dispatch_resume(self.timer);
}
-(void)stopTimer{
    
    dispatch_suspend(self.timer);
}
-(void)next{
    
    if (self.statusBlock) {
        self.statusBlock(self.currentTimeFormat, self.totalTimeFormat, self.progress, self.loadDataProgress, self.volume, self.muted);
    }
    
}
- (void)playEnd {
    NSLog(@"播放完成");
    self.state = HWPlayerStateStopped;
}

- (void)playInterupt {
    // 来电话, 资源加载跟不上
    NSLog(@"播放被打断");
    self.state = HWPlayerStatePause;
}
#pragma mark - get方法

- (BOOL)muted {
    return self.player.muted;
}

- (float)volume {
    return self.player.volume;
    
}

- (NSString *)currentTimeFormat {
    return [NSString stringWithFormat:@"%02d:%02d", (int)self.currentTime / 60, (int)self.currentTime % 60];
}

- (NSString *)totalTimeFormat {
    return [NSString stringWithFormat:@"%02d:%02d", (int)self.totalTime / 60, (int)self.totalTime % 60];
}


-(NSTimeInterval)totalTime {
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    if (isnan(totalTimeSec)) {
        return 0;
    }
    return totalTimeSec;
}

- (NSTimeInterval)currentTime {
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    if (isnan(playTimeSec)) {
        return 0;
    }
    return playTimeSec;
}

 
-(float)progress{
    if (self.totalTime == 0) {
        return 0;
    }
    return self.currentTime / self.totalTime;
}

- (float)loadDataProgress {
    
    if (self.totalTime == 0) {
        return 0;
    }
    
    CMTimeRange timeRange = [[self.player.currentItem loadedTimeRanges].lastObject CMTimeRangeValue];
    
    CMTime loadTime = CMTimeAdd(timeRange.start, timeRange.duration);
    NSTimeInterval loadTimeSec = CMTimeGetSeconds(loadTime);
    
    return loadTimeSec / self.totalTime;
    
}
#pragma mark - 接口
/**
 继续
 */
- (void)play {
    [self.player play];
}

/**
 暂停
 */
- (void)pause {
    [self.player pause];
    _isPause = YES;
    if (self.player) {
        self.state = HWPlayerStatePause;
    }
}

/**
 停止
 */
- (void)stop {
    [self.player pause];
    self.player = nil;
    [self removeObserver];
}



/**
 跳转或倒退固定时间

 @param timeDiffer 时间参数
 */
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer {
    
    // 1. 当前音频资源的总时长
    CMTime totalTime = self.player.currentItem.duration;
    NSTimeInterval totalTimeSec = CMTimeGetSeconds(totalTime);
    // 2. 当前音频, 已经播放的时长
    CMTime playTime = self.player.currentItem.currentTime;
    NSTimeInterval playTimeSec = CMTimeGetSeconds(playTime);
    playTimeSec += timeDiffer;
    
    self.progress = playTimeSec / totalTimeSec;
    
}


/**
 设置倍率

 @param rate 倍率
 */
- (void)setRate:(float)rate {
    
    [self.player setRate:rate];
    
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        if (status == AVPlayerItemStatusReadyToPlay) {
            NSLog(@"资源准备好了, 这时候播放就没有问题");
            [self play];
        }else {
            NSLog(@"状态未知");
            self.state = HWPlayerStateFailed;
        }
    }
    if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        BOOL ptk = [change[NSKeyValueChangeNewKey] boolValue];
        if (ptk) {
            NSLog(@"当前的资源, 准备的已经足够播放了");
            //
            // 用户的手动暂停的优先级最高
            if (!_isPause) {
                [self play];
            }else {
            }
        }else {
            NSLog(@"资源还不够, 正在加载过程当中");
            self.state = HWPlayerStateLoading;
        }
    }
}

- (void)removeObserver {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [self.player.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
}


@end
