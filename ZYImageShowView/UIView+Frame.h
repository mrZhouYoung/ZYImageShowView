//
//  UIView+Frame.h
//  ToTrade
//
//  Created by totrade2 on 16/3/17.
//  Copyright © 2016年 ToTrade. All rights reserved.
//

#import <UIKit/UIKit.h>

#define WIDTH_VIEW [[UIScreen mainScreen] bounds].size.width
#define HEIGHT_VIEW  [[UIScreen mainScreen] bounds].size.height
#define WeakObj(o) autoreleasepool{} __weak typeof(o) o##Weak = o

@interface UIView (Frame)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat centerX;
@property (nonatomic, assign) CGFloat centerY;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign, getter=y, setter=setY:) CGFloat top;
@property (nonatomic, assign, getter=x, setter=setX:) CGFloat left;

+ (instancetype)viewFromXib;

@end
