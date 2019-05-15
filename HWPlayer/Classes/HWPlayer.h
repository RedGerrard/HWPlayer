//
//  HWPlayer.h
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/4/29.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * 播放器的状态
 * 因为UI界面需要加载状态显示, 所以需要提供加载状态
 - HWPlayerStateUnknown: 未知(比如都没有开始播放音乐)
 - HWPlayerStateLoading: 正在加载()
 - HWPlayerStatePlaying: 正在播放
 - HWPlayerStateStopped: 停止
 - HWPlayerStatePause:   暂停
 - HWPlayerStateFailed:  失败(比如没有网络缓存失败, 地址找不到)
 */
typedef NS_ENUM(NSInteger, HWPlayerState) {
    HWPlayerStateUnknown = 0,
    HWPlayerStateLoading   = 1,
    HWPlayerStatePlaying   = 2,
    HWPlayerStateStopped   = 3,
    HWPlayerStatePause     = 4,
    HWPlayerStateFailed    = 5
};

/**
 状态回调

 @param currentTimeFormat 已播放时长
 @param totalTimeFormat 总时长
 @param progress 播放进度
 @param loadDataProgress 加载进度
 @param volume 音量
 @param muted 静音
 */
typedef void(^UpdateStatusBlock)(NSString *currentTimeFormat, NSString *totalTimeFormat, float progress, float loadDataProgress, float volume, BOOL muted);

@interface HWPlayer : NSObject
/**播放状态*/
@property (nonatomic, assign, readonly) HWPlayerState state;
/**音频地址*/
@property (nonatomic, strong, readonly) NSURL *url;
/**播放进度*/
@property (nonatomic, assign) float progress;
/**加载进度*/
@property (nonatomic, assign, readonly) float loadDataProgress;
/**音量*/
@property (nonatomic, assign) float volume;
/**静音*/
@property (nonatomic, assign) BOOL muted;
/**音频总时间*/
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
/**音频总时间字符串*/
@property (nonatomic, copy, readonly) NSString *totalTimeFormat;
/**当前时间*/
@property (nonatomic, assign, readonly) NSTimeInterval currentTime;
/**当前时间字符串*/
@property (nonatomic, copy, readonly) NSString *currentTimeFormat;
/**更新状态回调*/
@property(nonatomic, copy)UpdateStatusBlock statusBlock;

/**单例*/
+ (instancetype)shareInstance;

/**
 设置资源网址

 @param url 网址
 @param isCache 是否需要缓存音频
 */
-(void)setUrl:(NSURL *)url isCache:(BOOL)isCache;

/**播放*/
- (void)play;

/**暂停*/
- (void)pause;

/**停止*/
- (void)stop;

/**跳转或倒退固定时间*/
- (void)seekWithTimeDiffer:(NSTimeInterval)timeDiffer;

/**设置倍率*/
- (void)setRate:(float)rate;

@end
