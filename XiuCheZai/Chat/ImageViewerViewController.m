//
//  ImageViewerViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/11/7.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ImageViewerViewController.h"
#import "AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface ImageViewerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ImageViewerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.imageURL]];
    
    self.imageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
    [self.imageView addGestureRecognizer:tapGestureRecognizer];
    UIPanGestureRecognizer *panGestureRecognizer =[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panImage:)];
    [self.imageView addGestureRecognizer:panGestureRecognizer];
    UIPinchGestureRecognizer *pinchGestureRecognizer =[[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchImage:)];
    [self.imageView addGestureRecognizer:pinchGestureRecognizer];
}

- (void)tapImage:(UITapGestureRecognizer *)tapGestureRecognizer {
    [self dismissViewControllerAnimated:NO completion:^{}];
}

- (void)panImage:(UIPanGestureRecognizer *)panGestureRecognizer {
    NSLog(@"panGestureRecognizer");
}

- (void)pinchImage:(UIPanGestureRecognizer *)pinchGestureRecognizer {
    NSLog(@"pinchGestureRecognizer");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
