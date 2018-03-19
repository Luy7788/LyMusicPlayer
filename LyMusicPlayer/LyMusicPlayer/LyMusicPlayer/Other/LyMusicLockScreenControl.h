//
//  LyMusicManagerAuxiliary.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyMusicPlayerLyricModel.h"
#import "LyMusicDetailModel.h"

@interface LyMusicLockScreenControl : NSObject

/** 当前播放的歌词的索引 */
@property (nonatomic, assign) NSInteger currectLyricIndex;
 
//@property (nonatomic ,strong) LyMusicDetailModel             *currentSongModel;
@property (nonatomic ,weak) LyMusicDetailModel             *currentSongModel;



- (void)addRemoteCommandCenterWithTarget:(id)target
                                 playAction:(SEL)playAction
                                pauseAction:(SEL)pauseAction
                             lastSongAction:(SEL)lastAction
                             nextSongAction:(SEL)nextAction;

- (void)updateLockScreenWithDurationTime:(NSTimeInterval)durationTime CurrentTime:(NSTimeInterval)currentTime;



@end
