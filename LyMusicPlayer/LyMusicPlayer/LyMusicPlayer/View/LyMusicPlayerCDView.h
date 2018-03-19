//
//  LyMusicPlayerCDView.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LyMusicDetailModel;
@class LyMusicPlayerLyricModel;

@interface LyMusicPlayerCDView : UIView

@property (nonatomic ,weak) LyMusicDetailModel     *songsModel;

//停止定时器，停止CD旋转
-(void)stopTimer;
//设置当前歌词进度
-(void)setupCurrentLyricIndex:(NSInteger)index;

@end

 
