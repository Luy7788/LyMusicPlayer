//
//  UIImage+Extension.m
//  jy_client
//
//  Created by Lying on 2017/10/18.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "UIImage+Extension.h" 
@implementation UIImage (Extension)

- (UIImage*)cropRect:(CGRect)clipRect{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], clipRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedImage;
}


- (UIImage *)blurryImage:(UIImage *)image withMaskImage:(UIImage *)maskImage blurLevel:(CGFloat)blur {
    
    // 创建属性
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    
    // 滤镜效果 高斯模糊
    //    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    //    [filter setValue:cimage forKey:kCIInputImageKey];
    //    // 指定模糊值 默认为10, 范围为0-100
    //    [filter setValue:[NSNumber numberWithFloat:blur] forKey:@"inputRadius"];
    
    /**
     *  滤镜效果 VariableBlur
     *  此滤镜模糊图像具有可变模糊半径。你提供和目标图像相同大小的灰度图像为它指定模糊半径
     *  白色的区域模糊度最高，黑色区域则没有模糊。
     */
    CIFilter *filter = [CIFilter filterWithName:@"CIMaskedVariableBlur"];
    // 指定过滤照片
    [filter setValue:ciImage forKey:kCIInputImageKey];
    CIImage *mask = [CIImage imageWithCGImage:maskImage.CGImage] ;
    // 指定 mask image
    [filter setValue:mask forKey:@"inputMask"];
    // 指定模糊值  默认为10, 范围为0-100
    [filter setValue:[NSNumber numberWithFloat:blur] forKey: @"inputRadius"];
    
    // 生成图片
    CIContext *context = [CIContext contextWithOptions:nil];
    // 创建输出
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // 下面这一行的代码耗费时间内存最多,可以开辟线程处理然后回调主线程给imageView赋值
    //result.extent 指原来的大小size
    //    NSLog(@"%@",NSStringFromCGRect(result.extent));
    //    CGImageRef outImage = [context createCGImage: result fromRect: result.extent];
    
    CGImageRef outImage = [context createCGImage: result fromRect:CGRectMake(0, 0, 320.0 * 2, 334.0 * 2)];
    UIImage * blurImage = [UIImage imageWithCGImage:outImage];
    
    return blurImage;
}


#pragma mark 压缩图片到指定尺寸大小
- (UIImage *)compressImageToSize:(CGSize)size {
    UIImage * resultImage = self;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsEndImageContext();
    return resultImage;
}

+ (UIImage*)gradientImageWithBounds:(CGRect)bounds andColors:(NSArray*)colors{
    NSMutableArray *ar = [NSMutableArray array];
    
    for(UIColor *c in colors) {
        [ar addObject:(id)c.CGColor];
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, YES, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGColorSpaceRef colorSpace = CGColorGetColorSpace([[colors lastObject] CGColor]);
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef)ar, NULL);
    CGPoint start;
    CGPoint end;
//    start = CGPointMake(0.0, 0.0);
//    end = CGPointMake(0.0, bounds.size.height);
    start = CGPointMake(0.0, 0.0);
    end = CGPointMake(bounds.size.width, 0.0);
    CGContextDrawLinearGradient(context, gradient, start, end, kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(gradient);
    CGContextRestoreGState(context);
    CGColorSpaceRelease(colorSpace);
    UIGraphicsEndImageContext();
    return image;
}

 
+ (UIImage *)addSlaveImage:(UIImage *)slaveImage
              toMasterImage:(UIImage *)masterImage
                slaveFrame:(CGRect)slaveFrame
{
    CGSize newSize;
    if (CGRectGetMinX(slaveFrame) > 0) {
        newSize.width = (CGRectGetMinX(slaveFrame) + CGRectGetWidth(slaveFrame)) > masterImage.size.width ? CGRectGetMinX(slaveFrame) + CGRectGetWidth(slaveFrame) : masterImage.size.width;
        if (CGRectGetMinX(slaveFrame) + CGRectGetWidth(slaveFrame) > masterImage.size.width) {
            newSize.width = CGRectGetMinX(slaveFrame) + CGRectGetWidth(slaveFrame);
        } else {
            newSize.width = masterImage.size.width;
        }
    } else {
        if (CGRectGetWidth(slaveFrame) > masterImage.size.width) {
            newSize.width = CGRectGetWidth(slaveFrame);
        } else {
            newSize.width = masterImage.size.width;
        }
    }
    
    if (CGRectGetMinY(slaveFrame) > 0) {
        if (CGRectGetMinY(slaveFrame) + CGRectGetHeight(slaveFrame) > masterImage.size.height) {
            newSize.height = CGRectGetMinY(slaveFrame) + CGRectGetHeight(slaveFrame);
        } else {
            newSize.height = masterImage.size.height;
        }
    } else {
        if (CGRectGetHeight(slaveFrame) > masterImage.size.height) {
            newSize.height = CGRectGetHeight(slaveFrame);
        } else {
            newSize.height = masterImage.size.height;
        }
    }
    
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(newSize, YES, 0);
    
    [masterImage drawInRect:CGRectMake(0, 0, masterImage.size.width, masterImage.size.height)];
    [slaveImage drawInRect:slaveFrame];

    UIImage *resultImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultImage;
}

@end
