//
//  ZYImageShowView.h
//  PhotoView
//
//  Created by Young on 2018/4/7.
//  Copyright © 2018年 Young. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ZYImageShowViewDelegate <NSObject>

- (void)imageShowViewDidDismiss;

@end

@interface ZYImageShowView : UIView

@property (nonatomic, weak) id<ZYImageShowViewDelegate> delegate;
//

- (instancetype)initWithImage:(UIImage *)image imageFrame:(CGRect)frame;

- (void)show;


@end
