//
//  LyMusicDetailModel.h
//  jy_client
//
//  Created by Lying on 2017/11/17.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LyMusicPlayerLyricModel.h"

@interface LyMusicDetailModel : NSObject

#pragma mark - 接口返回
@property (nonatomic, copy) NSString        *ID;//歌曲id 

@property (nonatomic, assign) NSInteger     comments;//评论数

@property (nonatomic, copy) NSString        *isFavorite;//是否喜欢 0==没有     >0则为favoriteId

@property (nonatomic, copy) NSString        *singer;//歌手

@property (nonatomic, copy) NSString        *name;//歌曲名

@property (nonatomic, copy) NSString        *cover;//专辑封面

@property (nonatomic, copy) UIImage         *thumbImage;

@property (nonatomic, copy) NSArray         *lyrics;//歌词数组
@property (nonatomic ,strong) LyMusicPlayerLyricModel *lyricModel;//歌词模型

@property (nonatomic, copy) NSString        *playfileUrl;//当前播放链接

////歌曲本地路径，下载后的路径, 存储格式document/Music/XXXXXXX.mp3
//@property (nonatomic, copy) NSString        *locatePath;
@end
