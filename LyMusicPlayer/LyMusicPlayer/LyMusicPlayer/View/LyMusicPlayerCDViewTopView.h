//
//  LyMusicPlayerCDViewTopView.h
//  jy_client
//
//  Created by Lying on 2017/10/23.
//  Copyright © 2017年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol LyMusicPlayerCDViewTopViewDelegate<NSObject>
-(void)topViewKbitLevelButtonClickAction;
-(void)topViewMVButtonClickAction;
@end

@interface LyMusicPlayerCDViewTopView : UIView

@property (nonatomic ,weak) id<LyMusicPlayerCDViewTopViewDelegate> delegate;

-(void)setupCurrentKbitLevel:(NSString *)currentKbitLevel isHaveOtherKbitLevel:(BOOL)isHaveOtherKbit isHaveMV:(BOOL)isHaveMV;
//-(void)setupCurrentKbitLevel:(NSString *)currentKbitLevel KbitLevelsArray:(NSArray<NSString *>*)KbitLevelsArray isHaveMV:(BOOL)isHaveMV;

@end
