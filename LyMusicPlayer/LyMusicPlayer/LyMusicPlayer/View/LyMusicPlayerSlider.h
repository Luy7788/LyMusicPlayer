//
//  LyMusicPlayerSlider.h
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LyMusicPlayerSliderDelegate<NSObject>
//结束滑动 返回 -> x%
-(void)sliderProgressSliderEnd:(CGFloat)value;
//滑动中
-(void)sliderProgressSliderChanged:(CGFloat)value;
//开始
-(void)sliderProgressSliderStart:(CGFloat)value;
@end

@interface LyMusicPlayerSlider : UISlider
@property (nonatomic ,weak) id<LyMusicPlayerSliderDelegate>  delegate;
@end
