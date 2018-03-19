//
//  LyMusicPlayerCDViewTopView.m
//  jy_client
//
//  Created by Lying on 2017/10/23.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicPlayerCDViewTopView.h"

@interface LyMusicPlayerCDViewTopView()
@property (weak, nonatomic) IBOutlet UILabel *KbitLabel;
@property (weak, nonatomic) IBOutlet UIButton *KbitButton;
@property (weak, nonatomic) IBOutlet UIView *KbitContentView;
@property (weak, nonatomic) IBOutlet UILabel *mvLabel;
@property (weak, nonatomic) IBOutlet UIButton *mvButton;
@property (weak, nonatomic) IBOutlet UIView *mvContentView;
@property (nonatomic ,assign) BOOL   isHaveMV;
@end

@implementation LyMusicPlayerCDViewTopView
-(void)awakeFromNib{
    [super awakeFromNib];
    [self initView];
}

-(void)initView{
    self.mvLabel.textColor = [UIColor colorHex:0x333333];
    self.mvContentView.layer.borderWidth = 1.0f;
    self.mvContentView.layer.cornerRadius = 2.0f;
    self.mvContentView.layer.borderColor = [UIColor colorHex:0x333333].CGColor;
    self.mvContentView.layer.masksToBounds = YES;
    
    self.KbitLabel.textColor = [UIColor colorHex:0x333333];;
    self.KbitContentView.layer.borderWidth = 1.0f;
    self.KbitContentView.layer.cornerRadius = 2.0f;
    self.KbitContentView.layer.borderColor = [UIColor colorHex:0x333333].CGColor;
    self.KbitContentView.layer.masksToBounds = YES;
}

-(void)setupCurrentKbitLevel:(NSString *)currentKbitLevel isHaveOtherKbitLevel:(BOOL)isHaveOtherKbit isHaveMV:(BOOL)isHaveMV{
    self.isHaveMV = isHaveMV;
    if(isHaveMV == NO){
        self.mvButton.enabled = NO;
        self.mvContentView.alpha = 0.5f;
    }else{
        self.mvButton.enabled = YES;
        self.mvContentView.alpha = 1.0f;
    }
    if(isHaveOtherKbit == NO){
        self.KbitButton.enabled = NO;
        self.KbitContentView.alpha = 0.5f;
    }else{
        self.KbitButton.enabled = YES;
        self.KbitContentView.alpha = 1.0f;
    }
    self.KbitLabel.text = currentKbitLevel;
}

- (IBAction)KbitBtnClickAction:(id)sender {
    if([self.delegate respondsToSelector:@selector(topViewKbitLevelButtonClickAction)]){
        [self.delegate topViewKbitLevelButtonClickAction];
    }
}

- (IBAction)MVBtnClickAction:(id)sender {
    if([self.delegate respondsToSelector:@selector(topViewMVButtonClickAction)]){
        [self.delegate topViewMVButtonClickAction];
    }
}

@end
