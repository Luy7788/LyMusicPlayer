//
//  LyMusicPlayerCDView.m
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//
#define timerDuration       0.1
#import "LyMusicPlayerCDView.h"
#import "LyMusicManager.h"
#import "LyMusicDetailModel.h"
#import "LyMusicPlayerLyricModel.h"

@interface LyMusicPlayerCDView () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UIView         *contentView;
@property (nonatomic,strong) UIImageView    *bgShadowImageView;//CD背景阴影
@property (nonatomic,strong) UIImageView    *CDCoverImageView; //CD
@property (nonatomic,strong) UIImageView    *topCoverImageView;//CD中间的圆圈
@property (nonatomic,strong) UITableView    *lrcTabelView;     //底部歌词
@property (nonatomic,assign) NSInteger      lyricIndex;
@property (nonatomic,strong) NSTimer        *timer;
@end

@implementation LyMusicPlayerCDView

- (instancetype)init{
    self = [super init];
    if (self) {
        [self initView];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [self initView];
//    }
//    return self;
//}

-(void)initView{  
    [self addSubview:self.contentView]; 
//    int CDinsetWidth = 68*SCREEN_WIDTH/375;//32
//    int CDViewWidth = 270*SCREEN_WIDTH/375;
//    int contentViewWidth = CDViewWidth+CDinsetWidth;//310*SCREEN_WIDTH/375;
    int contentViewWidth = 340*SCREEN_WIDTH/375;
    int contentViewHeight = 355*SCREEN_WIDTH/375;
    int CDViewWidth = (340-70)*SCREEN_WIDTH/375;
    
    if(IS_IPHONE_4S_RATIO){
        contentViewWidth = 174;
        contentViewWidth = 181;
        CDViewWidth = 138;
    }
    
    [self.contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self).offset(-4);
        make.centerX.equalTo(self);
        make.width.equalTo(@(contentViewWidth));
        make.height.equalTo(@(contentViewHeight));
    }];
    
    //最后面一层有阴影
    [self.contentView addSubview:self.bgShadowImageView];
    [self.bgShadowImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
     }];
    if(IS_IPHONE_4S_RATIO){
        self.bgShadowImageView.contentMode = UIViewContentModeScaleAspectFit;
    }else{
        self.bgShadowImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    
    //播放旋转的 歌手 imageView
    [self.contentView addSubview:self.CDCoverImageView];
    [self.CDCoverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.contentView).insets(UIEdgeInsetsMake(CDinsetWidth, CDinsetWidth, CDinsetWidth, CDinsetWidth));
        make.center.equalTo(self.contentView);
        make.width.height.equalTo(@(CDViewWidth));
    }];
    self.CDCoverImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.CDCoverImageView layoutIfNeeded];
    self.CDCoverImageView.layer.cornerRadius = self.CDCoverImageView.frame.size.width/2;
    self.CDCoverImageView.layer.masksToBounds = YES;
    
    //最上层 黑洞(专业术语)
    int coverImageWidth = 70*SCREEN_WIDTH/375;
    [self.contentView addSubview:self.topCoverImageView];
    [self.topCoverImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.width.height.equalTo(@(coverImageWidth));
    }];
    self.topCoverImageView.layer.cornerRadius = coverImageWidth/2;
    self.topCoverImageView.layer.masksToBounds = YES;
    self.topCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    //歌词view
    [self addSubview:self.lrcTabelView];
    [self.lrcTabelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@(44*SCREEN_WIDTH/375));
        make.bottom.equalTo(self).offset(-(20*SCREEN_WIDTH/375));
    }];
    
    //通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLyric:) name:kNotification_LyricCurrentIndex object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicPlayAction) name:kNotification_MusicPlay object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicPauseAction) name:kNotification_MusicPause object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(musicPauseAction) name:kNotification_MusicStop object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkTimer) name:kNotification_MusicProgress object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(restoreCDView) name:kNotification_MusicNext object:nil];
    
    if(self.timer == nil){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timerDuration target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];//NSRunLoopCommonModes
    }
//    [self stopTimer];
    //关闭定时器
    [self.timer setFireDate:[NSDate distantFuture]];
}

-(void)dealloc{
    [self stopTimer];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_LyricCurrentIndex object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicPlay object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicPause object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicStop object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicProgress object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_MusicNext object:nil];
}

-(void)layoutSubviews{
    
}

-(void)stopTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)checkTimer{
    if(self.timer == nil){
        self.timer = [NSTimer scheduledTimerWithTimeInterval:timerDuration target:self selector:@selector(updateProgress) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];//NSRunLoopCommonModes
    }
}

-(void)restoreCDView{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.CDCoverImageView.transform = CGAffineTransformIdentity;
    });
}

-(void)musicPlayAction{
//    [self checkTimer];
    //开启定时器
    [self.timer setFireDate:[NSDate distantPast]];
}

-(void)musicPauseAction{
    [self stopTimer];
}

#pragma mark - 更新歌词进度
-(void)updateProgress{
    __weak __typeof(self)weakSelf = self;
    [UIView animateWithDuration:timerDuration animations:^{
        weakSelf.CDCoverImageView.transform = CGAffineTransformRotate(weakSelf.CDCoverImageView.transform, M_PI_2* 0.005);
    }];
}

-(void)setSongsModel:(LyMusicDetailModel *)songsModel{
    self.lyricIndex = 0;
    _songsModel = songsModel;
    //设置封面图
//    [weakSelf.CDCoverImageView setImage:image];
    [self musicPlayAction];
    [self.lrcTabelView reloadData];
}

-(void)updateLyric:(NSNotification *)obj{
    [self.lrcTabelView reloadData];
    NSNumber *object = obj.object;
    [self setupCurrentLyricIndex:[object integerValue]];
}

-(void)setupCurrentLyricIndex:(NSInteger)index{
    if(self.songsModel != nil){
        self.lyricIndex = index;
        if([LyMusicManager sharedManager].status != MusicStatusPlaying) return;
        if(self.lyricIndex < self.songsModel.lyrics.count){
            [self.lrcTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.lyricIndex inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }else{
            return;
        }
        [self.lrcTabelView reloadData];
    }
}

#pragma mark - tableview代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static CGFloat height = 44;
    return height;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songsModel.lyrics.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    cell.backgroundColor = [UIColor clearColor]; 
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    LyMusicPlayerLyricModel *model = self.songsModel.lyrics[self.lyricIndex];//self.songsModel.lyrics[indexPath.row];
    cell.textLabel.text = model.content;
//    if (self.lyricIndex == indexPath.row) {
        cell.textLabel.textColor = [UIColor colorHex:0x999999];
//    }else{
//        cell.textLabel.textColor = [UIColor grayColor];
//    }
    return cell;
}

#pragma mark - 懒加载
-(UIImageView *)CDCoverImageView{
    if (_CDCoverImageView == nil) {
        _CDCoverImageView = [[UIImageView alloc]init];
    }
    return _CDCoverImageView;
}

-(UIView *)contentView{
    if(_contentView == nil){
        _contentView = [[UIView alloc]init];
        _contentView.backgroundColor = [UIColor clearColor];
//        _contentView.userInteractionEnabled = NO;
    }
    return _contentView;
}

-(UIImageView *)bgShadowImageView{
    if(_bgShadowImageView == nil){
        _bgShadowImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_cd_nearplay"]];
    }
    return _bgShadowImageView;
}

-(UIImageView *)topCoverImageView{
    if(_topCoverImageView == nil){
        _topCoverImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"center_cd_nearplay"]];
        _topCoverImageView.backgroundColor = [UIColor blackColor];
    }
    return _topCoverImageView;
}

-(UITableView *)lrcTabelView{
    if(_lrcTabelView == nil){
        _lrcTabelView = [[UITableView alloc]init];
        _lrcTabelView.backgroundColor = [UIColor clearColor];
        _lrcTabelView.delegate = self;
        _lrcTabelView.dataSource = self;
        _lrcTabelView.separatorColor = [UIColor clearColor];
        _lrcTabelView.userInteractionEnabled = NO;
        [_lrcTabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    }
    return _lrcTabelView;
}

@end 
