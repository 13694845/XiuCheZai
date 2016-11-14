//
//  XCZMessageSearchResultClubCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/31.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSearchResultClubCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZMessageSearchResultClubCell()

@property (nonatomic, weak) UIImageView *iconImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *remarkLabel;

@end

@implementation XCZMessageSearchResultClubCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *iconImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:iconImageView];
        self.iconImageView = iconImageView;
        
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
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"forum_style"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    
    self.nameLabel.text = [self stringByReplacing:row[@"forum_name"]];
    self.remarkLabel.text = [self stringByReplacing:row[@"forum_remark"]];
    
    self.iconImageView.frame = CGRectMake(16, 8, 42, 42);
    self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 8, 12, self.selfW - CGRectGetMaxX(self.iconImageView.frame) - 16, 14);
    self.remarkLabel.frame = CGRectMake(self.nameLabel.frame.origin.x, CGRectGetMaxY(self.nameLabel.frame) + 8, self.nameLabel.bounds.size.width, 10);
}

- (NSString *)stringByReplacing:(NSString *)string
{
    NSString *summaryShow = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@" " withString:@""];
    return summaryShow;
}

@end
