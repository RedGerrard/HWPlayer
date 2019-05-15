<h1 align="center"> HWPlayer</h1>基于AVPlayer的音视频播放器，支持缓存

## How To Use
```
#import <HWPlayer.h>

- (void)viewDidLoad
{
[super viewDidLoad];

[[HWPlayer shareInstance]setUrl:self.url isCache:YES];

__weak typeof(self)weakSelf = self;
[HWPlayer shareInstance].statusBlock = ^(NSString *currentTimeFormat, NSString *totalTimeFormat, float progress, float loadDataProgress, float volume, BOOL muted) {
weakSelf.playTimeLabel.text =  currentTimeFormat;
weakSelf.totalTimeLabel.text = totalTimeFormat;

weakSelf.playSlider.value = progress;
weakSelf.loadPV.progress = loadDataProgress;

weakSelf.volumeSlider.value = volume;

weakSelf.mutedBtn.selected = muted;
};

}

- (IBAction)pause:(id)sender {
[[HWPlayer shareInstance] pause];
}

- (IBAction)resume:(id)sender {
[[HWPlayer shareInstance] play];
}
- (IBAction)kuaijin:(id)sender {
[[HWPlayer shareInstance] seekWithTimeDiffer:15];
}
- (IBAction)progress:(UISlider *)sender {
[HWPlayer shareInstance].progress = sender.value;
}
- (IBAction)rate:(id)sender {
[[HWPlayer shareInstance] setRate:2];
}
- (IBAction)muted:(UIButton *)sender {
sender.selected = !sender.selected;
[HWPlayer shareInstance].muted = sender.selected;
}
- (IBAction)volume:(UISlider *)sender {

[HWPlayer shareInstance].volume = sender.value;
}
```

## Installation

HWCyclePics is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HWParty'
```

## Author
本人小菜鸟一枚，欢迎各位同仁和大神指教
<br>我的简书是：https://www.jianshu.com/u/cdd48b9d36e0
<br>我的邮箱是：417705652@qq.com

## Licenses

All source code is licensed under the [MIT License](https://raw.github.com/SDWebImage/SDWebImage/master/LICENSE).
