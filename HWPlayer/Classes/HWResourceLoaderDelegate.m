//
//  HWResourceLoaderDelegate.m
//  HWPlayer_Example
//
//  Created by 袁海文 on 2019/5/7.
//  Copyright © 2019 wozaizhelishua. All rights reserved.
//

#import "HWResourceLoaderDelegate.h"
#import "HWFileManager.h"
#import "HWPlayerDownLoader.h"

@interface HWResourceLoaderDelegate()<HWPlayerDownLoaderDelegate>
@property (nonatomic, strong) HWPlayerDownLoader *downLoader;
@property (nonatomic, strong) NSMutableArray *loadingRequests;
@end

@implementation HWResourceLoaderDelegate

- (HWPlayerDownLoader *)downLoader {
    if (!_downLoader) {
        _downLoader = [[HWPlayerDownLoader alloc] init];
        _downLoader.delegate = self;
    }
    return _downLoader;
}

- (NSMutableArray *)loadingRequests {
    if (!_loadingRequests) {
        _loadingRequests = [NSMutableArray array];
    }
    return _loadingRequests;
}

// 当外界, 需要播放一段音频资源是, 会跑一个请求, 给这个对象
// 这个对象, 到时候, 只需要根据请求信息, 抛数据给外界
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
//    NSLog(@"%@", loadingRequest);
//    NSLog(@"收到一个请求信息");
    //判断本地有没有该音频资源的缓存文件
    NSURL *url = loadingRequest.request.URL;
    if ([HWFileManager cacheFileExists:url]) {
        NSLog(@"本地已经存在资源文件");
        //如果有则直接把该文件返回
        [self handleLocalRequest:loadingRequest];
        return YES;
    }
    
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    long long currentOffset = loadingRequest.dataRequest.currentOffset;
    if (requestOffset != currentOffset) {
        requestOffset = currentOffset;
    }
    
    // 记录所有的请求
    [self.loadingRequests addObject:loadingRequest];
//    NSLog(@"requestOffset:%lld,requestedLength:%ld",requestOffset,(long)loadingRequest.dataRequest.requestedLength);
//    NSLog(@"请求个数：%ld",self.loadingRequests.count);
    
    //判断有没有正在下载
    if (self.downLoader.loadedSize == 0) {
        NSLog(@"没有文件且没开始下载，现在开始下载");
        //如果没有有则开始下载
        //开始下载数据（根据请求的信息，url，requestOffset，requestLength）
        
        //注意，下载前需要把此时被转为流媒体协议的资源转为http协议，否则下载不了
        NSURLComponents *compents = [NSURLComponents componentsWithString:url.absoluteString];
        compents.scheme = @"http";
        url = compents.URL;
        
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        NSLog(@"%d,%d",requestOffset,loadingRequest.dataRequest.requestedLength);
        return YES;
    }
    
    //判断当前有下载的时候需不需要重新下载
    //当资源请求, 开始点 < 下载的开始点
    //当资源的请求, 开始点 > 下载的开始点 + 下载的长度 + 666，这里666是自己设定的
    if (requestOffset < self.downLoader.offset || requestOffset >
        (self.downLoader.offset + self.downLoader.loadedSize + 666)) {
        
        NSLog(@"有下载但是需要重新下载，现在开始重新下载");
        [self.downLoader downLoadWithURL:url offset:requestOffset];
        return YES;
    }
    
    // 开始处理资源请求 (在下载过程当中, 也要不断的判断)
//    NSLog(@"第四种情况：开始处理资源请求");
    [self handleAllLoadingRequest];
    
    return YES;
}

// 取消请求
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    NSLog(@"取消某个请求");
    [self.loadingRequests removeObject:loadingRequest];
}
#pragma mark - HWPlayerDownLoaderDelegate
- (void)downLoading {
    //    NSLog(@"%d,%s",__LINE__,__func__);
    [self handleAllLoadingRequest];
}
- (void)handleAllLoadingRequest {
//    NSLog(@"%d,%s",__LINE__,__func__);
    //    NSLog(@"在这里不断的处理请求");
//    NSLog(@"-----%@", self.loadingRequests);
//    NSLog(@"%d",self.loadingRequests.count);
    NSMutableArray *deleteRequests = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest *loadingRequest in self.loadingRequests) {
        // 1. 填充内容信息头
        NSURL *url = loadingRequest.request.URL;
        long long totalSize = self.downLoader.totalSize;
        loadingRequest.contentInformationRequest.contentLength = totalSize;
        NSString *contentType = self.downLoader.mimeType;
        loadingRequest.contentInformationRequest.contentType = contentType;
        loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
        
        // 2. 填充数据
        NSData *data = [NSData dataWithContentsOfFile:[HWFileManager tmpFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        
        if (data == nil) {
            data = [NSData dataWithContentsOfFile:[HWFileManager cacheFilePath:url] options:NSDataReadingMappedIfSafe error:nil];
        }
        
        long long requestOffset = loadingRequest.dataRequest.requestedOffset;
        long long currentOffset = loadingRequest.dataRequest.currentOffset;
        if (requestOffset != currentOffset) {
            requestOffset = currentOffset;
        }
        NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
        
        long long responseOffset = requestOffset - self.downLoader.offset;
        long long responseLength = MIN(self.downLoader.offset + self.downLoader.loadedSize - requestOffset, requestLength) ;
        
        NSData *subData = [data subdataWithRange:NSMakeRange(responseOffset, responseLength)];
        
        [loadingRequest.dataRequest respondWithData:subData];
//        NSLog(@"%lld,%lld,%lld,%lld,%lld",totalSize,requestOffset,requestLength,responseOffset,responseLength);
        // 3. 完成请求(必须把所有的关于这个请求的区间数据, 都返回完之后, 才能完成这个请求)
        if (requestLength == responseLength) {
            [loadingRequest finishLoading];
            [deleteRequests addObject:loadingRequest];
        }
        
    }
    
    [self.loadingRequests removeObjectsInArray:deleteRequests];
    
}

#pragma mark - 私有方法
// 处理本地数据
- (void)handleLocalRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    
    //获取大小
    NSURL *url = loadingRequest.request.URL;
    long long contentLength = [HWFileManager cacheFileSize:url];
    
    //获取MIME.TYPE
    NSString *contentType = [HWFileManager contentType:url];
    
    //获取数据路径
    NSString *path = [HWFileManager cacheFilePath:url];
    
    [self handleLoadingRequest:loadingRequest contentLength:contentLength contentType:contentType path:path];
}
//提供数据给外界使用，这里是提供播放器播放，每一个loadingRequest代表播放器需要播放的一个片段
- (void)handleLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest contentLength:(long long)contentLength contentType:(NSString *)contentType path:(NSString *)path{
    // 1. 填充请求头信息
    //设置文件大小
    loadingRequest.contentInformationRequest.contentLength = contentLength;
    //设置MIME.TYPE
    loadingRequest.contentInformationRequest.contentType = contentType;
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 2. 相应数据给外界
    //获取总数据
    NSData *data = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    //获取请求起始位置
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    //获取请求长度
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    //获取请求数据
    NSData *subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    
//    NSLog(@"%d,%d,%d",contentLength,requestOffset,requestLength);
    // 3. 完成本次请求(一旦,所有的数据都给完了, 才能调用完成请求方法)
    [loadingRequest finishLoading];
}


@end
