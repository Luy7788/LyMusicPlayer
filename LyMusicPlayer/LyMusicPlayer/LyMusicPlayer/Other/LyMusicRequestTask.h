//
//  LyMusicRequestTask.h
//  jy_client
//
//  Created by Lying on 2017/10/25.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol LyMysicRequestTaskDelegate <NSObject>
@required
- (void)requestTaskDidUpdateCache; //更新缓冲进度代理方法
@optional
- (void)requestTaskDidReceiveResponse;//响应回调
- (void)requestTaskDidFinishLoadingWithCache:(BOOL)cache;//结束
- (void)requestTaskDidFailWithError:(NSError *)error;//失败

@end

@interface LyMusicRequestTask : NSObject

@property (nonatomic, weak) id<LyMysicRequestTaskDelegate> delegate;
@property (nonatomic, strong) NSURL * requestURL; //请求网址
//@property (nonatomic, assign) NSUInteger requestOffset; //请求起始位置
//@property (nonatomic, assign) NSUInteger fileLength; //文件长度
//@property (nonatomic, assign) NSUInteger cacheLength; //缓冲长度
@property (nonatomic, assign) long long requestOffset; //请求起始位置
@property (nonatomic, assign) long long fileLength; //文件长度
@property (nonatomic, assign) long long cacheLength; //缓冲长度
@property (nonatomic, assign) BOOL cache; //是否缓存文件
@property (nonatomic, assign) BOOL cancel; //是否取消请求

-(void)start;

@end
