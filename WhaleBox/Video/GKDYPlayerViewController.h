//
//  GKDYPlayerViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoModel.h"
#import <JXCategoryView/JXCategoryView.h>
#import "GKDYVideoScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYPlayerViewController;

@protocol GKDYPlayerViewControllerDelegate <NSObject>

@optional;

- (void)playerVCDidClickShoot:(GKDYPlayerViewController *)playerVC;

//- (void)playerVC:(GKDYPlayerViewController *)playerVC controlView:(GKDYVideoControlView *)controlView isCritical:(BOOL)isCritical;

- (void)playerVC:(GKDYPlayerViewController *)playerVC didDragDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

- (void)playerVC:(GKDYPlayerViewController *)playerVC cellZoomBegan:(GKDYVideoModel *)model;

- (void)playerVC:(GKDYPlayerViewController *)playerVC cellZoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen;

@end

@interface GKDYPlayerViewController : UIViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<GKDYPlayerViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *tab;

@property (nonatomic, strong) GKDYVideoModel *model;

- (void)prepareModels:(NSArray <GKDYVideoModel *>*)models atIndex:(NSInteger)index;


- (void)refreshData:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
