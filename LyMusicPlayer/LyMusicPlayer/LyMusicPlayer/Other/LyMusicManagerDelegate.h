//
//  LyMusicManagerDelgate.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#ifndef LyMusicManagerDelgate_h
#define LyMusicManagerDelgate_h

typedef NS_ENUM(NSInteger, MusicStatus) {
    MusicStatusNormal,
    MusicStatusReadyToPlay,
    MusicStatusPlaying,
    MusicStatusPause,
    MusicStatusFinish,
    MusicStatusLoadingInfo,
};
@class LyMusicDetailModel;
@protocol  LyMusicManagerDelegate <NSObject>
@optional
/**
 音乐切换回调
 */
- (void)musicPlayerReplaceMusic:(LyMusicDetailModel *)musicModel;
/*
 音乐播放状态回调
 */
- (void)musicPlayerStatusChange:(MusicStatus)musicStatus;
/**
 音乐缓存进度
 */
- (void)musicPlayerCacheProgress:(float)progress;
/**
 音乐播放进度
 */
- (void)musicPlayerPlayingProgress:(float)progress;
/**
 音乐播放结束
 */
- (void)musicPlayerEndPlay;
/**
 音乐歌词当前下标
 */
- (void)musicPlayerLyricIndex:(NSInteger)lyricIndex;
@end


#endif /* LyMusicManagerDelgate_h */
