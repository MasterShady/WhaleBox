//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPlayerViewController.h"
//#import "GKDYUserViewController.h"
//#import "GKSlidePopupView.h"
//#import "GKDYCommentView.h"
#import "GKBallLoadingView.h"
//#import "GKLikeView.h"
#import "GKDYVideoScrollView.h"
#import "GKDYVideoCell.h"
#import "GKDYPlayerManager.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"
#import "WhaleBox-Swift.h"

@interface GKDYPlayerViewController ()<GKDYPlayerManagerDelegate>

@property (nonatomic, strong) GKDYPlayerManager     *manager;

@property (nonatomic, strong) NSArray <GKDYVideoModel *>*prepareModels;

//@property (nonatomic, assign) NSInteger page;

@end

@implementation GKDYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
}

- (void)dealloc {
    
    NSLog(@"playerVC dealloc");
}

- (void)viewWillAppear:(BOOL)animated{
    if (!self.prepareModels || self.prepareModels.count == 0){
        [self.navigationController setNavigationBarHidden:true animated:animated];
    }
    
    self.manager.isAppeared = YES;
    [self.manager play];
}

- (void)viewWillDisappear:(BOOL)animated{
    if (!self.prepareModels || self.prepareModels.count == 0){
        [self.navigationController setNavigationBarHidden:false animated:animated];
    }
    [self.manager pause];
}

- (void)initUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.manager.scrollView];
    
    [self.manager.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupRefresh {
    @weakify(self);
    self.manager.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        self.manager.page++;
        [self requestData:nil];
    }];
}

- (void)requestData {
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.view];
    [loadingView startLoading];
    
    self.manager.page = 1;
    @weakify(loadingView);
    [self requestData:^{
        @strongify(loadingView);
        [loadingView stopLoading];
        [loadingView removeFromSuperview];
    }];
}

- (void)refreshData:(void (^)(void))completion {
    self.manager.page = 1;
    [self requestData:completion];
}

- (void)prepareModels:(NSArray <GKDYVideoModel *>*)models atIndex:(NSInteger)index{
    self.prepareModels = models;
    self.manager.page = index;
}

- (void)requestData:(nullable void (^)(void))completion {
    if (self.prepareModels.count > 0) {
        [self.manager.dataSources addObjectsFromArray:self.prepareModels];
        [self.manager.scrollView.mj_footer endRefreshingWithNoMoreData];
        [self.manager.scrollView reloadData];
        !completion?:completion();
        return;
    }
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 好看视频 num=5，每次请求5条
//    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/video/feed?tab=%@&act=pcFeed&pd=pc&num=%d", self.tab, 5];
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/video/rec?tab=%@&act=pcFeed&pd=pc&num=%d", self.tab, 10];
    
    @weakify(self);
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        if ([responseObject[@"status"] integerValue] == 0) {
            NSArray *videos = responseObject[@"data"][@"response"][@"videos"];
            
            if (self.manager.page == 1) {
                [self.manager.dataSources removeAllObjects];
            }
            
            [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKDYVideoModel *model = [GKDYVideoModel modelWithDictionary:obj];
                [self.manager.dataSources addObject:model];
            }];
            
            [self.manager.scrollView.mj_footer endRefreshing];
            
            if (self.manager.page >= 10) { // 最多10页
                [self.manager.scrollView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.manager.scrollView reloadData];
        }
        !completion ?: completion();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self.manager.scrollView.mj_footer endRefreshing];
        !completion ?: completion();
    }];
}

- (GKDYVideoModel *)model {
    return self.manager.currentCell.model;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear {
    self.manager.isAppeared = YES;
    [self.manager play];
}

- (void)listWillDisappear {
    [self.manager pause];
}

- (void)listDidDisappear {
    self.manager.isAppeared = NO;
}

#pragma mark - GKDYPlayerManagerDelegate
- (void)scrollViewDidPanDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if ([self.delegate respondsToSelector:@selector(playerVC:didDragDistance:isEnd:)]) {
        [self.delegate playerVC:self didDragDistance:distance isEnd:isEnd];
    }
}

- (void)cellDidClickIcon:(GKDYVideoModel *)model {
//    GKDYUserViewController *userVC = [[GKDYUserViewController alloc] init];
//    userVC.model = model;
//    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)cellDidClickComment:(GKDYVideoModel *)model {
    ReportView *reportView = [ReportView new];
    @weakify(self)
    [reportView setDismissHandler:^(BOOL report) {
        @strongify(self)
        if (report){
            [self.manager.dataSources removeObject:model];
            [self.manager.scrollView reloadData];
            [@"感谢您的反馈,我们会对视频进行审核并处理" hint];
        }else{
            
        }
    }];
    [reportView popFromCenterWithMask:true tapToDismiss:false];
    
}

- (void)cellZoomBegan:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(playerVC:cellZoomBegan:)]) {
        [self.delegate playerVC:self cellZoomBegan:model];
    }
}

- (void)cellZoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen {
    if ([self.delegate respondsToSelector:@selector(playerVC:cellZoomEnded:isFullscreen:)]) {
        [self.delegate playerVC:self cellZoomEnded:model isFullscreen:isFullscreen];
    }
}

#pragma mark - 懒加载
- (GKDYPlayerManager *)manager {
    if (!_manager) {
        _manager = [[GKDYPlayerManager alloc] init];
        _manager.delegate = self;
    }
    return _manager;
}

@end
