//
//  XCZPublishOrdersViewCellBottomView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/11.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishOrdersViewCellBottomView.h"

@interface XCZPublishOrdersViewCellBottomView()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *showLabel;

@end

@implementation XCZPublishOrdersViewCellBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        CGFloat iconViewH = 15;
        CGFloat iconViewW = 15;
        CGFloat showLabelW = 80;
        CGFloat showLabelH = 15;
        CGFloat gongTongW = iconViewW + showLabelW + 8;
        CGFloat iconViewX = (frame.size.width - gongTongW) * 0.5;
        CGFloat iconViewY = 8;
        CGFloat showLabelX = iconViewX + iconViewW + 8;
        CGFloat showLabelY = 8;
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH)];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *showLabel = [[UILabel alloc] initWithFrame:CGRectMake(showLabelX, showLabelY, showLabelW, showLabelH)];
        showLabel.font = [UIFont systemFontOfSize:14];
        showLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self addSubview:showLabel];
        self.showLabel = showLabel;
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellBottomViewDidClick:)]];
    }
    return self;
}

- (void)setShowTitle:(NSString *)showTitle
{
    _showTitle = showTitle;
    
    self.showLabel.text = showTitle;
}

- (void)cellBottomViewDidClick:(UIGestureRecognizer *)grz
{
    XCZPublishOrdersViewCellBottomView *cellBottomView = (XCZPublishOrdersViewCellBottomView *)grz.view;
    if ([self.delegate respondsToSelector:@selector(cellBottomViewDidClick:)]) {
        [self.delegate cellBottomViewDidClick:cellBottomView];
    }
}


@end
