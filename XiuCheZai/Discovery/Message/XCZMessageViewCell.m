//
//  XCZMessageViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageViewCell.h"

@interface XCZMessageViewCell()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UIImageView *rightArrowView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *numLabel;
@property (nonatomic, weak) UIView *lineView;


@end

@implementation XCZMessageViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        self.backgroundColor = [UIColor redColor];
        
        UIImageView *iconView = [[UIImageView alloc] init];
        [self addSubview:iconView];
        self.iconView = iconView;
        UILabel *numLabel = [[UILabel alloc] init];
        numLabel.textAlignment = NSTextAlignmentCenter;
//        numLabel.backgroundColor = [UIColor colorWithRed:231/255.0 green:31/255.0 blue:25/255.0 alpha:1.0];
        numLabel.backgroundColor = [UIColor clearColor];
        numLabel.textColor = [UIColor whiteColor];
        numLabel.font = [UIFont systemFontOfSize:10];
        [iconView addSubview:numLabel];
        self.numLabel = numLabel;
    
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        titleLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self addSubview:lineView];
        self.lineView = lineView;
    }
    return self;
}

#pragma mark - 固定部分
/**
 *  name : 名称
 *  icon : 图标
 *  content : 内容
 */
- (void)setChat:(NSDictionary *)chat
{
    _chat = chat;
    
    self.nameLabel.text = chat[@"name"];
    self.iconView.image = [UIImage imageNamed:chat[@"icon"]] ;
    self.titleLabel.text = chat[@"content"];
    [self setupFixedDataFrame];
}

- (void)setupFixedDataFrame
{
    self.iconView.frame = CGRectMake(8, 8, 40, 40);
    
    CGFloat nameLabelX = CGRectGetMaxX(self.iconView.frame) + 8;
    CGFloat nameLabelW = self.selfW - 15 - 16 - nameLabelX;
    self.nameLabel.frame = CGRectMake(nameLabelX, 8, nameLabelW, 17);
    
    CGFloat titleLabelX = nameLabelX;
    CGFloat titleLabelY = CGRectGetMaxY(self.nameLabel.frame) + 8;
    CGFloat titleLabelW = nameLabelW;
    CGFloat titleLabelH = 12;
    self.titleLabel.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    
    CGFloat lineViewH = 1.0;
    self.lineView.frame = CGRectMake(0, 57, self.selfW, lineViewH);
}

#pragma mark - 刷新部分
/**
 *  num : 数
 *  content : 内容
 */
- (void)setContent:(NSDictionary *)content
{
    _content = content;
    
    if (content) {
        int num = [content[@"num"] intValue];
        if (num) {
            [self setupNumLabelFrame:num];
        } else {
            self.numLabel.frame = CGRectMake(0, 0, 0, 0);
        }
        self.titleLabel.text = content[@"content"];
    }
}

- (void)setupNumLabelFrame:(int)num
{
//    self.numLabel.text = [NSString stringWithFormat:@"%d", num];
    self.numLabel.text = @"";
    CGSize numLabelSize = [self.numLabel.text boundingRectWithSize:CGSizeMake(self.iconView.bounds.size.width * 0.5, 24) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.numLabel.font} context:nil].size;
    CGFloat numLabelH = 12;
    CGFloat numLabelW = numLabelSize.width + 6;
    if (numLabelW <= numLabelH) numLabelW = numLabelH;
    self.numLabel.frame = CGRectMake(self.iconView.bounds.size.width - numLabelW, 0, numLabelW, numLabelH);
    self.numLabel.layer.cornerRadius = numLabelH * 0.5;
    self.numLabel.layer.masksToBounds = YES;
}

@end
