//
//  SPcoreView.m
//  SPPickerView
//
//  Created by Libo on 2018/9/1.
//  Copyright © 2018年 Cookie. All rights reserved.
//

#import "SPModalView.h"

@interface SPModalView ()

@property (nonatomic, strong) UIImageView *shotImageView; // 屏幕截图
@property (nonatomic, strong) UIView *coreView;
@property (strong, nonatomic) UIControl *closeControl;
@property (strong, nonatomic) UIView *contentView;

@property (nonatomic, strong) UIViewController *baseViewController;
@property (nonatomic, strong) UIView *fatherView;

@end
@implementation SPModalView

- (instancetype)initWithView:(UIView *)view inBaseViewController:(UIViewController *)baseViewController {
    if (self = [super init]) {
        
        _coreView = view;
        _baseViewController = baseViewController;
        
        // 如果外界多次对本类alloc，可能会导致外界的控制器上有多个self，这里每次创建新的之前，先移除旧的
        [self removeAllModalView];
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        
        [self addSubview:self.shotImageView];
        [self addSubview:self.closeControl];
        [self addSubview:self.contentView];
        [self.contentView addSubview:view];
        self.contentView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height, view.bounds.size.width, view.bounds.size.height);
        
        [self.fatherView insertSubview:self atIndex:0];
        [self.fatherView sendSubviewToBack:self];
        
    }
    return self;
}

- (void)removeAllModalView {
    NSEnumerator *enumerator = [self.fatherView.subviews reverseObjectEnumerator];
    for (UIView *subView in enumerator) {
        if ([subView isKindOfClass:[SPModalView class]]) {
            [subView removeFromSuperview];
        }
    }
}


+ (UIImage *)snapshotWithWindow {
    @autoreleasepool {
        UIGraphicsBeginImageContextWithOptions([UIApplication sharedApplication].keyWindow.bounds.size, YES, [UIScreen mainScreen].scale);
        [[UIApplication sharedApplication].keyWindow.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

- (void)show {
    if (!self.narrowedOff) {
        CATransform3D t = CATransform3DIdentity;
        t.m34 = -0.004;
        [self.shotImageView.layer setTransform:t];
        self.shotImageView.layer.zPosition = -10000;
        
        self.shotImageView.image = [self.class snapshotWithWindow];
        [self.fatherView bringSubviewToFront:self];
        
        self.closeControl.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.4f animations:^{
            self.shotImageView.alpha = 0.5;
            self.contentView.frame = CGRectMake(0,[[UIScreen mainScreen] bounds].size.height - self.contentView.bounds.size.height,self.contentView.frame.size.width,self.contentView.frame.size.height);
        }];
        [UIView animateWithDuration:0.2f animations:^{
            self.shotImageView.layer.transform = CATransform3DRotate(t, 7/90.0 * M_PI_2, 1, 0, 0);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shotImageView.layer.transform = CATransform3DTranslate(t, 0, -10, -30);
            }];
        }];
    } else {
        self.shotImageView.image = [self.class snapshotWithWindow];
        [self.fatherView bringSubviewToFront:self];
        self.closeControl.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.2f animations:^{
            self.shotImageView.alpha = 0.5;
            self.contentView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height - self.contentView.bounds.size.height,self.contentView.frame.size.width,self.contentView.frame.size.height);
        }];
    }
}

- (void)hide {

    if (!self.narrowedOff) {
        CATransform3D t = CATransform3DIdentity;
        t.m34 = -0.004;
        [self.shotImageView.layer setTransform:t];
        self.closeControl.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.4f animations:^{
            self.shotImageView.alpha = 1;
            self.contentView.frame = CGRectMake(0, self.frame.size.height,self.contentView.frame.size.width,self.contentView.frame.size.height);
        } completion:^(BOOL finished) {
            [self.fatherView sendSubviewToBack:self];
        }];
        [UIView animateWithDuration:0.2f animations:^{
            self.shotImageView.layer.transform = CATransform3DTranslate(t, 0, -10, -30);
            self.shotImageView.layer.transform = CATransform3DRotate(t, 7/90.0 * M_PI_2, 1, 0, 0);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                self.shotImageView.layer.transform = CATransform3DTranslate(t, 0, 0, 0);
            }];
        }];
    } else {
        self.closeControl.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.2f animations:^{
            self.shotImageView.alpha = 1;
            self.contentView.frame = CGRectMake(0,self.frame.size.height,self.contentView.frame.size.width,self.contentView.frame.size.height);
        } completion:^(BOOL finished) {
            [self.fatherView sendSubviewToBack:self];
        }];
    }
}

- (UIView *)fatherView {
    if (self.baseViewController) {
        if (self.baseViewController.navigationController) {
            return self.baseViewController.navigationController.view;
        } else {
            return self.baseViewController.view;
        }
    }
    return nil;
}

- (UIView *)contentView {
    
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.shadowOffset = CGSizeZero;
        _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
        _contentView.layer.shadowRadius = 3;
        _contentView.layer.shadowOpacity = 1;
        _contentView.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(0, -2, self.frame.size.width, 2)].CGPath;
    }
    return _contentView;
}

- (UIControl *)closeControl {
    if (!_closeControl) {
        UIControl *closeControl = [[UIControl alloc] initWithFrame:self.bounds];
        closeControl.userInteractionEnabled = NO;
        closeControl.backgroundColor        = [UIColor clearColor];
        [closeControl addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        self.closeControl = closeControl;
    }
    return _closeControl;
}

- (UIImageView *)shotImageView {
    
    if (!_shotImageView) {
        _shotImageView = [[UIImageView alloc] init];
        _shotImageView.backgroundColor = self.fatherView.backgroundColor;
    }
    return _shotImageView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.frame = [UIScreen mainScreen].bounds;
    self.shotImageView.frame = self.bounds;
    self.closeControl.frame = self.bounds;
//    self.contentView.frame = self.coreView.bounds;
}

@end
