//
//  LyMusicResourceLoader.m
//  jy_client
//
//  Created by Lying on 2017/10/25.
//  Copyright © 2017年 JY. All rights reserved.
//

#define MimeType @"video/mp4"
#import "LyMusicResourceLoader.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface LyMusicResourceLoader ()

@property (nonatomic, strong) NSMutableArray        *requestList;
@property (nonatomic, strong) LyMusicRequestTask    *requestTask;
@end

@implementation LyMusicResourceLoader

- (instancetype)init {
    if (self = [super init]) {
        self.requestList = [NSMutableArray array];
    }
    return self;
}

- (void)stopLoading {
    self.requestTask.cancel = YES;
}

#pragma mark - AVAssetResourceLoaderDelegate
/**
 播放器关闭了下载请求
 播放器关闭一个旧请求，都会发起一到多个新请求，除非已经播放完毕了
 
 - parameter resourceLoader: 资源管理器
 - parameter loadingRequest: 待关请求
 */
- (void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
//    NSLog(@"CancelLoadingRequest  < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self.requestList removeObject:loadingRequest];
}

/**
 播放器问：是否应该等这requestResource加载完再说？
 这里会出现很多个loadingRequest请求， 需要为每一次请求作出处理
 
 - parameter resourceLoader: 资源管理器
 - parameter loadingRequest: 每一小块数据的请求
 
 - returns:
 */
- (BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest {
//    NSLog(@"WaitingLoadingRequest < requestedOffset = %lld, currentOffset = %lld, requestedLength = %ld >", loadingRequest.dataRequest.requestedOffset, loadingRequest.dataRequest.currentOffset, loadingRequest.dataRequest.requestedLength);
    [self addLoadingRequest:loadingRequest];
    return YES;
}

#pragma mark - requestTaskDelegate
- (void)requestTaskDidUpdateCache {
    [self processRequestList];
    if (self.delegate && [self.delegate respondsToSelector:@selector(loader:cacheProgress:)]) {
        CGFloat cacheProgress = (CGFloat)self.requestTask.cacheLength / (self.requestTask.fileLength - self.requestTask.requestOffset);
        [self.delegate loader:self cacheProgress:cacheProgress];
    }
}
//完成
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache {
    self.cacheFinished = cache;
}

- (void)requestTaskDidFailWithError:(NSError *)error {
    //加载数据错误的处理
    if([self.delegate respondsToSelector:@selector(loader:failLoadingWithError:)]){
        [self.delegate loader:self failLoadingWithError:error];
    }
}

#pragma mark - 处理LoadingRequest
- (void)addLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    [self.requestList addObject:loadingRequest];
    @synchronized(self) {
        if (self.requestTask) {
            if (loadingRequest.dataRequest.requestedOffset >= self.requestTask.requestOffset &&
                loadingRequest.dataRequest.requestedOffset <= self.requestTask.requestOffset + self.requestTask.cacheLength) {
                //数据已经缓存，则直接完成
                NSLog(@"数据已经缓存，则直接完成");
                [self processRequestList];
            }else {
                //数据还没缓存，则等待数据下载；如果是Seek操作，则重新请求
                if (self.seekRequired) {
                    NSLog(@"Seek操作，则重新请求");
                    [self newTaskWithLoadingRequest:loadingRequest cache:NO];
                }
            }
        }else {
            [self newTaskWithLoadingRequest:loadingRequest cache:YES];
        }
    }
}

- (void)newTaskWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest cache:(BOOL)cache {
    NSUInteger fileLength = 0;
    if (self.requestTask) {
        fileLength = self.requestTask.fileLength;
        self.requestTask.cancel = YES;
    }
    self.requestTask = [[LyMusicRequestTask alloc]init];
    self.requestTask.requestURL = loadingRequest.request.URL;
    self.requestTask.requestOffset = loadingRequest.dataRequest.requestedOffset;
    self.requestTask.cache = cache;
    if (fileLength > 0) {
        self.requestTask.fileLength = fileLength;
    }
    self.requestTask.delegate = self;
    [self.requestTask start];
    self.seekRequired = NO;
}

- (void)removeLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    if (loadingRequest) {
        [self.requestList removeObject:loadingRequest];
    }
}

- (void)processRequestList {
    NSMutableArray * finishRequestList = [NSMutableArray array];
    for (AVAssetResourceLoadingRequest * loadingRequest in self.requestList) {
        if ([self finishLoadingWithLoadingRequest:loadingRequest]) {
            [finishRequestList addObject:loadingRequest];
        }
    }
    if (finishRequestList.count) {
         [self.requestList removeObjectsInArray:finishRequestList];
    }
}

- (BOOL)finishLoadingWithLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest {
    //填充信息
    CFStringRef contentType = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, (__bridge CFStringRef)(MimeType), NULL);
    loadingRequest.contentInformationRequest.contentType = CFBridgingRelease(contentType);
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    loadingRequest.contentInformationRequest.contentLength = self.requestTask.fileLength;
    
    //读文件，填充数据
    NSUInteger cacheLength = self.requestTask.cacheLength;
    NSUInteger requestedOffset = loadingRequest.dataRequest.requestedOffset;
    if (loadingRequest.dataRequest.currentOffset != 0) {
        requestedOffset = loadingRequest.dataRequest.currentOffset;
    }
    NSUInteger canReadLength = cacheLength - (requestedOffset - self.requestTask.requestOffset);
    NSUInteger respondLength = MIN(canReadLength, loadingRequest.dataRequest.requestedLength);
    
    @try {
        [loadingRequest.dataRequest respondWithData:[LyFileHandle readTempFileDataWithOffset:requestedOffset - self.requestTask.requestOffset length:respondLength]];
        //如果完全响应了所需要的数据，则完成
        NSUInteger nowendOffset = requestedOffset + canReadLength;
        NSUInteger reqEndOffset = loadingRequest.dataRequest.requestedOffset + loadingRequest.dataRequest.requestedLength;
        if (nowendOffset >= reqEndOffset) {
            [loadingRequest finishLoading];
            return YES;
        }
    }
    @catch (NSException *exception) {
        // 捕获到的异常exception
        NSLog(@"/////////////////////------------------------异常exception\nexception %@",exception);
    }
    @finally {
        // 结果处理
    }
    return NO;
}

-(NSMutableArray *)requestList{
    if(_requestList == nil){
        _requestList = [NSMutableArray array];
    }
    return _requestList;
}


@end
