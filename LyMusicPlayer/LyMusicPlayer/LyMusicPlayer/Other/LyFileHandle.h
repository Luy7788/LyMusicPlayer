//
//  LyFileHandle.h
//  SULoader
//
//  Created by 万众科技 on 16/6/28.
//  Copyright © 2016年 万众科技. All rights reserved.
//

//用于音乐播放临时存储

#import <Foundation/Foundation.h>

@interface LyFileHandle : NSObject

/**
 *  创建临时文件
 */
+ (BOOL)createTempFile;

/**
 *  往临时文件写入数据
 */
+ (void)writeTempFileData:(NSData *)data;

/**
 *  读取临时文件数据
 */
+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length;

/**
 *  保存临时文件到缓存文件夹
 */
+ (void)cacheTempFileWithFileName:(NSString *)name;

/**
 *  是否存在缓存文件 存在：返回文件路径 不存在：返回nil
 */
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url;

/**
 *  清空缓存文件
 */
+ (BOOL)clearCache;

 

/**
 *  临时文件路径
 */
+ (NSString *)tempFilePath;

/**
 *  缓存文件夹路径
 */
+ (NSString *)cacheFolderPath;

/**
 *  获取网址中的文件名
 */
+ (NSString *)fileNameWithURL:(NSURL *)url;

@end
