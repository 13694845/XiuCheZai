//
//  XCZMessageSearchResultTopCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/31.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSearchResultTopicCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZMessageSearchResultTopicCell()

@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *remarkLabel;
@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UIView *lineView;

@end

@implementation XCZMessageSearchResultTopicCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
        [self.contentView addSubview:nameLabel];
        self.nameLabel = nameLabel;
        
        UILabel *remarkLabel = [[UILabel alloc] init];
        remarkLabel.font = [UIFont systemFontOfSize:10];
        remarkLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        [self.contentView addSubview:remarkLabel];
        self.remarkLabel = remarkLabel;
        
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self.contentView addSubview:lineView];
        self.lineView = lineView;
    }
    return self;
}


- (void)setRow:(NSDictionary *)row
{
    _row = row;

    self.nameLabel.text = row[@"topic"];
    self.remarkLabel.text = row[@"summary"];
     [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"main_image"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    
    self.nameLabel.frame = CGRectMake(16, 12, self.selfW - 42 - 16 - 8, 14);
    self.remarkLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, CGRectGetMaxY(self.nameLabel.frame) + 8, self.nameLabel.bounds.size.width, 10);
    self.iconImageView.frame = CGRectMake(self.selfW - 42 - 16, 8, 42, 42);
    self.lineView.frame = CGRectMake(0, 58.5, self.selfW, 0.5);
}

@end
