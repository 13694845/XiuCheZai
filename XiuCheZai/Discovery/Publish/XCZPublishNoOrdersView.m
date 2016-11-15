//
//  XCZPublishNoOrdersView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/11.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishNoOrdersView.h"

@interface XCZPublishNoOrdersView()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *textLabel;

@end

@implementation XCZPublishNoOrdersView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat imageViewW = 80;
        CGFloat imageViewH = 40;
        CGFloat imageViewX = (frame.size.width - imageViewW) * 0.5;
        CGFloat imageViewY = 45;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH)];
//        bbs_orde_list
        imageView.image = [UIImage imageNamed:@"bbs_orde_list"];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 16, frame.size.width, 18)];
        textLabel.text = @"您还没有订单, 赶紧去逛逛吧";
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        textLabel.font = [UIFont systemFontOfSize:18];
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        CGFloat goBtnW = 80;
        CGFloat goBtnH = 48;
        CGFloat goBtnX = (frame.size.width - goBtnW) * 0.5;
        CGFloat goBtnY = CGRectGetMaxY(textLabel.frame) + 16;
        UIButton *goBtn = [[UIButton alloc] initWithFrame:CGRectMake(goBtnX, goBtnY, goBtnW, goBtnH)];
        goBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [goBtn setBackgroundColor:[UIColor colorWithRed:232/255.0 green:37/255.0 blue:30/255.0 alpha:1.0]];
        [goBtn setTitle:@"去逛逛" forState:UIControlStateNormal];
        [goBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        goBtn.layer.cornerRadius = 5.0;
        [self addSubview:goBtn];
        
        [goBtn addTarget:self action:@selector(goBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)goBtnDidClick:(UIButton *)goBtn
{
    if ([self.delegate respondsToSelector:@selector(publishNoOrdersView:goBtnDidClick:)]) {
        [self.delegate publishNoOrdersView:self goBtnDidClick:goBtn];
    }
}

@end
