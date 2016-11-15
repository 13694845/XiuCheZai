//
//  XCZShareChannelPickerView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "XCZShareChannelPickerView.h"

@interface XCZShareChannelIconView()

@property(nonatomic, weak)UIImageView *iconView;
@property(nonatomic, weak)UILabel *nameLabel;

@end

@implementation XCZShareChannelIconView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *iconView = [[UIImageView alloc] init];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
    }
    return self;
}

- (void)setShareRow:(NSDictionary *)shareRow
{
    _shareRow = shareRow;
    
    self.iconView.image = [UIImage imageNamed:shareRow[@"icon"]];
    self.nameLabel.text = shareRow[@"name"];
    
    CGFloat iconViewW = self.selfW - 16;
    CGFloat iconViewH = iconViewW;
    self.iconView.frame = CGRectMake(8, 8, iconViewW, iconViewH);
    self.nameLabel.frame = CGRectMake(0, CGRectGetMaxY(self.iconView.frame) + 12, self.selfW, 16);
}

@end

@interface XCZShareChannelPickerView()

@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, assign) CGFloat height;

@end

@implementation XCZShareChannelPickerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *cancelBtn = [[UIButton alloc] init];
        cancelBtn.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithRed:223/255.0 green:26/255.0 blue:26/255.0 alpha:1.0] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [self addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
        [cancelBtn addTarget:self action:@selector(cancelBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (void)setShareRows:(NSArray *)shareRows
{
    _shareRows = shareRows;
    
    CGFloat lastRowHeight = 0.0;
    CGFloat iconViewW = (self.selfW - 16 * 2) * 0.2;
    CGFloat iconViewH = iconViewW + 30;
    for (int i = 0; i<shareRows.count; i++) {
        NSDictionary *shareRow = shareRows[i];
        XCZShareChannelIconView *iconView = [[XCZShareChannelIconView alloc] init];
        iconView.selfW = iconViewW;
        iconView.shareRow = shareRow;
        int liehao = i%5;
        int hanghao = i/5;
        CGFloat iconViewX = 16 + liehao * (iconViewW);
        CGFloat iconViewY = 16 + hanghao * (iconViewH);
        iconView.frame = CGRectMake(iconViewX, iconViewY, iconViewW, iconViewH);
        [self addSubview:iconView];
        if (i == (shareRows.count - 1)) {
            lastRowHeight = iconViewY + iconViewH + 16;
        }
        [iconView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconViewDidClick:)]];
    }
    
    self.cancelBtn.frame = CGRectMake(0, lastRowHeight, self.selfW, 50);
    self.bounds = CGRectMake(0, 0, self.selfW, CGRectGetMaxY(self.cancelBtn.frame));
}

- (void)cancelBtnDidClick:(UIButton *)cancelBtn
{
    if ([self.delegate respondsToSelector:@selector(shareChannelPickerView:cancelBtnDidClick:)]) {
        [self.delegate shareChannelPickerView:self cancelBtnDidClick:cancelBtn];
    }
}

- (void)iconViewDidClick:(UIGestureRecognizer *)grz
{
    XCZShareChannelIconView *iconView = (XCZShareChannelIconView *)grz.view;
    if ([self.delegate respondsToSelector:@selector(shareChannelPickerView:iconViewDidClick:)]) {
        [self.delegate shareChannelPickerView:self iconViewDidClick:iconView];
    }
}

@end
