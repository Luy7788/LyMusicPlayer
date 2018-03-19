//
//  LyMusicPlayerSlider.m
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicPlayerSlider.h"
#import "LyMusicManager.h"
#import "UIImage+Extension.h"

@interface LyMusicPlayerSlider()<UIGestureRecognizerDelegate>
@end

@implementation LyMusicPlayerSlider

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    [self initView];
}

-(void)initView{
    [self setThumbImage:[UIImage imageNamed:@"pic_dot_progressbar"] forState:UIControlStateNormal];
    self.maximumValue = 1;
//    self.minimumTrackTintColor = [UIColor colorHex:0x7834B7];
    self.maximumTrackTintColor = [UIColor clearColor];// [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5]; 
    [self setMinimumTrackImage:[UIImage gradientImageWithBounds:CGRectMake(0, 0, 100, 2) andColors:@[[UIColor colorHex:0xB064DC],[UIColor colorHex:0x7834B7]]] forState:UIControlStateNormal];
//    [self setMaximumTrackImage:[UIImage gradientImageWithBounds:CGRectMake(0, 0, 100, 2) andColors:@[[UIColor  lightGrayColor],[UIColor  lightGrayColor]]] forState:UIControlStateNormal];
    self.layer.masksToBounds = YES;
    
    // slider开始滑动事件
    [self addTarget:self action:@selector(progressSliderTouchBegan:) forControlEvents:UIControlEventTouchDown];
    // slider滑动中事件
    [self addTarget:self action:@selector(progressSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    // slider结束滑动事件
    [self addTarget:self action:@selector(progressSliderTouchEnded:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    UITapGestureRecognizer *sliderTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSliderAction:)];
    [self addGestureRecognizer:sliderTap];
    
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panRecognizer:)];
//    panRecognizer.delegate = self;
//    [panRecognizer setMaximumNumberOfTouches:1];
//    [panRecognizer setDelaysTouchesBegan:YES];
//    [panRecognizer setDelaysTouchesEnded:YES];
//    [panRecognizer setCancelsTouchesInView:YES];
//    [self addGestureRecognizer:panRecognizer];
 
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMusicProgress:) name:kNotification_MusicProgress object:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicProgress object:nil];
}

- (void)progressSliderTouchBegan:(UISlider *)sender {
    if ([LyMusicManager sharedManager].status == MusicStatusLoadingInfo) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(sliderProgressSliderStart:)]) {
        [self.delegate sliderProgressSliderStart:self.value];
    }
}

- (void)progressSliderValueChanged:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(sliderProgressSliderChanged:)]) {
        [self.delegate sliderProgressSliderChanged:self.value];
    }
}

- (void)progressSliderTouchEnded:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(sliderProgressSliderEnd:)]) {
        [self.delegate sliderProgressSliderEnd:self.value];
    }
}

-(void)updateMusicProgress:(NSNotification *)object{
    CGFloat progress = [[object object]floatValue];
    self.value = progress;
}

/**
 *  UISlider TapAction
 */
- (void)tapSliderAction:(UITapGestureRecognizer *)tap {
    if ([LyMusicManager sharedManager].status == MusicStatusLoadingInfo) {
        return;
    }
    CGPoint point = [tap locationInView:self];
    CGFloat length = self.frame.size.width;
    CGFloat tapValue = point.x / length;
    if ([self.delegate respondsToSelector:@selector(sliderProgressSliderEnd:)]) {
        [self.delegate sliderProgressSliderEnd:tapValue];
    }
}

//// 不做处理，只是为了滑动slider其他地方不响应其他手势
//- (void)panRecognizer:(UIPanGestureRecognizer *)sender {
//
//}


@end
