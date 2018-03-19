//
//  LyMusicResourceLoader.h
//  jy_client
//
//  Created by Lying on 2017/10/25.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "LyMusicRequestTask.h"
#import "LyFileHandle.h"

@class LyMusicResourceLoader;

@protocol LyMusicResourceLoaderDelegate <NSObject>
@optional
//进度
- (void)loader:(LyMusicResourceLoader *)loader cacheProgress:(CGFloat)progress;
//失败
- (void)loader:(LyMusicResourceLoader *)loader failLoadingWithError:(NSError *)error;
@end

@interface LyMusicResourceLoader : NSObject <AVAssetResourceLoaderDelegate,LyMysicRequestTaskDelegate>

@property (nonatomic, weak) id<LyMusicResourceLoaderDelegate> delegate;
@property (atomic, assign)      BOOL seekRequired; //Seek标识
@property (nonatomic, assign)   BOOL cacheFinished;

- (void)stopLoading;

@end
