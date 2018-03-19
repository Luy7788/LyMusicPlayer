//
//  UIColor+JY.m
//  jy_client
//
//  Created by JY on 2017/9/29.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "UIColor+JY.h"

@implementation UIColor (JY)

+ (UIColor*)colorHex:(NSUInteger)hex{
    return [UIColor colorWithRed:(((hex & 0xFF0000) >> 16))/255.0 green:(((hex &0xFF00) >>8))/255.0 blue:((hex &0xFF))/255.0 alpha:1.0];
}

+ (UIColor*)colorHex:(NSUInteger)hex alpha:(CGFloat)alpha{
    return [UIColor colorWithRed:(((hex & 0xFF0000) >> 16))/255.0 green:(((hex &0xFF00) >>8))/255.0 blue:((hex &0xFF))/255.0 alpha:alpha];
}

@end
