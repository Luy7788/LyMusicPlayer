//
//  LyMusicManagerAuxiliary.m
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LyMusicLockScreenControl.h"

@implementation LyMusicLockScreenControl

#pragma mark 更新锁屏歌词
static NSInteger _index = -1;


#pragma mark 添加远程控制中心
- (void)addRemoteCommandCenterWithTarget:(id)target
                                 playAction:(SEL)playAction
                                pauseAction:(SEL)pauseAction
                             lastSongAction:(SEL)lastAction
                             nextSongAction:(SEL)nextAction {
    // 远程控制类    播放/暂停/上一曲/下一曲
    MPRemoteCommandCenter *center = [MPRemoteCommandCenter sharedCommandCenter];
    [center.playCommand addTarget:target action:playAction];
    [center.pauseCommand addTarget:target action:pauseAction];
    [center.previousTrackCommand addTarget:target action:lastAction];
    [center.nextTrackCommand addTarget:target action:nextAction];
}

- (void)updateLockScreenWithDurationTime:(NSTimeInterval)durationTime CurrentTime:(NSTimeInterval)currentTime{
    // MARK 歌词不变或者app前台运行不需要锁屏歌词，但iOS10控制中心在前台也是需要的……
    // [UIApplication sharedApplication].applicationState == UIApplicationStateActive
    
    // 歌曲封面
    static UIImage *artworkImage;
    if (_index == _currectLyricIndex) {
    }else{
        _index = _currectLyricIndex;
        artworkImage = [LyMusicPlayerLyricModel lockScreenImageWithLyrics:self.currentSongModel.lyrics
                                                       currentIndex:_currectLyricIndex
                                                    backgroundImage:self.currentSongModel.thumbImage];
    }
    
    MPMediaItemArtwork *itemArtwork = [[MPMediaItemArtwork alloc] initWithImage:artworkImage];
    
    /*  播放信息中心，用于控制锁屏界面显示的内容
     MPMediaItemPropertyAlbumTitle       专辑
     MPMediaItemPropertyTitle            歌名
     MPMediaItemPropertyArtist           歌手
     MPMediaItemPropertyArtwork          歌曲封面
     MPMediaItemPropertyComposer         编曲
     MPMediaItemPropertyPlaybackDuration 持续时间
     MPNowPlayingInfoPropertyElapsedPlaybackTime  当前播放时间
     */
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    infoCenter.nowPlayingInfo = @{ MPMediaItemPropertyArtist : self.currentSongModel.singer,
                                  MPMediaItemPropertyTitle : self.currentSongModel.name,
                                  MPMediaItemPropertyPlaybackDuration : @(durationTime),
                                  MPNowPlayingInfoPropertyElapsedPlaybackTime : @(currentTime),
                                  MPMediaItemPropertyArtwork : itemArtwork,
                                  };
//    MPMediaItemPropertyAlbumTitle : self.currentSongModel.album,
}


@end
