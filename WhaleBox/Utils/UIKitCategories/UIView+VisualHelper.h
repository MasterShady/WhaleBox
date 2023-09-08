//
//  UIView+CornerHelper.h
//  timingapp
//
//  Created by 刘思源 on 2020/9/8.
//  Copyright © 2020 huiian. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (VisualHelper)

///边框类型
typedef NS_ENUM(NSInteger, UIBorderSideType) {
    UIBorderSideTypeAll    = 0,
    UIBorderSideTypeTop    = 1 << 0,
    UIBorderSideTypeBottom = 1 << 1,
    UIBorderSideTypeLeft   = 1 << 2,
    UIBorderSideTypeRight  = 1 << 3,
};

@property (nonatomic, assign) UIEdgeInsets sy_touchAreaInsets;

@property CALayer *sy_borderLayer;

/**
 单边 & 多边圆角
 */
- (void)addCornerRectWith:(UIRectCorner)rectCorner radius:(CGFloat)radius;
/**
单边 & 多边 边框
 */
-(void)addBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType;

//虚线边框
- (CAShapeLayer *)addDashLineWithColor:(UIColor *)color width:(CGFloat)borderWidth lineDashPattern:(NSArray *)dashPattern cornerRadius:(CGFloat)radius;

//单边& 多变虚线边框
- (void)addDashLineWithColor:(UIColor *)color width:(CGFloat)borderWidth lineDashPattern:(NSArray *)dashPattern cornerRadius:(CGFloat)radius borderType:(UIBorderSideType)borderType;



@end

NS_ASSUME_NONNULL_END
