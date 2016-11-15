//
//  XCZClubCircleViewMemberCellUserAddView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewMemberCellUserAddView.h"

@interface XCZClubCircleViewMemberCellUserAddView()

/** 1.iconView */
@property (nonatomic, weak) UIImageView *iconView;
/** 2.nameLabel */
@property (nonatomic, weak) UILabel *nameLabel;
/** 3.suosuLabel */
@property (nonatomic, weak) UILabel *suosuLabel;

@end

@implementation XCZClubCircleViewMemberCellUserAddView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        /** 1.iconView */
        UIImageView *iconView = [[UIImageView alloc] init];
        iconView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        /** 2.nameLabel */
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor colorWithRed:35/255.0 green:82/255.0 blue:176/255.0 alpha:1.0];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        /** 3.suosuLabel */
        UILabel *suosuLabel = [[UILabel alloc] init];
        suosuLabel.font = [UIFont systemFontOfSize:10];
        suosuLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        [self addSubview:suosuLabel];
        self.suosuLabel = suosuLabel;
        
        [self setupAttr];

    }
    return self;
}

- (void)setupAttr
{
    self.nameLabel.text = @"邀请好友加入";
    self.suosuLabel.text = @"可以邀请多个好友加入";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    
//    [self setupFrame];
    
}

- (void)setCellW:(CGFloat)cellW
{
    _cellW = cellW;
    
    self.iconView.frame = CGRectMake(8, 8, 42, 42);
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.height * 0.5;
    
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.cellW, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    CGFloat nameLabelX = CGRectGetMaxX(self.iconView.frame) + 8;
    CGFloat nameLabelW = (self.cellW * 0.5 - nameLabelX - 8);
    self.nameLabel.frame = CGRectMake(nameLabelX, 12, nameLabelW, nameLabelSize.height);
    
    CGSize suosuLabelSize = [self.suosuLabel.text boundingRectWithSize:CGSizeMake(self.cellW, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.suosuLabel.font} context:nil].size;
    self.suosuLabel.frame = CGRectMake(nameLabelX, CGRectGetMaxY(self.nameLabel.frame) + 4, nameLabelW, suosuLabelSize.height);
    
}


@end
