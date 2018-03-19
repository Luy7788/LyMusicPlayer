//
//  LyMusicManager.m
//  jy_client
//
//  Created by Lying on 2017/10/19.
//  Copyright © 2017年 JY. All rights reserved.
//

#import "LyMusicManager.h"
#import "LyFileHandle.h"
#import "LyMusicResourceLoader.h"
#import "LyMusicRequestTask.h"
#import "LyMusicDetailModel.h"

@interface LyMusicManager ()<LyMusicResourceLoaderDelegate>{
    BOOL  _enterBcakground;
}
// 本类中的播放器指针
@property (nonatomic ,strong) AVPlayer                       *player;
// 播放器状态监听
@property (nonatomic ,strong) id                             playTimeObserver;
/* 当前播放的序号 */
@property (nonatomic ,assign) NSInteger                      currentIndex;
/* 当前这首歌的模型 */
@property (nonatomic ,strong) LyMusicDetailModel             *currentSongModel;
/* 当前设置的播放列表（随机播放不使用） */
@property (nonatomic ,strong) NSMutableArray                 *songsModelArray;
/* 随机播放的播放列表 */
@property (nonatomic ,strong) NSMutableArray                 *randomSongsModelArray;
//音乐边下边播
@property (nonatomic ,strong) LyMusicResourceLoader          *resourceLoader;
//音乐播放器-控制器
@property (nonatomic ,strong) LyMusicPlayerViewController    *musicPlayerController;
@end

@implementation LyMusicManager

#pragma mark - 初始化
+ (instancetype)sharedManager{
    static LyMusicManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[LyMusicManager alloc]init];
    });
    return instance;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.lockscreenControl addRemoteCommandCenterWithTarget:self
                                                      playAction:@selector(play)
                                                     pauseAction:@selector(pause)
                                                  lastSongAction:@selector(last)
                                                  nextSongAction:@selector(next)];
    }
    return self;
}

- (void)dealloc{
    self.player = nil;
    [self removePlayerListener];
}

#pragma mark - 获取播放器界面
-(UIViewController *)musicPlayerContrller{
    return self.musicPlayerController;
}

#pragma mark - 切换播放列表，设置当前播放歌曲
/**
 切换播放列表，设置当前播放歌曲
 @param songList        播放列表
 @param playIndex       播放的index
 */
- (void)setupPlayMusicWithSongList:(NSArray<LyMusicDetailModel*>*)songList
                         playIndex:(NSInteger)playIndex {
    if (playIndex>songList.count-1) {
        playIndex = 0;
    }
    //切换歌曲要停止加载先
    [self.resourceLoader stopLoading];
    //设置播放列表
    self.songsModelArray = [NSMutableArray arrayWithArray:songList];
    self.currentIndex = playIndex;
    if(songList.count){
        self.currentSongModel = self.songsModelArray[self.currentIndex];
        [self setupPlayer];
    }
    _randomSongsModelArray = nil;
}
 
#pragma mark - 添加下一首播放
-(void)addNextSong:(LyMusicDetailModel *)songModel{
//    NSLog(@"addNextSong");
    if(self.songsModelArray.count == 0){
        //当前没有播放歌曲
        self.currentIndex = 0;
        self.songsModelArray = [NSMutableArray arrayWithObject:songModel];
        self.currentSongModel = self.songsModelArray[self.currentIndex];
        _randomSongsModelArray = nil;
        [self setupPlayer];
        return;
    }else{
        //判断是否已存在
        BOOL isHave = NO;
        for (LyMusicDetailModel *model in self.songsModelArray) {
            if ([model.ID isEqualToString:songModel.ID] && ![songModel.ID isEqualToString:self.currentSongModel.ID]) {
                isHave = YES;
                [self.songsModelArray removeObject:model];
                [self.songsModelArray insertObject:model atIndex:self.currentIndex+1];
                break;
            }
        }
        if (isHave == NO) {
            if(self.currentIndex >= self.songsModelArray.count-1){
                [self.songsModelArray addObject:songModel];
            }else{
                [self.songsModelArray insertObject:songModel atIndex:self.currentIndex+1];
            }
        }
        _randomSongsModelArray = nil;
    }
}

#pragma mark - 播放前设置player
-(void)setupPlayer{
    __weak __typeof(self)weakSelf = self;
    self.lockscreenControl.currentSongModel = self.currentSongModel;
    //检测歌词
    [self checkCurrentSongLyric];
    self.status = MusicStatusLoadingInfo;
    //查找歌曲，如果有做缓存的话……
    //……
    //直接播放链接
    if (self.currentSongModel.playfileUrl.length) {
        [weakSelf playingWithUrlString:weakSelf.currentSongModel.playfileUrl];
    }
    self.status = MusicStatusReadyToPlay;
    
    if ([self.delegate respondsToSelector:@selector(musicPlayerReplaceMusic:)]) {
        [self.delegate musicPlayerReplaceMusic:self.currentSongModel];
    }
    
    return;
}

#pragma mark - 检测存储
//检测有无存储歌词,如果没有的话，获取方法内部进行下载
-(void)checkCurrentSongLyric{
    
} 

#pragma mark - 播放媒体链接（内部方法）
-(void)playingWithUrlString:(NSString *)urlString{
    NSLog(@"playingWithUrlString");
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    AVPlayerItem *playerItem = nil;
    [self.resourceLoader stopLoading];
    self.resourceLoader = nil;
    if ([url.absoluteString hasPrefix:@"http"]) {
        //如果没有缓存的文件直接播放
        playerItem = [[AVPlayerItem alloc]initWithURL:url];
        //有缓存播放缓存文件
        NSString * cacheFilePath = [LyFileHandle cacheFileExistsWithURL:url];
        if (cacheFilePath) {
            NSURL * url = [NSURL fileURLWithPath:cacheFilePath];
            playerItem = [AVPlayerItem playerItemWithURL:url];
            NSLog(@"有缓存，播放缓存文件");
//            self.resourceLoader = nil;
        }else {
            //没有缓存播放网络文件
            self.resourceLoader = [[LyMusicResourceLoader alloc]init];
            self.resourceLoader.delegate = self;
            NSURLComponents * components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
            components.scheme = @"streaming";
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[components URL] options:nil];
            [asset.resourceLoader setDelegate:self.resourceLoader queue:dispatch_get_main_queue()];
            playerItem = [AVPlayerItem playerItemWithAsset:asset];
            NSLog(@"无缓存 ，播放网络文件");
        }
    }else {
        NSLog(@"路径没有http,播放已下载的本地文件");
        NSURL * url = [NSURL fileURLWithPath:urlString];
        playerItem = [AVPlayerItem playerItemWithURL:url];
//        self.resourceLoader = nil;
    }
    //播放准备
    if (self.player == nil) {
        self.player = [[AVPlayer alloc]initWithPlayerItem:playerItem];
        // AVPlayer只初始化一次，添加|移除 监听也只操作一次
        [self addPlayerListener];
        [self addPlayerItemListener];
    }else {
        // AVPlayerItem会多次生成，也需要多次移除
        [self removePlayerItemListener];
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
        [self addPlayerItemListener];
    }
    [self play];
    if ([self.delegate respondsToSelector:@selector(musicPlayerReplaceMusic:)]) {
        [self.delegate musicPlayerReplaceMusic:self.currentSongModel];
    }
}

#pragma mark - 播放
-(void)play{
    NSLog(@"play");
    if(!self.songsModelArray.count) return;
    if (self.status == MusicStatusFinish) {
        //播放进度
        if ([self.delegate respondsToSelector:@selector(musicPlayerPlayingProgress:)]) {
            [self.delegate musicPlayerPlayingProgress:0.0];
        }
        [self.player seekToTime:CMTimeMake(0.0, 1.0)];
        [self addPlayerItemListener];
    }
    NSLog(@"self.player.status %ld",(long)self.player.status);// AVPlayerStatusFailed;
    [self.player play];
//    self.status = MusicStatusPlaying;
//    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicPlay object:nil];
}

-(void)pause{
//    if(!self.songsModelArray.count) return;
    NSLog(@"pause");
    [self.player pause];
    self.status = MusicStatusPause;
//    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicPause object:nil];
}


//停止播放
- (void)stop{
    NSLog(@"stop");
    [self.resourceLoader stopLoading];
    
    if (self.status == MusicStatusPause) {
        [self.player pause];
        return;
    }
    if (self.status != MusicStatusFinish) {
        [self removePlayerItemListener]; //移除监听
        self.status = MusicStatusFinish;
    }
    [self.player pause];
    //播放进度
    if ([self.delegate respondsToSelector:@selector(musicPlayerPlayingProgress:)]) {
        [self.delegate musicPlayerPlayingProgress:0.0];
    }
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicStop object:nil];
    if(self.songsModelArray.count == 0)
        return;
    [self.player seekToTime:CMTimeMake(0.0, 1.0)];
}
//下一首
-(void)next{
    NSLog(@"next");
    if(self.songsModelArray.count==0 ) return;//|| self.songsModelArray.count==1
    [self.resourceLoader stopLoading];
    self.currentIndex++;
    if(self.currentIndex >= self.songsModelArray.count-1){
        self.currentIndex = 0;
    }
    switch (self.playModel) {
        case MusicPlayModelRandom:
            //随机播放
            self.currentSongModel = self.randomSongsModelArray[self.currentIndex];
            break;
        default:
            self.currentSongModel = self.songsModelArray[self.currentIndex];
            break;
    }
    [self setupPlayer];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicNext object:nil];
}
//上一首
-(void)last{
    NSLog(@"last");
    if(!self.songsModelArray.count || self.songsModelArray.count==1) return;
    [self.resourceLoader stopLoading];
    self.currentIndex--;
    if(self.currentIndex < 0){
        self.currentIndex = self.songsModelArray.count-1;
    }
    switch (self.playModel) {
        case MusicPlayModelRandom:
            //随机播放
            self.currentSongModel = self.randomSongsModelArray[self.currentIndex];
            break;
        default:
            self.currentSongModel = self.songsModelArray[self.currentIndex];
            break;
    }
    [self setupPlayer];
    [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicNext object:nil];
}

#pragma mark - 跳转音乐进度
- (void)seekToTimeBegin{
//    NSLog(@"seekToTimeBegin");
    self.isSeeking = YES;
}
 
- (void)seekToTimeEndWithProgress:(CGFloat)progress completionHandler:(void (^)(void))completionHandler {
    if(!self.songsModelArray.count) return;
//    NSLog(@"seekToTimeEndWithProgress");
    __weak typeof(self)weakSelf = self;
    self.resourceLoader.seekRequired = YES;
    CMTime changedTime = CMTimeMake(self.durationTime * progress, 1.0);
    [self.player seekToTime:changedTime completionHandler:^(BOOL finished) {
        if (finished) {
            weakSelf.isSeeking = NO;
            if (completionHandler) completionHandler();
        }
    }];
}

#pragma mark - LoaderDelegate
- (void)loader:(LyMusicResourceLoader *)loader cacheProgress:(CGFloat)progress{
    NSLog(@"loader 缓存进度  %f",progress);
}
-(void)loader:(LyMusicResourceLoader *)loader failLoadingWithError:(NSError *)error{
    NSLog(@"loader 加载失败");
}

#pragma mark - 通知
-(void)addPlayerListener{
    //    NSLog(@"addPlayerListener");
    __weak typeof(self)weakSelf = self;
    // 添加视频播放结束通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerToEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    // 添加异常中断通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStalled:)
                                                 name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
    // 进入后台，一些耗性能的动作要暂停
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBcakground)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];
    // 返回前台，恢复需要的动作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeForeground)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.playTimeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(3, 4) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        // MARK: 当正在拖动滑块，修改播放时间的时候，就不需要自动更新了
        if (!weakSelf.isSeeking && weakSelf.status==MusicStatusPlaying) {
            // MARK: 播放进度
            weakSelf.currentTime = CMTimeGetSeconds(time);
            CGFloat progress = weakSelf.currentTime / weakSelf.durationTime;
            if ([weakSelf.delegate respondsToSelector:@selector(musicPlayerPlayingProgress:)]) {
                [weakSelf.delegate musicPlayerPlayingProgress:progress];
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicProgress object:[NSNumber numberWithFloat:progress]];
            
            if (weakSelf.currentSongModel.lyrics.count > 0) {
                [weakSelf updateTheCurrentLyricIndex];
            }else{
//                [weakSelf.lockscreenControl updateLockScreenWithDurationTime:weakSelf.durationTime CurrentTime:weakSelf.currentTime];
//                weakSelf.lockscreenControl.currectLyricIndex = -1;
            }
        }
    }];
}

-(void)removePlayerListener{
    //    NSLog(@"removePlayerListener");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemTimeJumpedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player removeTimeObserver:_playTimeObserver];
}

-(void)addPlayerItemListener{
    //    NSLog(@"addPlayerItemListener");
    AVPlayerItem *playerItem = self.player.currentItem;
    [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    [self.player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removePlayerItemListener {
    //    NSLog(@"removePlayerItemListener");
    AVPlayerItem *playerItem = self.player.currentItem;
    id info = playerItem.observationInfo;
    NSArray *array = [info valueForKey:@"_observances"];
    for (id objc in array) {
        id Properties = [objc valueForKeyPath:@"_property"];
        id newObserver = [objc valueForKeyPath:@"_observer"];
        
        NSString *keyPath = [Properties valueForKeyPath:@"_keyPath"];
        if ([@"status"isEqualToString:keyPath] && [newObserver isEqual:self]) {
            [playerItem removeObserver:self forKeyPath:@"status"];
        }
        if ([@"loadedTimeRanges"isEqualToString:keyPath] && [newObserver isEqual:self]) {
            [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        }
        if ([@"rate"isEqualToString:keyPath] && [newObserver isEqual:self]) {
            [playerItem removeObserver:self forKeyPath:@"rate"];
        }
    }
//    if (playerItem.observationInfo != nil) {
//        [playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
//        [self.player removeObserver:self forKeyPath:@"rate"];
//    }
}

#pragma mark - kvo处理
//监听事件
- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = self.player.currentItem.status;
        switch (status) {
            case AVPlayerStatusUnknown:{
                NSLog(@"KVO：未知状态，此时不能播放");
                self.status = MusicStatusPause;
                [self.player pause];
            }
                break;
            case AVPlayerStatusReadyToPlay:{
                NSLog(@"KVO：准备完毕，可以播放");
//                self.status = MusicStatusReadyToPlay;
//                [self play];
                return;
            }
                break;
            case AVPlayerStatusFailed:{
                NSLog(@"KVO：加载失败，网络或者服务器出现问题");
                [self.player.currentItem cancelPendingSeeks];
                [self pause];
                return;
            }
                break;
            default:
                break;
        }
    }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSLog(@"loadedTimeRanges");
        //缓存进度
        if ([self.delegate respondsToSelector:@selector(musicPlayerCacheProgress:)]) {
//            NSTimeInterval timeInterval = [self availableDuration];
//            CMTime  duration = self.player.currentItem.duration;
//            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [self.delegate musicPlayerCacheProgress:([self availableDuration] / self.durationTime)];
        }
    }else if ([keyPath isEqualToString:@"rate"]) {
        if (self.player.rate == 0.0) {
            _status = MusicStatusPause;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicPause object:nil];
        }else {
            _status = MusicStatusPlaying;
            [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_MusicPlay object:nil];
        }
    } else {
        NSLog(@"其他问题");
    }
}

#pragma mark - 结束
- (void)playerToEnd:(NSNotification *)notification {
    NSLog(@"kvoplayerToEnd");
    switch (self.playModel) {
        case MusicPlayModelRandom:
            break;
        case MusicPlayModelNormal:
            break;
        case MusicPlayModelSingleCycle://单曲循环
            [self setupPlayer];
//            [self.player replaceCurrentItemWithPlayerItem:self.player.currentItem];
            return;
            break;
        case MusicPlayModelCycle://全部循环
            if (self.songsModelArray.count==1) {
                [self setupPlayer];
            }else{
               [self next];
            }
            break;
        default:
            break;
    }
    if(self.currentIndex < self.songsModelArray.count-1){
        [self next];
    }else{
        NSLog(@"playerToEnd %@",NSStringFromSelector(_cmd));
        self.status = MusicStatusFinish;
        [self removePlayerItemListener]; //移除监听
        [self stop];
        //播放结束
        if ([self.delegate respondsToSelector:@selector(musicPlayerEndPlay)]) {
            [self.delegate musicPlayerEndPlay];
        }
    }
}

#pragma mark - 异常中断通知
- (void)playerStalled:(NSNotification *)notification {
    NSLog(@"异常中断通知 playerStalled");
    [self next];
}

#pragma mark - 前后台切换
// 进入后台
- (void)enterBcakground {
//    NSLog(@"enterBcakground %@",NSStringFromSelector(_cmd));
    _enterBcakground = YES;
}

// 返回前台
- (void)becomeForeground {
//    NSLog(@"becomeForeground %@",NSStringFromSelector(_cmd));
    _enterBcakground = NO;
}

#pragma mark -  更新歌词显示
- (void)updateTheCurrentLyricIndex{
    if ([self.delegate respondsToSelector:@selector(musicPlayerLyricIndex:)]) {
        static NSInteger currectLyricIndex = 0;
        for (LyMusicPlayerLyricModel *model in self.currentSongModel.lyrics) {
            if(self.currentTime >= model.beginTime - 0.28) {// 提前0.28s
                currectLyricIndex = [self.currentSongModel.lyrics indexOfObject:model];
            }else
                break;
        }
        if (currectLyricIndex == self.lockscreenControl.currectLyricIndex) {
            return;// 避免过分调用
        }
        self.lockscreenControl.currectLyricIndex = currectLyricIndex;
        [self.delegate musicPlayerLyricIndex:(self.lockscreenControl.currectLyricIndex)];
        
        if(_enterBcakground == NO){
            [self.lockscreenControl updateLockScreenWithDurationTime:self.durationTime CurrentTime:self.currentTime];
        }
        //发送通知
        [[NSNotificationCenter defaultCenter]postNotificationName:kNotification_LyricCurrentIndex object:[NSNumber numberWithInteger:currectLyricIndex]];
    }
}
#pragma mark  计算缓存
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}

#pragma mark - 时间格式转换
- (NSString *)formatTime:(NSTimeInterval)duration {
    if (duration <= 0 || isnan(duration)) {
        return @"00:00";
    }
    NSInteger minute = (int)duration / 60;
    NSInteger second = (int)duration % 60;
    return [NSString stringWithFormat:@"%.02ld:%.02ld", (long)minute, (long)second];
}

#pragma mark - 为数组随机排序
- (NSArray *)randomArray:(NSArray *)array {
    NSLog(@"randomArray");
    NSArray *randomArray = [array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        int seed = arc4random_uniform(2);   // 生成0～(2-1)的随机数
        if (seed) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    return randomArray;
}

#pragma mark - 总时间
- (NSTimeInterval)durationTime {
    if (CMTimeGetSeconds(self.player.currentItem.duration) < 0.0) {
        return 0.0;
    }
    return CMTimeGetSeconds(self.player.currentItem.duration);
}

#pragma mark - 设置播放状态，会调用代理
- (void)setStatus:(MusicStatus)status {
//    NSLog(@"setStatus");
    if (_status == status) {
        return;// 避免过分调用
    }
    _status = status;
    if ([self.delegate respondsToSelector:@selector(musicPlayerStatusChange:)]) {
        [self.delegate musicPlayerStatusChange:status];
    }
}
#pragma mark - 懒加载
-(LyMusicLockScreenControl *)lockscreenControl{
    if(_lockscreenControl == nil){
        _lockscreenControl = [[LyMusicLockScreenControl alloc]init];
        _lockscreenControl.currectLyricIndex = 0;
        _lockscreenControl.currentSongModel = self.currentSongModel;
    }
    return _lockscreenControl;
}

-(NSMutableArray *)randomSongsModelArray{
    if (_randomSongsModelArray == nil) {
        _randomSongsModelArray = [NSMutableArray arrayWithArray:[self randomArray:self.songsModelArray]];
    }
    return _randomSongsModelArray;
}

-(LyMusicPlayerViewController *)musicPlayerController{
    if(_musicPlayerController == nil){
        _musicPlayerController = [[LyMusicPlayerViewController alloc]init];
    }
    return _musicPlayerController;
}

@end
