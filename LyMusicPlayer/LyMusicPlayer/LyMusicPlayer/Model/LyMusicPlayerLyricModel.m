//
//  LyMusicPlayerLyricModel.m
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicPlayerLyricModel.h"

@implementation LyMusicPlayerLyricModel

// 如果实现了该方法，则处理过程中会忽略该列表内的所有属性
+ (NSArray *)modelPropertyBlacklist {
    return @[@"beginTime"];
}

#pragma mark 生成锁屏歌词图片
+ (UIImage *)lockScreenImageWithLyrics:(NSArray *)lyrics
                          currentIndex:(NSInteger)currentIndex
                       backgroundImage:(UIImage *)backgroundImage {

//    return [UIImage new];
    
    CGSize size = CGSizeMake(500, 500);
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    // 绘制歌曲图片
    if (backgroundImage) [backgroundImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
//    // 绘制歌词半透明背景图片
//    UIImage *imageLrc = [UIImage imageNamed:@"music_lyric"];
//    [imageLrc drawInRect:CGRectMake(0, size.height - 120, size.width, 120)];
    
    if (lyrics && currentIndex >= 0) {
        // 绘制文字
        NSString *textTop = currentIndex == 0 ? @"" : [lyrics[currentIndex - 1] content];
        NSString *textCenter = [lyrics[currentIndex] content];
        NSString *textBottom = currentIndex == lyrics.count - 1 ? @"" : [lyrics[currentIndex + 1] content];
        
        NSString *formatString = [NSString stringWithFormat:@"%@\n%@\n%@", textTop, textCenter, textBottom];
        //修改属性
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:formatString];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;
        paragraphStyle.lineSpacing = 5.0;
        [attrStr addAttributes:@{
                                 NSForegroundColorAttributeName:[UIColor whiteColor],//字体前景颜色（字体颜色）
                                 NSFontAttributeName:[UIFont systemFontOfSize:23],//字体大小
                                 NSParagraphStyleAttributeName : paragraphStyle
                                 }
                         range:NSMakeRange(0, [formatString length])];
        [attrStr addAttributes:@{
                                 NSForegroundColorAttributeName:[UIColor redColor],//字体前景颜色（字体颜色）
                                 NSFontAttributeName:[UIFont systemFontOfSize:25],//字体大小
                                 NSParagraphStyleAttributeName : paragraphStyle
                                 }
                         range:NSMakeRange([textTop length] + 1, [textCenter length])];
        
        CGRect textRect = CGRectMake(0, size.height - 100, size.width, 100);
        
        [attrStr drawInRect:textRect];
    }
    
    // 从上下文中取出图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 关闭图形上下文
    UIGraphicsEndImageContext();
    return image;
}

+ (NSArray *)lyrics:(NSString *)lyric
{
    NSMutableArray *array = [NSMutableArray array];
    // 歌词数组
    lyric = [lyric stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSMutableArray *lyrics = [[lyric componentsSeparatedByString:@"\n"] mutableCopy];
    [lyrics removeObject:@""];
    // 遍历
    for (NSString *lineLrc in lyrics) {
        NSRange startRange = [lineLrc rangeOfString:@"["];
        NSRange stopRange = [lineLrc rangeOfString:@"]"];
        NSString *timeString = @"";
        if (startRange.location == NSNotFound) {
            timeString = lineLrc;
        }else{
            // 截取[]内容
            timeString = [lineLrc substringWithRange:NSMakeRange(startRange.location + 1, stopRange.location - startRange.location - 1)];
            // 正则
            NSString *timeRegex = @"[0-9]{2}\\:[0-9]{2}\\.[0-9]{2}";
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", timeRegex];
            
            // 匹配数据并保存到数组
            LyMusicPlayerLyricModel *model = [LyMusicPlayerLyricModel new];
            if ([predicate evaluateWithObject:timeString]) {
                // 存在时间格式的 [00:00.00]
                NSString *minString = [timeString substringWithRange:NSMakeRange(0, 2)];
                NSString *secString = [timeString substringWithRange:NSMakeRange(3, 2)];
                NSString *mseString = [timeString substringWithRange:NSMakeRange(6, 2)];
                
                float timeLength = [minString floatValue] * 60 + [secString floatValue] + [mseString floatValue] / 1000;
                NSString *lyricString = [lineLrc substringFromIndex:10];
                
                model.beginTime = timeLength;
                model.content = lyricString;
            }else{
                // 其他格式的 ti: ar: al: by: 等
                NSRange startRange = [lineLrc rangeOfString:@":"];
                NSString *lyricString = [timeString substringFromIndex:startRange.location];
                
                model.beginTime = 0.0;
                model.content = lyricString;
            }
            
            [array addObject:model];
        }
    }
    
    return array;
}
@end
