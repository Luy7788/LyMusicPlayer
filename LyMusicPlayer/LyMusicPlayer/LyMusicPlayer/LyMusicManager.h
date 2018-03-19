//
//  LyMusicManager.h
//  jy_client
//
//  Created by Lying on 2017/10/19.
//  Copyright © 2017年 JY. All rights reserved.
//

//音乐专用通知
static NSString  *kNotification_LyricCurrentIndex = @"Notification_CurrentLyricIndex";
static NSString  *kNotification_MusicProgress = @"Notification_MusicProgress";
static NSString  *kNotification_MusicPlay = @"Notification_MusicPlay";
static NSString  *kNotification_MusicPause = @"Notification_MusicPause";
static NSString  *kNotification_MusicStop = @"Notification_MusicStop";
static NSString  *kNotification_MusicNext = @"Notification_MusicNext";//上一首、下一首

typedef NS_ENUM(NSInteger, MusicPlayModel) {
    MusicPlayModelNormal,
    MusicPlayModelCycle,
    MusicPlayModelSingleCycle,
    MusicPlayModelRandom,
};

#import <AVFoundation/AVFoundation.h>
#import <Foundation/Foundation.h>
//#import "JYMusicPlayerSongModel.h"
#import "LyMusicPlayerLyricModel.h"
#import "LyMusicManagerDelegate.h"
#import "LyMusicLockScreenControl.h"
#import "LyMusicPlayerViewController.h"

@interface LyMusicManager : NSObject
//锁屏播放的功能
@property (nonatomic ,strong)LyMusicLockScreenControl        *lockscreenControl;
/** 协议代理 */
@property (nonatomic ,assign) id<LyMusicManagerDelegate>     delegate;
/** 音乐播放状态 */
@property (nonatomic, assign) MusicStatus                    status;
/* 播放模式*/
@property (nonatomic, assign) MusicPlayModel                 playModel;
/** 当前时间 */
@property (nonatomic, assign) NSTimeInterval                 currentTime;
/** 总时间 */
@property (nonatomic, assign) NSTimeInterval                 durationTime;
/** 是否正在滑杆调整时间 */
@property (nonatomic, assign) BOOL                           isSeeking;

/* 当前这首歌的模型 */
@property (nonatomic , readonly ,strong) LyMusicDetailModel   *currentSongModel;
/* 当前设置的播放列表（随机播放不使用） */
@property (nonatomic , readonly ,strong) NSMutableArray       *songsModelArray;
/* 随机播放的播放列表 */
@property (nonatomic , readonly ,strong) NSMutableArray       *randomSongsModelArray;

#pragma mark - 单例 
+(instancetype)sharedManager;
#pragma mark - 获取播放器界面
-(UIViewController *)musicPlayerContrller;;
#pragma mark - 添加下一首播放
-(void)addNextSong:(LyMusicDetailModel *)songModel; 
#pragma mark - 设置播放列表
/**
 切换播放列表，设置当前播放歌曲
 @param songList        播放列表
 @param playIndex       播放的index 
 */
- (void)setupPlayMusicWithSongList:(NSArray<LyMusicDetailModel*>*)songList
                         playIndex:(NSInteger)playIndex ;



#pragma mark - 播放
-(void)play;
#pragma mark - 暂停
-(void)pause;
#pragma mark - 停止播放
- (void)stop;
#pragma mark - 下一首
-(void)next;
#pragma mark - 上一首
-(void)last;

#pragma mark - 跳转音乐进度
//标记开始
- (void)seekToTimeBegin;
//跳转至对应位置
- (void)seekToTimeEndWithProgress:(CGFloat)progress completionHandler:(void (^)(void))completionHandler;

/**
 时间格式转换
 @param duration 时间秒数
 @return 时间字符串 如 00:00
 */
- (NSString *)formatTime:(NSTimeInterval)duration;
/**
 为数组随机排序
 @param array 源数组
 @return 随机数组
 */
- (NSArray *)randomArray:(NSArray *)array;
 
@end
