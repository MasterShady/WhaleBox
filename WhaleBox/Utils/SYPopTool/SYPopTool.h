//
//  ArtPopTool.h
//  artapp
//
//  Created by 刘思源 on 17/8/7.
//  Copyright © 2017年 SJWL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"


#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    ArtPopDirectionFromBottom,
    ArtPopDirectionFromTop,
    ArtPopDirectionFromLeft,
    ArtPopDirectionFromRight,
    ArtPopDirectionFromCenter
} ArtPopDirection;


@interface SYPopTool : NSObject

/** <#注释#> */
@property (nonatomic, strong) UIView *popWindow;
/** <#注释#> */
@property (nonatomic, assign) CGFloat maskAlpha;

/** <#注释#> */
@property (nonatomic, assign) BOOL touchToDismiss;

/** <#注释#> */
@property (nonatomic, assign) CFTimeInterval animationDuration;

/** <#注释#> */
@property (nonatomic, strong) void(^dismissBlock)(void) ;

/** <#注释#> */
@property (nonatomic, assign) BOOL popViewIsShow;



kSingletonH

- (void)popViewFromBottom:(UIView *)view;

- (void)popView:(UIView *)view direction:(ArtPopDirection)direction completedBlock:(void(^)(void))popCompleted;

- (void)popView:(UIView *)view fromView:(UIView *)fromView direction:(ArtPopDirection)direction completedBlock:(void (^)(void))popCompleted;

- (void)popView:(UIView *)view maskViewHeirarchyConfig:(void(^)(UIView *maskView))config direction:(ArtPopDirection)direction completedBlock:(void (^)(void))popCompleted;

- (void)dismiss;

- (void)dismissCompleted:(void(^)(void))dismissCompleted;


@end
