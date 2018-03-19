//
//  LyFileHandle.m
//  SULoader
//
//  Created by 万众科技 on 16/6/28.
//  Copyright © 2016年 万众科技. All rights reserved.
//

#import "LyFileHandle.h"

@interface LyFileHandle ()

@property (nonatomic, strong) NSFileHandle * writeFileHandle;
@property (nonatomic, strong) NSFileHandle * readFileHandle;

@end

@implementation LyFileHandle

+ (BOOL)createTempFile {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [LyFileHandle tempFilePath];
    if ([manager fileExistsAtPath:path]) {
        [manager removeItemAtPath:path error:nil];
    }
    return [manager createFileAtPath:path contents:nil attributes:nil];
}

+ (void)writeTempFileData:(NSData *)data {
    NSFileHandle * handle = [NSFileHandle fileHandleForWritingAtPath:[LyFileHandle tempFilePath]];
    [handle seekToEndOfFile];
    [handle writeData:data];
}

+ (NSData *)readTempFileDataWithOffset:(NSUInteger)offset length:(NSUInteger)length {
    NSFileHandle * handle = [NSFileHandle fileHandleForReadingAtPath:[LyFileHandle tempFilePath]];
    [handle seekToFileOffset:offset];
    return [handle readDataOfLength:length];
}

+ (void)cacheTempFileWithFileName:(NSString *)name {
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * cacheFolderPath = [LyFileHandle cacheFolderPath];
    if (![manager fileExistsAtPath:cacheFolderPath]) {
        [manager createDirectoryAtPath:cacheFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", cacheFolderPath, name];
    BOOL success = [[NSFileManager defaultManager] copyItemAtPath:[LyFileHandle tempFilePath] toPath:cacheFilePath error:nil];
    NSLog(@"cache file : %@", success ? @"success" : @"fail");
}

//返回路径
+ (NSString *)cacheFileExistsWithURL:(NSURL *)url {
    NSString * cacheFilePath = [NSString stringWithFormat:@"%@/%@", [LyFileHandle cacheFolderPath], [LyFileHandle fileNameWithURL:url]];
    if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
        return cacheFilePath;
    }
    return nil;
}

+ (BOOL)clearCache {
    NSFileManager * manager = [NSFileManager defaultManager];
    return [manager removeItemAtPath:[LyFileHandle cacheFolderPath] error:nil];
}

+ (NSString *)tempFilePath {
//    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp4"];
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:@"MusicTemp.mp3"];
}

//存储路径
+ (NSString *)cacheFolderPath {
    return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
            stringByAppendingPathComponent:@"MusicCaches"];
//    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"Library"] stringByAppendingPathComponent:@"MusicCaches"];
}

+ (NSString *)fileNameWithURL:(NSURL *)url {
    return [[url.path componentsSeparatedByString:@"/"] lastObject];
}

@end
