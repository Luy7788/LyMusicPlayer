//
//  LyMusicPlayerLyricView.m
//  jy_client
//
//  Created by Lying on 2017/10/22.
//  Copyright © 2017年 JY. All rights reserved.
//
#define rowHeight   (50)

#import "LyMusicPlayerLyricView.h"
#import "LyMusicManager.h"
#import "LyMusicDetailModel.h"
#import "LyMusicPlayerLyricModel.h"
#import "UIImage+Extension.h"

@interface LyMusicPlayerLyricView()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate>{
   BOOL  _isScrolling;
}
@property (nonatomic,strong) UITableView    *lrcTabelView;     //底部歌词
//@property (nonatomic,strong) UIImageView    *coverView;
@property (nonatomic,assign) NSInteger      lyricIndex;
@property (nonatomic,assign) CAGradientLayer *gradLayer;

@property (nonatomic,strong) UILabel        *emptyLyric;//没有歌词

@end

@implementation LyMusicPlayerLyricView

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
    //歌词view
    [self addSubview:self.lrcTabelView];
    int num = (360*SCREEN_WIDTH/375)/rowHeight +1;
    [self.lrcTabelView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self);
//        make.width.equalTo(@(SCREEN_WIDTH));
        make.width.equalTo(@(SCREEN_WIDTH - 70));
        make.centerX.equalTo(self);
        make.centerY.equalTo(self).offset(20);
        make.height.equalTo(@(num * rowHeight));
    }];
    //通知
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateLyric:) name:kNotification_LyricCurrentIndex object:nil];
    _isScrolling = NO;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kNotification_LyricCurrentIndex object:nil];
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    [self layoutIfNeeded];
    [self changeAlpha];
}

#pragma mark - 更新歌词进度
-(void)updateLyric:(NSNotification *)obj{
    NSNumber *object = obj.object;
    [self setupCurrentLyricIndex: [object integerValue]];
}

-(void)setupCurrentLyricIndex:(NSInteger)index{
    if(self.songsModel != nil){
        self.lyricIndex = index;
        [self.lrcTabelView reloadData];
        if(_isScrolling == NO){
            if([LyMusicManager sharedManager].status != MusicStatusPlaying) return;
            if(self.lyricIndex < self.songsModel.lyrics.count){
                [self.lrcTabelView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.lyricIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            }else{
                return;
            }
        }
    }
}

-(void)setSongsModel:(LyMusicDetailModel *)songsModel{
    self.lyricIndex = 0;
    _songsModel = songsModel;
    [self.lrcTabelView reloadData];
    if(_songsModel.lyrics.count==0){
        self.emptyLyric.hidden = NO;
    }else{
        self.emptyLyric.hidden = YES;
    }
}

// 用户开始拖拽时调用
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isScrolling = YES ;
}
// 用户结束拖拽时调用
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (decelerate == NO) {
        _isScrolling = NO ;
    }
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    _isScrolling = NO ;
}

#pragma mark - tableview代理方法
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    static CGFloat height = rowHeight;
    return rowHeight;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.songsModel.lyrics.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell2"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor]; 
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    LyMusicPlayerLyricModel *model = self.songsModel.lyrics[indexPath.row];
    cell.textLabel.text = model.content;
    if (self.lyricIndex == indexPath.row) {
        cell.textLabel.textColor = [UIColor colorHex:0x6F2EB1];
    }else{
        cell.textLabel.textColor = [UIColor colorHex:0x333333];//alpha:1/(labs(self.lyricIndex-indexPath.row) +0.3)
    }
    return cell;
}

-(void)changeAlpha{
    CAGradientLayer *_gradLayer = [CAGradientLayer layer];
    NSArray *colors =  @[(__bridge id)[UIColor colorWithWhite:1 alpha:1.0].CGColor,
                         (__bridge id)[UIColor clearColor].CGColor];
    [_gradLayer setColors:colors];
    //渐变起止点，point表示向量
    [_gradLayer setStartPoint:CGPointMake(0, 0.5)];
    [_gradLayer setEndPoint:CGPointMake(0, 1)];
    //设置颜色分割点（范围：0-1）
    _gradLayer.locations = @[@(0.1f),@(1.0f)];
    [_gradLayer setFrame:CGRectMake(0, 0, self.bounds.size.width, self.lrcTabelView.bounds.size.height)];//
    [self.layer setMask:_gradLayer];
}

#pragma mark - 懒加载
-(UITableView *)lrcTabelView{
    if(_lrcTabelView == nil){
        _lrcTabelView = [[UITableView alloc]init];
        _lrcTabelView.backgroundColor = [UIColor clearColor];
        _lrcTabelView.delegate = self;
        _lrcTabelView.dataSource = self;
        _lrcTabelView.separatorColor = [UIColor clearColor];
//        _lrcTabelView.userInteractionEnabled = NO;
        [_lrcTabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell2"];
        UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 120)];
        footer.backgroundColor = [UIColor clearColor];
        _lrcTabelView.tableFooterView = footer;
        _lrcTabelView.showsVerticalScrollIndicator = NO;
        _lrcTabelView.showsHorizontalScrollIndicator = NO;
    }
    return _lrcTabelView;
}


-(CAGradientLayer *)gradLayer{
    if(_gradLayer == nil){
        _gradLayer = [CAGradientLayer layer];
    }
    return _gradLayer;
}

-(UILabel *)emptyLyric{
    if(_emptyLyric == nil){
        UILabel *emptyLyric = [[UILabel alloc]init];
        emptyLyric.text = @"暂无歌词";
        emptyLyric.font = [UIFont systemFontOfSize:14];
        emptyLyric.textColor = [UIColor colorHex:0x333333];
        [self addSubview:emptyLyric];
        [emptyLyric mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.height.equalTo(@20);
        }];
        emptyLyric.hidden = YES;
        _emptyLyric = emptyLyric;
    }
    return _emptyLyric;
}

@end
