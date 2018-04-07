//
//  ZYImageShowView.m
//  PhotoView
//
//  Created by Young on 2018/4/7.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ZYImageShowView.h"

#import "ZYImageShowView.h"
#import "UIView+Frame.h"

static const CGFloat animaTime = 0.3;

@interface ZYImageShowView ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic) UIScrollView *bottomScrollV;
@property (nonatomic) UIImageView  *imageView;
@property (nonatomic) UIImage      *image;
@property (nonatomic, assign) CGRect        imgViewFrame;
@property (nonatomic, assign) CGFloat       totalScale;
@property (nonatomic) UIView       *barBackView;
@property (nonatomic, assign) CGPoint  beginP;
@property (nonatomic) UIPanGestureRecognizer *panGes;

@end

@implementation ZYImageShowView

- (instancetype)initWithImage:(UIImage *)image imageFrame:(CGRect)frame {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.image = image;
        self.imgViewFrame = frame;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return [gestureRecognizer isEqual:_panGes] && ([otherGestureRecognizer isEqual:_bottomScrollV.panGestureRecognizer] || [otherGestureRecognizer isEqual:_bottomScrollV.pinchGestureRecognizer]);
}

#pragma mark - UIScrollerView Delegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)panAction:(UIPanGestureRecognizer *)gesture {
    BOOL ended = gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled;
    if (!ended && (_bottomScrollV.zoomScale != 1 || _bottomScrollV.zooming))
        return;
    
    CGPoint translation = [gesture translationInView:self];
    CGFloat distance = sqrt(translation.x*translation.x + translation.y*translation.y);
    CGFloat scale = 1 - distance / sqrt(self.bounds.size.width * self.bounds.size.width + HEIGHT_VIEW * HEIGHT_VIEW);
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [gesture locationInView:self];
        self.beginP = CGPointMake(location.x - self.imageView.centerX, location.y - self.imageView.centerY);
        _bottomScrollV.bounces = NO;
    }
    else if (!ended) {
        CGAffineTransform transform = CGAffineTransformMakeTranslation(translation.x + (self.beginP.x * (1 - scale)), translation.y + (self.beginP.y * (1 - scale)));
        gesture.view.layer.affineTransform = CGAffineTransformScale(transform, scale, scale);
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:scale*scale];
    }
    else if (!_bottomScrollV.bounces && scale < 0.8) {
        [self hide];
    }
    else {
        _bottomScrollV.bounces = YES;
        @WeakObj(self);
        [UIView animateWithDuration:animaTime animations:^{
            gesture.view.layer.affineTransform = CGAffineTransformIdentity;
            selfWeak.backgroundColor = [UIColor blackColor];
        }];
    }
}

#pragma Show and Hide
- (void)show {
    CGSize imageSize = self.image.size;
    CGFloat imageH = self.bounds.size.width / self.image.size.width * self.image.size.height;
    if (imageSize.width >= self.bounds.size.width) {
        self.bottomScrollV.maximumZoomScale = imageSize.width / self.bounds.size.width * 2;
    } else {
        self.bottomScrollV.maximumZoomScale = 1 * 2;
    }
    self.imageView.image = self.image;
    [self.bottomScrollV addSubview:self.imageView];
    _bottomScrollV.contentSize = _imageView.frame.size;
    [self addSubview:self.bottomScrollV];
    
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    @WeakObj(self);
    [UIView animateWithDuration:animaTime animations:^{
        selfWeak.imageView.frame = CGRectMake(0,0, self.bounds.size.width, imageH);
        selfWeak.imageView.center = selfWeak.center;
        selfWeak.backgroundColor = [UIColor blackColor];
    }];
}

- (void)hide {
    
    CGSize size = self.image.size;
    float ratio = size.width / size.height;
    CGRect to = self.imgViewFrame;
    if (to.size.width / to.size.height >= ratio) {
        to = CGRectInset(to, (to.size.width - to.size.height * ratio) / 2, 0);
    }
    else {
        to = CGRectInset(to, 0, (to.size.height - to.size.width / ratio) / 2);
    }
    CGRect from = [UIScreen mainScreen].bounds;
    float fromRatio = from.size.width / from.size.height;
    if (fromRatio >= ratio) {
        to = CGRectInset(to, (to.size.width - to.size.height * fromRatio) / 2, 0);
    }
    else {
        to = CGRectInset(to, 0, (to.size.height - to.size.width / fromRatio) / 2);
    }
    
    float sx = to.size.width / from.size.width;
    float sy = to.size.height / from.size.height;
    float tx = to.origin.x - from.origin.x;
    float ty = to.origin.y - from.origin.y;
    tx -= from.size.width * (1 - sx) / 2;
    ty -= from.size.height * (1 - sy) / 2;
    CGAffineTransform transform = CGAffineTransformMakeTranslation(tx, ty);
    transform = CGAffineTransformScale(transform, sx, sy);
    
    @WeakObj(self);
    // Fixes affineTransform jumps at beginning bug by applying a keyframe animation
    // see https://stackoverflow.com/questions/27931421/cgaffinetransform-scale-and-translation-jump-before-animation
    // and https://stackoverflow.com/questions/12535647/uiview-animation-jumps-at-beginning
    //[UIView animateWithDuration:animaTime animations:^ {
    //selfWeak.bottomScrollV.layer.affineTransform = transform;
    //selfWeak.bottomScrollV.zoomScale = 1;
    //selfWeak.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
    CGAffineTransform initial = self.bottomScrollV.layer.affineTransform;
    [UIView animateKeyframesWithDuration:animaTime delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubic animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.01 animations:^{
            selfWeak.bottomScrollV.layer.affineTransform = initial; // reset transform start point
        }];
        [UIView addKeyframeWithRelativeStartTime:0.01 relativeDuration:0.99 animations:^{
            selfWeak.bottomScrollV.layer.affineTransform = transform;
            selfWeak.bottomScrollV.zoomScale = 1;
            selfWeak.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0];
        }];
    } completion:^(BOOL finished) {
        [selfWeak.imageView removeFromSuperview];
        selfWeak.imageView = nil;
        [selfWeak removeFromSuperview];
        if ([UIApplication sharedApplication].statusBarHidden)
            [UIApplication sharedApplication].statusBarHidden = NO;
        [selfWeak.delegate imageShowViewDidDismiss];
    }];
}

- (void)doubleClick:(UITapGestureRecognizer *)gesture {
    CGRect zoomRect;
    CGFloat scale = _bottomScrollV.zoomScale;
    if (scale != 1) {
        zoomRect = CGRectMake(-self.imageView.origin.x, -self.imageView.origin.y, self.frame.size.width, self.frame.size.height);
    }
    else {
        scale = _bottomScrollV.maximumZoomScale;
        CGPoint center = [gesture locationInView:gesture.view];
        zoomRect.size.height = self.frame.size.height / scale;
        zoomRect.size.width  = self.frame.size.width  / scale;
        zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0) - self.imageView.origin.x;
        zoomRect.origin.y = center.y - (zoomRect.size.height /2.0) - self.imageView.origin.y;
    }
    [self.bottomScrollV zoomToRect:zoomRect animated:YES];
}

- (void)click:(UITapGestureRecognizer *)sender {
    BOOL state = ![UIApplication sharedApplication].statusBarHidden;
    if (state) {
        [UIView animateWithDuration:animaTime animations:^{
            self.barBackView.alpha = 0;
        } completion:^(BOOL finished) {
            self.barBackView.hidden = state;
        }];
    } else {
        self.barBackView.hidden = state;
        [UIView animateWithDuration:animaTime animations:^{
            self.barBackView.alpha = 1;
        }];
    }
}

#pragma mark UI
- (UIScrollView *)bottomScrollV {
    if (!_bottomScrollV) {
        _bottomScrollV = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _bottomScrollV.delegate = self;
        _bottomScrollV.showsVerticalScrollIndicator = NO;
        _bottomScrollV.showsHorizontalScrollIndicator = NO;
        UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(click:)];
        [_bottomScrollV addGestureRecognizer:ges];
        
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
        [tapGes setNumberOfTapsRequired:2];
        [_bottomScrollV addGestureRecognizer:tapGes];
        [ges requireGestureRecognizerToFail:tapGes];
        
        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        _panGes.delegate = self;
        [_bottomScrollV addGestureRecognizer:_panGes];
    }
    return _bottomScrollV;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [UIImageView new];
        _imageView.frame = self.imgViewFrame;
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled = YES;
    }
    return _imageView;
}

@end

