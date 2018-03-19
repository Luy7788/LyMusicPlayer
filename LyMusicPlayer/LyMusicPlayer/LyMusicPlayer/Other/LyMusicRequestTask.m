//
//  LyMusicRequestTask.m
//  jy_client
//
//  Created by Lying on 2017/10/25.
//  Copyright © 2017年 JY. All rights reserved.
//
#define RequestTimeout 15.0

#import "LyMusicRequestTask.h"
#import "LyFileHandle.h"

@interface LyMusicRequestTask()<NSURLConnectionDataDelegate, NSURLSessionDataDelegate>
@property (nonatomic ,strong) NSURLSession           *session;
@property (nonatomic ,strong) NSURLSessionDataTask   *task;
@end

@implementation LyMusicRequestTask

- (instancetype)init{
    self = [super init];
    if (self) {
        //创建临时目录
        [LyFileHandle createTempFile];
    }
    return self;
}

-(void)start{
    NSURLComponents * components = [[NSURLComponents alloc] initWithURL:self.requestURL resolvingAgainstBaseURL:NO];
    components.scheme = @"http";
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[components URL]  cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:RequestTimeout];
    if (self.requestOffset > 0) {//计算偏移量
        [request addValue:[NSString stringWithFormat:@"bytes=%lld-%lld",self.requestOffset,self.fileLength - 1] forHTTPHeaderField:@"Range"];
    }
    
    [self.task cancel];
    self.session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    self.task = [self.session dataTaskWithRequest:request];
    [self.task resume];
}

-(void)setCancel:(BOOL)cancel{
    _cancel = cancel;
    [self.task cancel];
    //取消
    [self.session invalidateAndCancel];
}

#pragma mark - 代理
//响应回调
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler{
    if(self.cancel) return;//取消了
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSString *connentRange = [[httpResponse allHeaderFields] objectForKey:@"Content-Range"];
    NSString *fileLength = [[connentRange componentsSeparatedByString:@"/"] lastObject];
    
    self.fileLength = fileLength.longLongValue>0 ? fileLength.longLongValue : response.expectedContentLength;
    if ([self.delegate respondsToSelector:@selector(requestTaskDidReceiveResponse)]) {
        [self.delegate requestTaskDidReceiveResponse];
    }
}

//服务器返回数据 可能会调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    if (self.cancel) return;
    [LyFileHandle writeTempFileData:data];
    self.cacheLength += data.length;
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidUpdateCache)]) {
        [self.delegate requestTaskDidUpdateCache];
    }
}

//请求完成会调用该方法，请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    if (self.cancel) {
        NSLog(@"下载取消");
    }else {
        if (error) {
            NSLog(@"下载失败");
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFailWithError:)]) {
                [self.delegate requestTaskDidFailWithError:error];
            }
        }else {
            //可以缓存则保存文件
            NSLog(@"下载成功");
            if (self.cache) {
                [LyFileHandle cacheTempFileWithFileName:[[self.requestURL.path componentsSeparatedByString:@"/"] lastObject]];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(requestTaskDidFinishLoadingWithCache:)]) {
                [self.delegate requestTaskDidFinishLoadingWithCache:self.cache];
            }
        }
    }
}

@end
