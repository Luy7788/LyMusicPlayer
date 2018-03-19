//
//  LyMusicPlayerLyricModel.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LyMusicPlayerLyricModel : NSObject
/**
 歌词的开始时间
 */
@property (nonatomic, assign) NSTimeInterval beginTime;
/**
 歌词的内容
 */
@property (nonatomic, copy) NSString* content;

/** Id */
@property (nonatomic, copy) NSString *songId;

/**
 生成锁屏歌词图片
 
 @param lyrics 歌词数组
 @param currentIndex 当前歌词
 @param backgroundImage 背景图片，歌曲插图
 @return 图片
 */
+ (UIImage *)lockScreenImageWithLyrics:(NSArray *)lyrics
                          currentIndex:(NSInteger)currentIndex
                       backgroundImage:(UIImage *)backgroundImage;

+ (NSArray *)lyrics:(NSString *)lyric;

@end
