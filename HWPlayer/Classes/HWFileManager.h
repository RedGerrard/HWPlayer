//
//  HWFileManager.h
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/5/7.
//  Copyright © 2019 wozaizhelishua. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HWFileManager : NSObject
#pragma mark - 完成缓存
/**下载完成：根据url获取本地缓存的路径*/
+ (NSString *)cacheFilePath:(NSURL *)url;
/**下载完成：根据url查看文件是否存在*/
+ (BOOL)cacheFileExists:(NSURL *)url;
/**下载完成：根据url获取文件大小*/
+ (long long)cacheFileSize:(NSURL *)url;
/**下载完成：根据url获取本地文件的MIME.TYPE*/
+ (NSString *)contentType:(NSURL *)url;

#pragma mark - 临时缓存
/**下载中：根据url获取本地缓存的路径*/
+ (NSString *)tmpFilePath:(NSURL *)url;
/**下载中：根据url查看文件是否存在*/
+ (BOOL)tmpFileExists:(NSURL *)url;
/**下载中：根据url获取文件大小*/
+ (long long)tmpFileSize:(NSURL *)url;
#pragma mark - 移动缓存
+ (void)moveTmpPathToCachePath:(NSURL *)url;
#pragma mark - 清空临时缓存
+ (void)clearTmpFile:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
