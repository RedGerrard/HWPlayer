//
//  HWFirstController.m
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/4/30.
//  Copyright © 2019年 wozaizhelishua. All rights reserved.
//

#import "HWFirstController.h"
#import "HWViewController.h"
@interface HWFirstController ()

@end

@implementation HWFirstController


- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    HWViewController *vc = segue.destinationViewController;
    NSURL *url;
    if ([segue.identifier isEqualToString:@"p1"]) {
        
//        url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
        url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M06/5C/70/wKgJL1g0DVahoMhrAMJMkvfN17c025.m4a"];
//        url = [NSURL URLWithString:@"/Users/yuanhaiwen/Desktop/今日视频/IOS/0115-FMDay4/235319.mp3"];
//        http://localhost:8080/MJServer/resources/videos/minion_01.mp4
//        "http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"
//            "http://audio.xmcdn.com/group22/M0B/60/85/wKgJM1g1g0ShoPalAJiI5nj3-yY200.m4a",
//            "http://audio.xmcdn.com/group23/M06/5C/70/wKgJL1g0DVahoMhrAMJMkvfN17c025.m4a",
    } else if ([segue.identifier isEqualToString:@"p2"]){
        url = [NSURL URLWithString:@"http://audio.xmcdn.com/group23/M04/63/C5/wKgJNFg2qdLCziiYAGQxcTOSBEw402.m4a"];
    }
    vc.url = url;
    [super prepareForSegue:segue sender:sender];
}

@end
