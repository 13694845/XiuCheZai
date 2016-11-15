//
//  XCZMessageSearchDefaultBtn.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/31.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSearchDefaultBtn.h"

@interface XCZMessageSearchDefaultBtn()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;

@end

@implementation XCZMessageSearchDefaultBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat iconViewW = frame.size.width;
        CGFloat iconViewH = 22;
        CGFloat iconViewX = (frame.size.width - iconViewW) * 0.5;
        CGFloat iconViewY = 0;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH)];
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(iconView.frame) + 10, frame.size.width, 18)];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:nameLabel];
        nameLabel.textColor = [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:16];
        self.nameLabel = nameLabel;
    }
    return self;
}

- (void)setDict:(NSDictionary *)dict
{
    _dict = dict;

    self.iconView.image = [UIImage imageNamed:[dict objectForKey:@"image"]];
    self.nameLabel.text = [dict objectForKey:@"title"];
}

@end
