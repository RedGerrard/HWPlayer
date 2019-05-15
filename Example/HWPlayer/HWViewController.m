//
//  HWViewController.m
//  HWPlayer
//
//  Created by wozaizhelishua on 04/29/2019.
//  Copyright (c) 2019 wozaizhelishua. All rights reserved.
//

#import "HWViewController.h"
#import "HWPlayer.h"

@interface HWViewController ()
@property (weak, nonatomic) IBOutlet UILabel *playTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalTimeLabel;

@property (weak, nonatomic) IBOutlet UISlider *playSlider;

@property (weak, nonatomic) IBOutlet UIProgressView *loadPV;

@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;

@property (weak, nonatomic) IBOutlet UIButton *mutedBtn;
@end

@implementation HWViewController
 
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
//-(void)dealloc{
//    NSLog(@"%d,%s",__LINE__,__func__);
//}
@end
