//
//  Double12AwardViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/30.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "Double12AwardViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface Double12AwardViewCell()

@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIImageView *iconView;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation Double12AwardViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self addSubview:self.lineView];
        
        self.iconView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 40, 40)];
        self.iconView.backgroundColor = self.lineView.backgroundColor;
        self.iconView.layer.cornerRadius = self.iconView.bounds.size.height * 0.5;
        self.iconView.clipsToBounds = YES;
        [self addSubview:self.iconView];
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.iconView.frame) + 12, 26, 135, 12)];
        self.nameLabel.text = @"";
        self.nameLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        self.nameLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.nameLabel];
        
        self.priceLabel = [[UILabel alloc] init];
        self.priceLabel.text = @"";
        self.priceLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0  blue:51/255.0  alpha:1.0];
        self.priceLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.priceLabel];
        
        self.timeLabel = [[UILabel alloc] init];
        self.timeLabel.text = @"";
        self.timeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        self.timeLabel.font = [UIFont systemFontOfSize:12];
        [self addSubview:self.timeLabel];
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
 
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    self.nameLabel.text = [row objectForKey:@"login_name"];
    double priceDouble = [[row objectForKey:@"get_money"] doubleValue] / 100.0;
    self.priceLabel.text = [NSString stringWithFormat:@"%.2f%@", priceDouble, @"元"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:MM"];
    NSString *get_timeYStr = [row objectForKey:@"get_time"];
    double get_timeYDouble = (get_timeYStr.length == 13) ? [get_timeYStr doubleValue]/1000 : [get_timeYStr doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:get_timeYDouble];
    NSString *get_timeStr = [formatter stringFromDate:date];
    self.timeLabel.text = get_timeStr;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat priceLabelW = [self.priceLabel.text boundingRectWithSize:CGSizeMake(100, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.priceLabel.font} context:nil].size.width;
    self.priceLabel.frame = CGRectMake(self.bounds.size.width - 12 - priceLabelW, 16, priceLabelW, 12);
    
    CGFloat timeLabelW = [self.timeLabel.text boundingRectWithSize:CGSizeMake(110, 18) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.timeLabel.font} context:nil].size.width;
    self.timeLabel.frame = CGRectMake(self.bounds.size.width - 12 - timeLabelW, self.bounds.size.height - 1 - 16 - 12, timeLabelW, 12);
    self.lineView.frame = CGRectMake(0, 64, self.bounds.size.width, 1.0);
}






@end
