//
//  ChatImageViewer.m
//  XiuCheZai
//
//  Created by QSH on 16/10/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatImageViewer.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation ChatImageViewer

- (instancetype)initWithImageURL:(NSString *)imageURL {
    self = [super init];
    if (self) {
        UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        backgroundView.backgroundColor = [UIColor blackColor];
        
        UIImageView *imgView = [[UIImageView alloc] init];
        [imgView sd_setImageWithURL:[NSURL URLWithString:imageURL]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;
        imgView.frame = self.bounds;
        [backgroundView addSubview:imgView];
        
        UIButton *closeButton = [[UIButton alloc] init];
        closeButton.frame = CGRectMake(20.0, 20.0, 32.0, 32.0);
        [closeButton setTitle:@"X" forState:UIControlStateNormal];
        closeButton.backgroundColor = [UIColor grayColor];
        closeButton.layer.cornerRadius = 16.0;
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [backgroundView addSubview:closeButton];
        [self addSubview:backgroundView];
    }
    return self;
}

- (void)close {
    [self removeFromSuperview];
}

@end
