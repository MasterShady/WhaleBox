//
//  ArtPopTool.m
//  artapp
//
//  Created by 刘思源 on 17/8/7.
//  Copyright © 2017年 SJWL. All rights reserved.
//

#import "SYPopTool.h"
#import "Aspects.h"
#import <YYKit/YYKit.h>




static const NSInteger windowLevel = 999;


@interface SYPopTool ()<UIGestureRecognizerDelegate>


/** <#注释#> */
@property (nonatomic, assign) ArtPopDirection popDirection;

/** <#注释#> */
@property (nonatomic, weak) UIView *popView;

/** <#注释#> */
@property (nonatomic, strong) UITapGestureRecognizer *tap;





@end


@implementation SYPopTool

@synthesize popWindow = _popWindow;

kSingletonM

- (instancetype)init{
    if (self = [super init]) {
        self.animationDuration = 0.21;
        self.maskAlpha = 0.4;
        self.touchToDismiss = YES;
        self.popViewIsShow = NO;
    }
    return self;
}


-(void)dismiss{
    [self dismissCompleted:_dismissBlock];
}

- (void)dismissCompleted:(void (^)(void))dismissCompleted{
    _dismissBlock = dismissCompleted;
    _popViewIsShow = NO;
    void(^endPosition)(void);
    switch (self.popDirection) {
        case ArtPopDirectionFromBottom:
        {
            endPosition = ^{
                self.popView.center = CGPointMake(_popWindow.size.width/2, _popWindow.height + self.popView.height/2);
            };

        }
            break;
            
        case ArtPopDirectionFromCenter:{
            endPosition =^{
                self.popView.alpha = 0;
            };
        }
            break;
        case ArtPopDirectionFromRight:{
            endPosition = ^{self.popView.center = CGPointMake(_popWindow.size.width - self.popView.width/2, _popWindow.height/2);
                
            };
        }
            break;
        case ArtPopDirectionFromTop:{
            endPosition = ^{
                _popView.center = CGPointMake(_popWindow.size.width/2, -_popView.height/2);
            };
        }
            break;
        default:
            break;
    }
    [UIView animateWithDuration:self.animationDuration animations:^{
        endPosition();
    }completion:^(BOOL finished) {
        self.popView.alpha = 1;
        [self.popView removeFromSuperview];
        self.popView = nil;
        self.popWindow.hidden = YES;
        if (self.popWindow.superview) {
            [self.popWindow removeFromSuperview];
        }
        self.popWindow = nil;
        !dismissCompleted?:dismissCompleted();
        self.dismissBlock = nil;
    }];
}

- (void)popViewFromBottom:(UIView *)view{
    [self popView:view direction:ArtPopDirectionFromBottom completedBlock:nil];
}

- (void)popView:(UIView *)view direction:(ArtPopDirection)direction completedBlock:(void (^)(void))popCompleted{
    //一个奇怪的bug window上面保留了原来的视图.
    if (self.popView) {
        [self.popView removeFromSuperview];
        self.popView = nil;
        return;
    }
    
    self.popWindow.hidden = NO;
    self.popDirection = direction;
    self.popView = view;
    
    //view可能是frameLayout 或 autoLayout 如果是autoLayout这个东西的frame现在是cgrectzero
    //self.popView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.popWindow addSubview:view];
    [self.popWindow layoutIfNeeded];
    [self adjustSubViewsFrame];
    _popViewIsShow = YES;
    switch (direction) {
        case ArtPopDirectionFromBottom:{
            [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.center = CGPointMake(self.popWindow.size.width/2, self.popWindow.height - view.height/2);
            } completion:^(BOOL finished) {
                !popCompleted?:popCompleted();
            }];
        }
            break;
        case ArtPopDirectionFromCenter:{
            self.popView.alpha = 0;
            [UIView animateWithDuration:self.animationDuration animations:^{
                self.popView.alpha = 1;
            } completion:^(BOOL finished) {
                !popCompleted?:popCompleted();
            }];
        }
            break;
        case ArtPopDirectionFromRight:{
            [UIView animateWithDuration:self.animationDuration animations:^{
                view.center = CGPointMake(_popWindow.size.width - view.width/2, _popWindow.height/2);
            } completion:^(BOOL finished) {
                !popCompleted?:popCompleted();
            }];
        }
            break;
        case ArtPopDirectionFromTop:{
            [UIView animateWithDuration:self.animationDuration animations:^{
                view.center = CGPointMake(_popWindow.size.width/2, view.height/2);
            } completion:^(BOOL finished) {
                !popCompleted?:popCompleted();
            }];
        }
            break;
        default:
            
            break;
    }
    
};


- (void)popView:(UIView *)view fromView:(UIView *)fromView direction:(ArtPopDirection)direction completedBlock:(void (^)(void))popCompleted{
    UIView *maskView = [UIView new];
    maskView.frame = fromView.bounds;
    [fromView addSubview:maskView];
    self.popWindow = maskView;
    [self popView:view direction:direction completedBlock:popCompleted];
}




- (void)popView:(UIView *)view maskViewHeirarchyConfig:(void(^)(UIView *maskView))config direction:(ArtPopDirection)direction completedBlock:(void (^)(void))popCompleted{
    UIView *maskView = [UIView new];
    config(maskView);
    self.popWindow = maskView;
    [self popView:view direction:direction completedBlock:popCompleted];
}

-(void)setMaskAlpha:(CGFloat)maskAlpha{
    _maskAlpha = maskAlpha;
    self.popWindow.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:maskAlpha];
}

- (void)setTouchToDismiss:(BOOL)touchToDismiss{
    _touchToDismiss = touchToDismiss;
    self.tap.enabled = touchToDismiss;
}


- (UITapGestureRecognizer *)tap{
    @weakify(self)
    _tap = [[UITapGestureRecognizer alloc] initWithActionBlock:^(UITapGestureRecognizer *_Nonnull sender) {
        @strongify(self)
        [self dismissCompleted:self.dismissBlock];
    }];
    _tap.delegate = self;
    return _tap;
}


- (void)adjustSubViewsFrame{
    switch (_popDirection) {
        case ArtPopDirectionFromBottom:
        {
            if (_popViewIsShow) {
                _popView.center = CGPointMake(_popWindow.width/2, _popWindow.height - _popView.height/2);
            }else{
                 _popView.center = CGPointMake(_popWindow.size.width/2, _popWindow.height + _popView.height/2);
            }
        }
            break;
        case ArtPopDirectionFromCenter:
        {
            _popView.center = CGPointMake(_popWindow.size.width/2, _popWindow.height/2);
        }
            break;
        case ArtPopDirectionFromRight:{
            if (_popViewIsShow) {
                _popView.center = CGPointMake(_popWindow.size.width - _popView.width/2, _popWindow.height/2);
            }else{
                _popView.center = CGPointMake(_popWindow.size.width + _popView.width/2, _popWindow.height/2);
            }
        }
            break;
        case ArtPopDirectionFromTop:{
            if (_popViewIsShow) {
                _popView.center = CGPointMake(_popWindow.size.width/2, _popView.height/2);
            }else{
                
                _popView.center = CGPointMake(_popWindow.size.width/2, -_popView.height/2);
            }
        }
        default:
            break;
    }
}

- (UIView *)popWindow{
    if(!_popWindow){
        UIWindow *popWindow = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
        
        popWindow.windowLevel = windowLevel;
        popWindow.hidden = YES;
        popWindow.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:_maskAlpha];
        [popWindow addGestureRecognizer:self.tap];
        @weakify(self)
        [popWindow aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionAfter usingBlock:^{
            @strongify(self)
            [self adjustSubViewsFrame];
        } error:nil];
        _popWindow = popWindow;
    }
    return _popWindow;
}

-(void)setPopWindow:(UIView *)popWindow{
    _popWindow = popWindow;
    popWindow.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:_maskAlpha];
    [popWindow addGestureRecognizer:self.tap];
    @weakify(self)
    [popWindow aspect_hookSelector:@selector(layoutSubviews) withOptions:AspectPositionAfter usingBlock:^{
        @strongify(self)
        [self adjustSubViewsFrame];
    } error:nil];
}


#pragma mark - gesture recognize delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view == self.popWindow) {
        return YES;
    }
    return NO;
}



@end
