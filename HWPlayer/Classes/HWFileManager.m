//
//  HWFileManager.m
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/5/7.
//  Copyright © 2019 wozaizhelishua. All rights reserved.
//

//整个文件下载完成后放cache，下载中的房tmp
#define kCachePath NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject
#define kTmpPath NSTemporaryDirectory()

#import "HWFileManager.h"
#import <MobileCoreServices/MobileCoreServices.h>


@implementation HWFileManager

//获取文件路径
+(NSString *)cacheFilePath:(NSURL *)url{
    return [kCachePath stringByAppendingPathComponent:url.lastPathComponent];
}
//检测文件是否存在该路径
+(BOOL)cacheFileExists:(NSURL *)url{
    NSString *path = [self cacheFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
// 获取文件路大小
+(long long)cacheFileSize:(NSURL *)url{
    // 先检查文件是否存在
    if (![self cacheFileExists:url]) {
        return 0;
    }
    // 获取文件路径
    NSString *path = [self cacheFilePath:url];
    // 获取文件路大小
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfoDic[NSFileSize] longLongValue];
}

//根据url获取本地文件的MIME.TYPE
+(NSString *)contentType:(NSURL *)url{
    //文件路径
    NSString *path = [self cacheFilePath:url];
    //文件扩展名
    NSString *fileExtension = path.pathExtension;
    
    CFStringRef contentTypeCF = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef _Nonnull)(fileExtension), NULL);
    NSString *contentType = CFBridgingRelease(contentTypeCF);
    
    return contentType;
}

+ (NSString *)tmpFilePath:(NSURL *)url {
    return [kTmpPath stringByAppendingPathComponent:url.lastPathComponent];
}
+ (BOOL)tmpFileExists:(NSURL *)url {
    NSString *path = [self tmpFilePath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}
+ (long long)tmpFileSize:(NSURL *)url {
    // 1.2 计算文件路径对应的文件大小
    if (![self tmpFileExists:url]) {
        return 0;
    }
    // 1.1 获取文件路径
    NSString *path = [self tmpFilePath:url];
    NSDictionary *fileInfoDic = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    return  [fileInfoDic[NSFileSize] longLongValue];
}

+ (void)moveTmpPathToCachePath:(NSURL *)url {
    
    NSString *tmpPath = [self tmpFilePath:url];
    NSString *cachePath = [self cacheFilePath:url];
    [[NSFileManager defaultManager] moveItemAtPath:tmpPath toPath:cachePath error:nil];
 
}
+ (void)clearTmpFile:(NSURL *)url {
    NSString *tmpPath = [self tmpFilePath:url];
    //isDirectory表示是否是文件夹
    BOOL isDirectory = YES;
    BOOL isEx = [[NSFileManager defaultManager] fileExistsAtPath:tmpPath isDirectory:&isDirectory];
    if (isEx && !isDirectory) {
        [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:nil];
    }
}
@end
