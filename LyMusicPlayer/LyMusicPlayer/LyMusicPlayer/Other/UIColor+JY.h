//
//  UIColor+JY.h
//  jy_client
//
//  Created by JY on 2017/9/29.
//  Copyright © 2017年 JY. All rights reserved.
//

//--------------颜色配置---------------
#define COLOR_WHITE         [UIColor colorHex:0xFFFFFF] // 白色颜色
#define COLOR_PURPLE        [UIColor colorHex:0x6F2EB1] // 紫色颜色
#define COLOR_BLACK         [UIColor colorHex:0x333333] // 黑色颜色
#define COLOR_GRAY          [UIColor colorHex:0x999999] // 灰色颜色


#define COLOR_RED           [UIColor colorHex:0xF55858] // 红色颜色
#define COLOR_PINK          [UIColor colorHex:0xFC7C79] // 粉色颜色
#define COLOR_GOLD          [UIColor colorHex:0xDEAD16] // 金色颜色

#define COLOR_LINE          [UIColor colorHex:0xDDDDDD] // 灰线条和边框颜色
#define COLOR_LINE_PURPLE   [UIColor colorHex:0x6F2EB1] // 紫线条和边框颜色

#import <UIKit/UIKit.h>

@interface UIColor (JY)

+ (UIColor *)colorHex:(NSUInteger)hex;

+ (UIColor*)colorHex:(NSUInteger)hex alpha:(CGFloat)alpha;

@end
