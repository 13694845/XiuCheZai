//
//  XCZClubTableHeaderSubView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/28.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubTableHeaderSubView.h"

@interface XCZClubTableHeaderSubView()

/** 1.nameLabel */
@property (nonatomic, weak) UILabel *nameLabel;
/** 2.miaoshuLabel */
@property (nonatomic, weak) UILabel *miaoshuLabel;
/** 3.numLabel */
@property (nonatomic, weak) UILabel *numLabel;

@end

@implementation XCZClubTableHeaderSubView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:231/255.0 green:231/255.0 blue:231/255.0 alpha:1.0];
        self.layer.cornerRadius = 5.0;
        self.layer.masksToBounds = YES;
        
        /** 1.nameLabel */
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
       
        /** 2.miaoshuLabel */
        UILabel *miaoshuLabel = [[UILabel alloc] init];
        miaoshuLabel.font = [UIFont systemFontOfSize:10];
        miaoshuLabel.textColor = [UIColor colorWithRed:14/255.0 green:91/255.0 blue:230/255.0 alpha:1.0];
        [self addSubview:miaoshuLabel];
        self.miaoshuLabel = miaoshuLabel;
        
        /** 3.numLabel */
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.backgroundColor = [UIColor colorWithRed:232/255.0 green:37/255.0 blue:30/255.0 alpha:1.0];
        numLabel.font = [UIFont systemFontOfSize:10];
        numLabel.textColor = [UIColor whiteColor];
        numLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:numLabel];
        self.numLabel = numLabel;
    }
    return self;
}

- (void)setBanner:(NSDictionary *)banner
{
    _banner = banner;
    
    [self setupAttr];
    [self setupFrame];
}

- (void)setupAttr
{
    self.nameLabel.text = self.banner[@"forum_name"];
    
    NSString *parent_name = self.banner[@"parent_name"];
    self.miaoshuLabel.text = parent_name.length ? [NSString stringWithFormat:@"（%@）", self.banner[@"parent_name"]] : @"";
    self.numLabel.text = self.banner[@"num"];
}

- (void)setupFrame
{
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.selfW  - 36, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    self.nameLabel.frame = CGRectMake(8, 4, nameLabelSize.width, nameLabelSize.height);
    
    CGSize miaoshuLabelSize = [self.miaoshuLabel.text boundingRectWithSize:CGSizeMake(self.selfW  - 36, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.miaoshuLabel.font} context:nil].size;
    self.miaoshuLabel.frame = CGRectMake(2, CGRectGetMaxY(self.nameLabel.frame), miaoshuLabelSize.width, 20);
    
    CGFloat numLabelW = 35;
    CGFloat numLabelH = 14;
    self.numLabel.frame = CGRectMake(self.selfW - 9 - numLabelW, (self.selfH - numLabelH) * 0.5, numLabelW, numLabelH);
    self.numLabel.layer.cornerRadius = numLabelH * 0.5;
    self.numLabel.layer.masksToBounds = YES;
    
//    /** 2.miaoshuLabel */
//    UILabel *miaoshuLabel = [[UILabel alloc] init];
//    miaoshuLabel.font = [UIFont systemFontOfSize:10];
//    miaoshuLabel.textColor = [UIColor colorWithRed:14/255.0 green:91/255.0 blue:230/255.0 alpha:1.0];
//    [self addSubview:miaoshuLabel];
//    self.miaoshuLabel = miaoshuLabel;
//    
//    /** 3.numLabel */
//    UILabel *numLabel = [[UILabel alloc] init];
//    numLabel.font = [UIFont systemFontOfSize:10];
//    numLabel.textColor = [UIColor whiteColor];
//    [self addSubview:numLabel];
//    self.numLabel = numLabel;
}


@end









