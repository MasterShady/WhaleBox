//
//  UIView+CornerHelper.m
//  timingapp
//
//  Created by 刘思源 on 2020/9/8.
//  Copyright © 2020 huiian. All rights reserved.
//

#import "UIView+VisualHelper.h"
#import <objc/runtime.h>

@implementation UIView (VisualHelper)

static void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

+ (void)load {
    Swizzle(self, @selector(pointInside:withEvent:), @selector(myPointInside:withEvent:));
}


- (CALayer *)sy_borderLayer{
    return objc_getAssociatedObject(self,@selector(sy_borderLayer));
}

- (void)setSy_borderLayer:(CALayer *)layer{
    objc_setAssociatedObject(self, @selector(sy_borderLayer), layer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


-(UIEdgeInsets)sy_touchAreaInsets
{
   return [objc_getAssociatedObject(self, @selector(sy_touchAreaInsets)) UIEdgeInsetsValue];
}

- (void)setSy_touchAreaInsets:(UIEdgeInsets)touchAreaInsets
{
   NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
   objc_setAssociatedObject(self, @selector(sy_touchAreaInsets), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)myPointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.sy_touchAreaInsets, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:UIControl.class] && !((UIControl *)self).enabled)) {
        return [self myPointInside:point withEvent:event]; // original implementation
    }
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - self.sy_touchAreaInsets.left,
                        bounds.origin.y - self.sy_touchAreaInsets.top,
                        bounds.size.width + self.sy_touchAreaInsets.left + self.sy_touchAreaInsets.right,
                        bounds.size.height + self.sy_touchAreaInsets.top + self.sy_touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}


- (void)addCornerRectWith:(UIRectCorner)rectCorner radius:(CGFloat)radius{
    UIBezierPath *maskPath  = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame         = self.bounds;
    maskLayer.path          = maskPath.CGPath;
    self.layer.mask         = maskLayer;
}

-(void)addBorderWithColor:(UIColor *)color width:(CGFloat)borderWidth borderType:(UIBorderSideType)borderType{
    
    if (borderType == UIBorderSideTypeAll) {
        self.layer.borderWidth = borderWidth;
        self.layer.borderColor = color.CGColor;
    }
    
    /// 线的路径
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    
    /// 左侧
    if (borderType & UIBorderSideTypeLeft) {
        /// 左侧线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, self.frame.size.height)];
        [bezierPath addLineToPoint:CGPointMake(0.0f, 0.0f)];
    }
    /// 右侧
    if (borderType & UIBorderSideTypeRight) {
        /// 右侧线路径
        [bezierPath moveToPoint:CGPointMake(self.frame.size.width, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake( self.frame.size.width, self.frame.size.height)];
    }
    
    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake(self.frame.size.width, 0.0f)];
    }
    
    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, self.frame.size.height)];
        [bezierPath addLineToPoint:CGPointMake( self.frame.size.width, self.frame.size.height)];
    }
    
    if(self.sy_borderLayer){
        [self.sy_borderLayer removeFromSuperlayer];
    }
    
    CAShapeLayer * shapeLayer = [CAShapeLayer layer];
    self.sy_borderLayer = shapeLayer;
    shapeLayer.strokeColor = color.CGColor;
    shapeLayer.fillColor  = [UIColor clearColor].CGColor;
    /// 添加路径
    shapeLayer.path = bezierPath.CGPath;
    /// 线宽度
    shapeLayer.lineWidth = borderWidth;
    [self.layer addSublayer:shapeLayer];
    
}


- (CAShapeLayer *)addDashLineWithColor:(UIColor *)color width:(CGFloat)borderWidth lineDashPattern:(NSArray *)dashPattern cornerRadius:(CGFloat)radius{
    CAShapeLayer *border = [CAShapeLayer layer];
    //虚线的颜色
    border.strokeColor = color.CGColor;
    //填充的颜色
    border.fillColor = [UIColor clearColor].CGColor;
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:radius];
    //设置路径
    border.path = path.CGPath;
    border.frame = self.bounds;
    //虚线的宽度
    border.lineWidth = borderWidth;
    //设置线条的样式
    // border.lineCap = @"square";
    //虚线的间隔
    border.lineDashPattern = dashPattern;
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:border];
    return border;
}

- (void)addDashLineWithColor:(UIColor *)color width:(CGFloat)borderWidth lineDashPattern:(NSArray *)dashPattern cornerRadius:(CGFloat)radius borderType:(UIBorderSideType)borderType{
    if (borderType == UIBorderSideTypeAll) {
        //        self.layer.borderWidth = borderWidth;
        //        self.layer.borderColor = color.CGColor;
    }
    
    /// 线的路径
    UIBezierPath * bezierPath = [UIBezierPath bezierPath];
    
    /// 左侧
    if (borderType & UIBorderSideTypeLeft) {
        /// 左侧线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, self.bounds.size.height)];
        [bezierPath addLineToPoint:CGPointMake(0.0f, 0.0f)];
    }
    /// 右侧
    if (borderType & UIBorderSideTypeRight) {
        /// 右侧线路径
        [bezierPath moveToPoint:CGPointMake(self.bounds.size.width, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake( self.bounds.size.width, self.bounds.size.height)];
    }
    
    /// top
    if (borderType & UIBorderSideTypeTop) {
        /// top线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, 0.0f)];
        [bezierPath addLineToPoint:CGPointMake(self.bounds.size.width, 0.0f)];
    }
    
    /// bottom
    if (borderType & UIBorderSideTypeBottom) {
        /// bottom线路径
        [bezierPath moveToPoint:CGPointMake(0.0f, self.bounds.size.height)];
        [bezierPath addLineToPoint:CGPointMake( self.bounds.size.width, self.bounds.size.height)];
    }
    if (self.sy_borderLayer){
        [self.sy_borderLayer removeFromSuperlayer];
    }
    
    CAShapeLayer *border = [CAShapeLayer layer];
    self.sy_borderLayer = border;
    
    //虚线的颜色
    border.strokeColor = color.CGColor;
    //填充的颜色
    border.fillColor = [UIColor clearColor].CGColor;
    
    //设置路径
    border.path = bezierPath.CGPath;
    border.frame = self.bounds;
    //虚线的宽度
    border.lineWidth = borderWidth;
    //设置线条的样式
    // border.lineCap = @"square";
    //虚线的间隔
    border.lineDashPattern = dashPattern;
    self.layer.cornerRadius = radius;
    self.layer.masksToBounds = YES;
    [self.layer addSublayer:border];
}


@end
