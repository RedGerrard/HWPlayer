//
//  HWPlayerDownLoader.h
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/5/8.
//  Copyright © 2019 wozaizhelishua. All rights reserved.
//

#import <Foundation/Foundation.h>
 
NS_ASSUME_NONNULL_BEGIN

@protocol HWPlayerDownLoaderDelegate <NSObject>

- (void)downLoading;

@end

@interface HWPlayerDownLoader : NSObject
/**临时缓存大小，可以用于判断是否正在下载中*/
@property (nonatomic, assign) long long loadedSize;
/**下载起始点，可以用于判断是否需要重新下载*/
@property (nonatomic, assign) long long offset;

@property (nonatomic, weak) id<HWPlayerDownLoaderDelegate> delegate;

@property (nonatomic, assign) long long totalSize;

@property (nonatomic, strong) NSString *mimeType;


- (void)downLoadWithURL:(NSURL *)url offset:(long long)offset;

@end

NS_ASSUME_NONNULL_END
