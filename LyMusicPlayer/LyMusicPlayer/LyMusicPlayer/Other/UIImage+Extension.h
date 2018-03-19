//
//  UIImage+Extension.h
//  jy_client
//
//  Created by Lying on 2017/10/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
 
- (UIImage*)cropRect:(CGRect)clipRect;

//从上到下 渐变
+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors;

// 压缩图片到指定尺寸大小
- (UIImage *)compressImageToSize:(CGSize)size;
 

/**
 拼接图片

 @param slaveImage 要拼接的图片
 @param masterImage 原图
 @param slaveFrame 拼接位置
 @return 拼接好的图片
 */
+ (UIImage *)addSlaveImage:(UIImage *)slaveImage
             toMasterImage:(UIImage *)masterImage
                slaveFrame:(CGRect)slaveFrame;


@end
