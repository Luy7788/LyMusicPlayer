//
//  LyMusicPlayerContentView.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h> 
#import "LyMusicPlayerCDView.h"
#import "LyMusicPlayerCDViewTopView.h"
#import "LyMusicPlayerLyricView.h"

@protocol LyMusicPlayerContentViewDelegate<NSObject>
-(void)contentViewCDViewKbitLevelButtonClickAction;
-(void)contentViewCDViewMVButtonClickAction;
@end

@interface LyMusicPlayerContentView : UIView
@property (nonatomic ,weak) LyMusicDetailModel          *songsModel;
@property (nonatomic ,strong)LyMusicPlayerCDView        *cdView;
@property (nonatomic ,strong)LyMusicPlayerLyricView     *lyricView;
@property (nonatomic ,strong)LyMusicPlayerCDViewTopView *topView;
@property (nonatomic ,weak) id <LyMusicPlayerContentViewDelegate>   delegate;
//设置当前歌词进度
-(void)setupCurrentLyricIndex:(NSInteger)index;

@end
