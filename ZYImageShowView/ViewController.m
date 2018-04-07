//
//  ViewController.m
//  PhotoView
//
//  Created by Young on 2018/4/7.
//  Copyright © 2018年 Young. All rights reserved.
//

#import "ViewController.h"
#import "ZYImageShowView.h"
@interface ViewController ()<ZYImageShowViewDelegate>
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, assign) CGRect frame;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 200, 200)];
    bgView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:bgView];
    
    
    _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg.jpeg"]];
    _imgView.frame = CGRectMake(50, 50, 100, 100);
    _imgView.contentMode = UIViewContentModeScaleAspectFit;
    _imgView.userInteractionEnabled = YES;
    [bgView addSubview:_imgView];

    CGRect frame = [bgView convertRect:_imgView.frame toView:self.view];
    _frame = frame;
    NSLog(@"frame: %@", NSStringFromCGRect(frame));
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [_imgView addGestureRecognizer:tap];
    
}




- (void)tapAction:(UITapGestureRecognizer *)sender {
    UIImageView *imgView = self.imgView;
    ZYImageShowView *imageShowView = [[ZYImageShowView alloc] initWithImage:imgView.image imageFrame:_frame];
    imageShowView.delegate = self;
    [self.view addSubview:imageShowView];
    [imageShowView show];
}

- (void)imageShowViewDidDismiss {
    
}

- (void)imageShowViewShareImage:(UIImage *)image withTitle:(NSString *)title {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
