//
//  SYBasePopView.m
//  Premoment
//
//  Created by 刘思源 on 2021/1/13.
//

#import "SYBasePopView.h"
#import <YYKit/YYKit.h>
#import "UIView+VisualHelper.h"

//[(CALayer *)[[[[UIApplication sharedApplication] windows] objectAtIndex:0] layer] setSpeed:1.f];

@interface SYBasePopView()

@property (nonatomic, strong) UIView *maskView;

/** 是否正在动画 */
@property (nonatomic, assign) BOOL isAnimating;

@property (nonatomic, assign) CGFloat centerYConstraintValue;




@end


@implementation SYBasePopView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.translatesAutoresizingMaskIntoConstraints = NO;
        _animDuration = .4f;
        _dismissDuration = .3f;
        _maskAlpha = .3f;
        _bounce = YES;
        _popDiretion = SYPopDirectionFromCenter;
        _touchToDismiss = NO;
        _indicatorEnable = NO;
    }
    return self;
}

- (void)addInitalConstraints{
    if (_popDiretion == SYPopDirectionFromCenter) {
        // 使用自动布局实现居中对齐
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
        

        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                          constant:0]];
        
        
    }else if(_popDiretion == SYPopDirectionFromBottom){
        //这里用center来做约束是为了方便dismissToView中约束更新.
        CGSize size = [self systemLayoutSizeFittingSize:self.superview.size];
        self.centerYConstraintValue = self.superview.size.height/2 + size.height/2;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:self.centerYConstraintValue]];
    }else{
        NSAssert(NO, @"not implemented this direction");
    }
    
}

- (void)applyAnimationWithCompletedHandler:(void(^)(void))completedHandler{
    if (_popDiretion == SYPopDirectionFromCenter) {
        self.alpha = 0;
        [UIView animateWithDuration:_animDuration animations:^{
            self.alpha = 1;
        } completion:^(BOOL finished) {
            !completedHandler?:completedHandler();
        }];
    }else if(_popDiretion == SYPopDirectionFromBottom){
        CGSize size = [self systemLayoutSizeFittingSize:self.superview.size];
        self.centerYConstraintValue = self.superview.size.height/2 - size.height/2;
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:self.centerYConstraintValue]];
        [UIView animateWithDuration:_animDuration animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            !completedHandler?:completedHandler();
        }];
    }
    
}

- (void)showInView:(UIView *)view{
    [self showInView:view completed:nil];
}


- (void)showInView:(UIView *)view completed:(void(^)(void))completedHandler{
    [view addSubview:self];
    [self addMaskView];
    [self addInitalConstraints];
    [self addSliderIfNeeded];
    [self.superview layoutIfNeeded];
    [self applyAnimationWithCompletedHandler:completedHandler];
}

- (void)addSliderIfNeeded{
    if(_popDiretion == SYPopDirectionFromBottom && _indicatorEnable){
        UIView *sliderBar = [UIView new];
        [self addSubview:sliderBar];
        // 距离顶部 10 点
        [self addConstraint:[NSLayoutConstraint constraintWithItem:sliderBar
                                                              attribute:NSLayoutAttributeTop
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeTop
                                                             multiplier:1
                                                               constant:10]];

        // 水平方向上居中对齐
        [self addConstraint:[NSLayoutConstraint constraintWithItem:sliderBar
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1
                                                               constant:0]];

        // 设置视图宽度为 230
        [self addConstraint:[NSLayoutConstraint constraintWithItem:sliderBar
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:230]];
        
     
        [self addConstraint:[NSLayoutConstraint constraintWithItem:sliderBar
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1
                                                               constant:4]];

        sliderBar.sy_touchAreaInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        sliderBar.backgroundColor = UIColor.whiteColor;
        sliderBar.layer.cornerRadius = 2;
        sliderBar.clipsToBounds = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSliderPan:)];
        [sliderBar addGestureRecognizer:pan];
    }
    
}

- (void)handleSliderPan:(UIPanGestureRecognizer *)pan{
    CGPoint translate = [pan translationInView:self];
    if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
        if (self.centerYConstraintValue + translate.y > self.superview.size.height/2 - self.size.height/2 && self.centerYConstraintValue + translate.y < self.superview.size.height/2 + self.size.height/2) {
            self.centerYConstraintValue = self.centerYConstraintValue + translate.y;
        }
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.superview
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1
                                                               constant:self.centerYConstraintValue]];
        [self layoutIfNeeded];
    }else {//end cancel...
        CGFloat ratio = (self.centerYConstraintValue - (self.superview.size.height/2 - self.height/2))/self.size.height;
        NSLog(@"~~ drop at ratio %.2f",ratio);
        if (ratio > .3) {
            [self dismissWithAnimDuration:(1 -ratio) * self.animDuration userTouch:YES];
        }else{
            [self applyAnimationWithCompletedHandler:^{
                
            }];
        }
    }
    [pan setTranslation:CGPointZero inView:self];
}

- (void)addMaskView{
    _maskView = [UIView new];
    [self.superview insertSubview:_maskView belowSubview:self];
    // 四周都与父视图对齐
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_maskView)]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_maskView)]];
//    [_maskView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_offset(0);
//    }];
    _maskView.backgroundColor = [UIColor blackColor];
    _maskView.alpha = _maskAlpha;
    if (_touchToDismiss) {
        @weakify(self)
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(id  _Nonnull sender) {
            @strongify(self)
            [self dismissWithAnimDuration:self.animDuration userTouch:YES];
        }];
        [_maskView addGestureRecognizer:tap];
    }
}


- (void)dismissToView:(UIView *)view{
    if (!self.superview || _isAnimating) {
        return;
    }
    _isAnimating = YES;
    CGRect rect = [view.superview convertRect:view.frame toView:self.superview];
    CGFloat scaleX = view.width/self.width;
    CGFloat scaleY = view.height/self.height;
    CGPoint offset = CGPointMake(CGRectGetCenter(rect).x - self.superview.centerX,  CGRectGetCenter(rect).y - self.superview.centerY);
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.superview
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:1
                                                           constant:0]];
    

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                          attribute:NSLayoutAttributeCenterY
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.superview
                                                          attribute:NSLayoutAttributeCenterY
                                                            multiplier:1
                                                      constant:0]];
    [UIView animateWithDuration:_dismissDuration animations:^{
        [self.superview layoutIfNeeded];
        self.transform = CGAffineTransformMakeScale(scaleX, scaleY);
        self.alpha = 0.5;
    } completion:^(BOOL finished) {
        [self resetView];
        !self.dismissHandler?:self.dismissHandler(NO);

    }];
}

    
- (void)dismiss{
    [self dismissWithAnimDuration:_animDuration userTouch:NO];
}

- (void)dismissWithAnimDuration:(CGFloat)animDuration userTouch:(BOOL)userTouch{
    if (!self.superview || _isAnimating) {
        return;
    }
    _isAnimating = YES;
    if (_popDiretion == SYPopDirectionFromCenter) {
        [UIView animateWithDuration:animDuration animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self resetView];
            !self.dismissHandler?:self.dismissHandler(userTouch);
        }];
    }else if(_popDiretion == SYPopDirectionFromBottom){
        [self addInitalConstraints];
        [UIView animateWithDuration:animDuration animations:^{
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self resetView];
            !self.dismissHandler?:self.dismissHandler(userTouch);
        }];
    }
}

- (void)resetView{
    self.isAnimating = NO;
    self.alpha = 1;
    self.transform = CGAffineTransformIdentity;
    [self removeFromSuperview];
    [self.maskView removeFromSuperview];
}

- (void)show{
    [self showInView:[UIApplication sharedApplication].keyWindow];
}


@end
