//
//  SYBasePopView.h
//  Premoment
//
//  Created by 刘思源 on 2021/1/13.
//

#import <UIKit/UIKit.h>
#import "SYPopTool.h"


typedef enum : NSUInteger {
    SYPopDirectionFromCenter,
    SYPopDirectionFromTop,
    SYPopDirectionFromBottom,
    SYPopDirectionFromLeft,
    SYPopDirectionFromRight,
} SYPopDirection;

@interface SYBasePopView : UIView

/** 动画时长  defaults to .4 */
@property (nonatomic, assign) CGFloat animDuration;

/** dimsiss动画时长 defaults to .3 */
@property (nonatomic, assign) CGFloat dismissDuration;

/** 是否回弹  only works for SYPopDirectionFromCenter defaults to YES */
@property (nonatomic, assign) BOOL bounce;

/** 弹窗方向 defaults to SYPopDirectionFromCenter*/
@property (nonatomic, assign) SYPopDirection popDiretion;

/** 遮罩不透明度  defaults to .3 */
@property (nonatomic, assign) CGFloat maskAlpha;


/** 是否显示拖动条, 目前仅在 SYPopDirectionFromBottom 时生效 默认 NO*/
@property (nonatomic, assign) BOOL indicatorEnable;

/** defaults to NO */
@property (nonatomic, assign) BOOL touchToDismiss;

@property (nonatomic, strong) void (^dismissHandler)(BOOL isTouch);

- (void)showInView:(UIView *)view completed:(void(^)(void))completedHandler;

- (void)showInView:(UIView *)view;

- (void)show;

- (void)dismissToView:(UIView *)view;

- (void)dismiss;


@end


