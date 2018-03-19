//
//  LyMusicPlayerContentView.m
//  jy_client
//
//  Created by Lying on 2017/10/20.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicPlayerContentView.h"

@interface LyMusicPlayerContentView()<LyMusicPlayerCDViewTopViewDelegate,UIScrollViewDelegate>
@property (nonatomic ,strong)UIScrollView       *scrollView;
@property (nonatomic ,strong)UIPageControl      *pageControl;
@end

@implementation LyMusicPlayerContentView

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
    //添加歌词view
    [self.scrollView addSubview:self.lyricView];
    //添加专辑view
    [self addSubview:self.cdView];
    //添加顶部音质、mv
    [self addSubview:self.topView];
    //分页指示
    [self addSubview:self.pageControl];
}

-(void)layoutSubviews{
    self.cdView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.topView.frame = CGRectMake(0, 0, self.frame.size.width, 30);
    self.lyricView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    self.pageControl.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20);
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width*2, self.frame.size.height); 
}

-(void)dealloc{
    [self.cdView stopTimer];
}

-(void)setSongsModel:(LyMusicDetailModel *)songsModel{
    _songsModel = songsModel;
    self.cdView.songsModel = songsModel;
    self.lyricView.songsModel = songsModel;
    [self.topView setupCurrentKbitLevel:@"标准" isHaveOtherKbitLevel:YES isHaveMV:NO];
}

//设置当前歌词进度
-(void)setupCurrentLyricIndex:(NSInteger)index{
    [self.cdView setupCurrentLyricIndex:index];
    [self.lyricView setupCurrentLyricIndex:index];
}

#pragma mark - 代理
-(void)topViewMVButtonClickAction{
    if([self.delegate respondsToSelector:@selector(contentViewCDViewMVButtonClickAction)]){
        [self.delegate contentViewCDViewMVButtonClickAction];
    }
}

-(void)topViewKbitLevelButtonClickAction{
    if([self.delegate respondsToSelector:@selector(contentViewCDViewKbitLevelButtonClickAction)]){
        [self.delegate contentViewCDViewKbitLevelButtonClickAction];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender{
    CGFloat pagewidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pagewidth/2)/pagewidth)+1;
    self.pageControl.currentPage = page;
    
    CGFloat alpha = 1-((self.scrollView.contentOffset.x - pagewidth)/pagewidth +1);
    if(alpha<0){
        alpha = 0;
    }else if(alpha >1){
        alpha = 1;
    }
    self.cdView.alpha = alpha;
    self.topView.alpha = alpha;
}

#pragma mark - 懒加载
-(LyMusicPlayerCDView *)cdView{
    if(_cdView == nil){
        LyMusicPlayerCDView *cdView = [[LyMusicPlayerCDView alloc]init];
        cdView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
        _cdView = cdView;
        _cdView.userInteractionEnabled = NO;
    }
    return _cdView;
}

-(LyMusicPlayerLyricView *)lyricView{
    if(_lyricView == nil){
        _lyricView = [[LyMusicPlayerLyricView alloc]init];
        _lyricView.frame = CGRectMake(self.frame.size.width, 0, self.frame.size.width, self.frame.size.height);
    }
    return _lyricView;
}

-(UIScrollView *)scrollView{
    if(_scrollView == nil){
        _scrollView = [[UIScrollView alloc]init];
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.pagingEnabled = YES;
        _scrollView.userInteractionEnabled = YES;
        _scrollView.scrollEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _scrollView;
}

-(LyMusicPlayerCDViewTopView *)topView{
    if (_topView == nil) {
        _topView = [[[NSBundle mainBundle]loadNibNamed:@"LyMusicPlayerCDViewTopView" owner:nil options:nil]lastObject];
        _topView.frame = CGRectMake(0, 0, self.frame.size.width, 30);
        _topView.delegate = self;
        _topView.userInteractionEnabled = YES;
    }
    return _topView;
}

-(UIPageControl *)pageControl{
    if(_pageControl == nil){
        _pageControl = [[UIPageControl alloc]init];
        _pageControl.pageIndicatorTintColor = [UIColor colorHex:0xCCCCCC];//[UIColor colorHex:0xDDDDDD];
        _pageControl.currentPageIndicatorTintColor = [UIColor colorHex:0x999999];
        _pageControl.numberOfPages = 2;
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

@end
