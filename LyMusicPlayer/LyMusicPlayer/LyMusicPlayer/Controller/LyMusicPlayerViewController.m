//
//  LyMusicPlayerViewController.m
//  jy_client
//
//  Created by Lying on 2017/10/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicPlayerViewController.h"
#import "LyMusicManager.h"
//view
#import "LyMusicPlayerSlider.h"
#import "LyMusicPlayerContentView.h"

@interface LyMusicPlayerViewController ()<LyMusicPlayerSliderDelegate,LyMusicManagerDelegate,LyMusicPlayerContentViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView            *bigBackgroundImageView;
@property (weak, nonatomic) IBOutlet UIButton               *goMoreBtn;//更多
@property (weak, nonatomic) IBOutlet UIButton               *play_Button;//播放
@property (weak, nonatomic) IBOutlet UIButton               *stop_Button;//停止播放
@property (weak, nonatomic) IBOutlet UIButton               *list_Button;//最近列表
@property (weak, nonatomic) IBOutlet UIButton               *close_Button;//返回
@property (weak, nonatomic) IBOutlet UILabel                *currentTimeLabel;//当前时间
@property (weak, nonatomic) IBOutlet UILabel                *totalTimeLabel;//时长
@property (weak, nonatomic) IBOutlet UILabel                *songnameLabel;//歌曲名
@property (weak, nonatomic) IBOutlet UILabel                *singerLabel;//歌手
@property (weak, nonatomic) IBOutlet UIButton               *modeButton;//模式切换
@property (weak, nonatomic) IBOutlet UIButton               *lastButton;//上一首
@property (weak, nonatomic) IBOutlet UIButton               *nextButton;//下一首
@property (weak, nonatomic) IBOutlet UIButton               *likeButton;//喜欢
@property (weak, nonatomic) IBOutlet UIButton               *downloadButton;//下载
@property (weak, nonatomic) IBOutlet UILabel                *commentCountLabel;//评论数量
@property (weak, nonatomic) IBOutlet UIButton               *commentButton;//评论
@property (weak, nonatomic) IBOutlet UIButton               *shareButton;//分享
@property (weak, nonatomic) IBOutlet LyMusicPlayerSlider    *slider;   //滑动进度
@property (weak, nonatomic) IBOutlet LyMusicPlayerContentView *lrcView;//歌词view
@property (weak, nonatomic) IBOutlet NSLayoutConstraint     *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView           *scrollTitleView; //滚动标题
@property (weak, nonatomic) IBOutlet UILabel                *scrollTitleLabel;
@property (weak, nonatomic) IBOutlet UIProgressView         *progressView;

@property (nonatomic ,  weak) LyMusicDetailModel         *currentSongModel;//当前的歌曲模型

@end

@implementation LyMusicPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNav];
    [self setupUI];
    self.bigBackgroundImageView.layer.masksToBounds = YES;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playOrStop) name:kNotification_MusicPlay object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playOrStop) name:kNotification_MusicPause object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(playOrStop) name:kNotification_MusicStop object:nil];
}

#pragma mark - 自定义返回方法
- (void)customBack {
    if (self.navigationController && self.navigationController.viewControllers.count > 1) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [(BaseNavigationController *)self.navigationController setBackButtonHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
//    [(BaseNavigationController *)self.navigationController setBackButtonHidden:NO];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

-(void)dealloc{
    [LyMusicManager sharedManager].delegate = nil; 
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicPlay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicPause object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicStop object:nil];
}

-(void)setupNav{
    self.title = @"";
}

-(void)setupUI{
    self.topLayoutConstraint.constant = 30 + SAVE_ARE_BOTTOM;
    [self playOrStop];
    [self setupPlayModelDisplay];
    [LyMusicManager sharedManager].delegate = self;
    self.slider.delegate = self;
    self.slider.userInteractionEnabled = YES;
    self.lrcView.delegate = self;
    self.progressView.progressTintColor = [UIColor lightGrayColor];//[UIColor colorWithWhite:0.5 alpha:1.0];
    self.progressView.trackTintColor = [UIColor darkGrayColor];
}

#pragma mark - 设置当前歌曲模型
-(void)setupCurrentModel:(LyMusicDetailModel*)songModel{ 
    //设置样式
    self.currentSongModel = songModel;
    self.lrcView.songsModel = songModel;
    self.songnameLabel.text = songModel.name;
    self.singerLabel.text = songModel.singer;
    self.scrollTitleLabel.text = songModel.name;
    [self.likeButton setSelected:songModel.isFavorite.length>1?YES:NO];
    self.commentCountLabel.text = (songModel.comments>10000)?[NSString stringWithFormat:@"%.1f万",(CGFloat)songModel.comments/10000] : [NSString stringWithFormat:@"%zd",songModel.comments];
    //背景图设置
//    [self.bigBackgroundImageView sd_setImageWithURL:[NSURL URLWithString:songModel.cover]];
    [self updateProgress];
    
    //检查是否只有单曲
    if ([LyMusicManager sharedManager].songsModelArray.count <= 1) {
        self.nextButton.enabled = NO;
        self.lastButton.enabled = NO;
    }else{
        self.nextButton.enabled = YES;
        self.lastButton.enabled = YES;
    }
    
    //检测标题长度，如果过长就滚动
    if (songModel.name.length) {
        CGSize constraintSize = CGSizeMake(MAXFLOAT,22);
        [self.scrollTitleLabel layoutIfNeeded];
        __block CGSize size = [self.scrollTitleLabel sizeThatFits:constraintSize];
        if (size.width > self.scrollTitleView.frame.size.width) {
            self.scrollTitleView.hidden = NO;
            self.songnameLabel.hidden = YES;
            self.scrollTitleLabel.text = [NSString stringWithFormat:@"%@    %@",songModel.name,songModel.name];
            [self.scrollTitleLabel layoutIfNeeded];
            [self.scrollTitleView layoutIfNeeded];
            size = [self.scrollTitleLabel sizeThatFits:constraintSize];
            self.scrollTitleView.contentSize = CGSizeMake(size.width, size.height);
            self.scrollTitleLabel.frame = CGRectMake(0, 0, size.width, size.height);
            NSLog(@"size %@ songModel.name %@",NSStringFromCGSize(self.scrollTitleLabel.frame.size),songModel.name);
            //滚动动画
            [UIView animateWithDuration:(size.width*8.0f/SCREEN_WIDTH) delay:1.0f options:UIViewAnimationOptionCurveLinear|UIViewAnimationOptionRepeat animations:^{
                CGRect frame = self.scrollTitleLabel.frame;
                self.scrollTitleLabel.transform = CGAffineTransformMakeTranslation(-frame.size.width/2 - 8, 0);
            } completion:^(BOOL finished) {
            }];
        }else{
            self.scrollTitleView.hidden = YES;
            self.songnameLabel.hidden = NO;
        }
    }
}
#pragma mark - 更新歌曲进度
-(void)updateProgress{
    self.currentTimeLabel.text =  [[LyMusicManager sharedManager] formatTime:[LyMusicManager sharedManager].currentTime];
    self.totalTimeLabel.text = [[LyMusicManager sharedManager] formatTime:[[LyMusicManager sharedManager] durationTime]];
}

-(void)updateProgressWithProgress:(CGFloat)progress{
    self.currentTimeLabel.text =  [[LyMusicManager sharedManager] formatTime:[LyMusicManager sharedManager].durationTime*progress];
    self.totalTimeLabel.text = [[LyMusicManager sharedManager] formatTime:[[LyMusicManager sharedManager] durationTime]];
}


#pragma mark - 播放模式的不同样式
-(void)setupPlayModelDisplay{
    switch ([LyMusicManager sharedManager].playModel) {
        case MusicPlayModelNormal:
            [self.modeButton setImage:[UIImage imageNamed:@"icon_musicplay_order"] forState:UIControlStateNormal];
            break;
        case MusicPlayModelCycle:
            [self.modeButton setImage:[UIImage imageNamed:@"icon_musicplay_loop"] forState:UIControlStateNormal];
            break;
        case MusicPlayModelSingleCycle:
            [self.modeButton setImage:[UIImage imageNamed:@"icon_musicplay_singlecycle"] forState:UIControlStateNormal];
            break;
        case MusicPlayModelRandom:
            [self.modeButton setImage:[UIImage imageNamed:@"icon_musicplay_random"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}
#pragma mark -播放器按键设置
-(void)playOrStop{
    dispatch_async(dispatch_get_main_queue(), ^{
        if([LyMusicManager sharedManager].status == MusicStatusPlaying){
            self.play_Button.hidden = YES;
            self.play_Button.enabled = NO;
            self.stop_Button.hidden = NO;
            self.stop_Button.enabled = YES;
        }else{
            self.play_Button.hidden = NO;
            self.play_Button.enabled = YES;
            self.stop_Button.hidden = YES;
            self.stop_Button.enabled = NO;
        }
    });
}
#pragma mark - 点击导航栏更多
-(void)goMore{
    [self goMoreAction:nil];
}
#pragma mark - 点击事件
- (IBAction)goBackAction:(id)sender {
    [self customBack];
}
#pragma mark - 更多
- (IBAction)goMoreAction:(id)sender {
}
#pragma mark - 播放
- (IBAction)playAction:(id)sender {
    [[LyMusicManager sharedManager]play];
    [self playOrStop];
}
#pragma mark - 停止
- (IBAction)stopAction:(id)sender {
    [[LyMusicManager sharedManager]pause];
    [self playOrStop];
}
#pragma mark - 上一首
- (IBAction)lastAction:(id)sender {
    [[LyMusicManager sharedManager]last];
}
#pragma mark - 下一首
- (IBAction)nextAction:(id)sender {
    [[LyMusicManager sharedManager]next];
}
#pragma mark - 切换模式
- (IBAction)modeChangeAction:(id)sender {
    switch ([LyMusicManager sharedManager].playModel) {
        case MusicPlayModelNormal:
            [LyMusicManager sharedManager].playModel = MusicPlayModelCycle;
            break;
        case MusicPlayModelCycle:
            [LyMusicManager sharedManager].playModel = MusicPlayModelSingleCycle;
            break;
        case MusicPlayModelSingleCycle:
            [LyMusicManager sharedManager].playModel = MusicPlayModelRandom;
            break;
        case MusicPlayModelRandom:
            [LyMusicManager sharedManager].playModel = MusicPlayModelNormal;
            break;
        default:
            break;
    }
    [self setupPlayModelDisplay];
}
#pragma mark - 列表
- (IBAction)listAction:(id)sender {
}

#pragma mark - 评论列表
- (IBAction)commentAction:(id)sender {
}

#pragma mark - 分享
- (IBAction)shareAction:(id)sender {
}

#pragma mark - 下载
- (IBAction)downloadAction:(id)sender {
}

#pragma mark - 喜欢
- (IBAction)likeAction:(UIButton *)sender {
    if(sender.selected){
        [sender setSelected:NO];
    }else{
        [sender setSelected:YES];
    }
}

#pragma mark - 专辑页面代理方法
//点击音质
-(void)contentViewCDViewKbitLevelButtonClickAction{
}
//点击 mv
-(void)contentViewCDViewMVButtonClickAction{
}

#pragma mark - slider代理方法
//滑动条
-(void)sliderProgressSliderStart:(CGFloat)value{
    [[LyMusicManager sharedManager] seekToTimeBegin];
}

-(void)sliderProgressSliderChanged:(CGFloat)value{ 
    [self updateProgressWithProgress:value];
}

-(void)sliderProgressSliderEnd:(CGFloat)value{
    NSLog(@"滑动条 ……%.2f",value);
    [[LyMusicManager sharedManager] seekToTimeBegin];
    [self updateProgressWithProgress:value];
    [[LyMusicManager sharedManager] seekToTimeEndWithProgress:value completionHandler:^{
        ;
    }];
}

#pragma mark - 播放器代理方法
/**
 音乐切换回调
 */
- (void)musicPlayerReplaceMusic:(LyMusicDetailModel *)musicModel{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupCurrentModel:musicModel];
    });
    [self playOrStop];
}
/*
 音乐播放状态回调
 */
- (void)musicPlayerStatusChange:(MusicStatus)musicStatus{
    if (musicStatus==MusicStatusPlaying) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.stop_Button.hidden = NO;
            self.play_Button.hidden = YES;
        });
    }
}
/**
 音乐缓存进度
 */
- (void)musicPlayerCacheProgress:(float)progress{
    NSLog(@"歌曲缓存进度 %f",progress);
    self.progressView.progress = progress;
}
/**
 音乐播放进度
 */
- (void)musicPlayerPlayingProgress:(float)progress{
    [self updateProgressWithProgress:progress];
    self.slider.value = progress;
}
/**
 音乐播放结束
 */
- (void)musicPlayerEndPlay{
    dispatch_async(dispatch_get_main_queue(), ^{
//        self.stop_Button.hidden = NO;
//        self.play_Button.hidden = YES;
        self.play_Button.hidden = NO;
        self.play_Button.enabled = YES;
        self.stop_Button.hidden = YES;
        self.stop_Button.enabled = NO;
    });
}

/**
 音乐歌词当前下标
 */
- (void)musicPlayerLyricIndex:(NSInteger)lyricIndex{
    if([LyMusicManager sharedManager].status != MusicStatusPlaying) return;
//    [self.lrcView setupCurrentLyricIndex:[LyMusicManager sharedManager].lockscreenControl.currectLyricIndex];
}

//为防止为获取歌曲列表的情况下进行一些操作，添加判断处理
-(BOOL)isCanOperate{
    if([LyMusicManager sharedManager].songsModelArray.count > 0){
        return YES;
    }
    return NO;
}


@end
