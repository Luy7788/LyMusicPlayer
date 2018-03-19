//
//  LyMusicPlayerLyricView.h
//  jy_client
//
//  Created by Lying on 2017/10/22.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LyMusicDetailModel;
@class LyMusicPlayerLyricModel;
@interface LyMusicPlayerLyricView : UIView

@property (nonatomic ,weak) LyMusicDetailModel     *songsModel;

//设置当前歌词进度
-(void)setupCurrentLyricIndex:(NSInteger)index;


@end
