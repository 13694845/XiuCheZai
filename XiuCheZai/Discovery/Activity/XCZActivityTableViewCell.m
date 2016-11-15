//
//  XCZActivityTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZActivityTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZActivityTableViewCell()

@property (weak, nonatomic) UIImageView *activityImageView;
@property (weak, nonatomic) UILabel *activityTypeLabel;
@property (weak, nonatomic) UILabel *activityTitleLabel;
@property (weak, nonatomic) UILabel *activityTimeLabel;
@property (weak, nonatomic) UIView *activityLineView;

@end

@implementation XCZActivityTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        UIImageView *activityImageView = [[UIImageView alloc] init];
        activityImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:activityImageView];
        self.activityImageView = activityImageView;
        
        UILabel *activityTypeLabel = [[UILabel alloc] init];
        activityTypeLabel.backgroundColor = [UIColor colorWithRed:60/255.0 green:150/255.0 blue:210/255.0 alpha:1.0];
        activityTypeLabel.textColor = [UIColor whiteColor];
        activityTypeLabel.textAlignment = NSTextAlignmentCenter;
        activityTypeLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:activityTypeLabel];
        self.activityTypeLabel = activityTypeLabel;
        
        UILabel *activityTitleLabel = [[UILabel alloc] init];
        activityTitleLabel.numberOfLines = 0;
        activityTitleLabel.font = [UIFont systemFontOfSize:14];
        activityTitleLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
        [self.contentView addSubview:activityTitleLabel];
        self.activityTitleLabel = activityTitleLabel;
        
        UILabel *activityTimeLabel = [[UILabel alloc] init];
        activityTimeLabel.font = [UIFont systemFontOfSize:10];
        activityTimeLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self.contentView addSubview:activityTimeLabel];
        self.activityTimeLabel = activityTimeLabel;
        
        UILabel *activityLineView = [[UILabel alloc] init];
        activityLineView.backgroundColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0];
        [self.contentView addSubview:activityLineView];
        self.activityLineView = activityLineView;
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    NSString *imageUrlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"main_image"]];
    [self.activityImageView sd_setImageWithURL:[NSURL URLWithString:imageUrlStr] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    
    NSString *avatar;
    if ([row[@"avatar"] containsString:@"http"]) {
        avatar = row[@"avatar"];
    } else {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], row[@"avatar"]];
    }
   
    self.activityTypeLabel.text = @"活";
    self.activityTypeLabel.layer.cornerRadius = 2.0;
    self.activityTypeLabel.layer.masksToBounds = YES;
    
    NSString *summaryShow = [row[@"summary"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@" " withString:@""];
    self.activityTitleLabel.text = [NSString stringWithFormat:@"%@", summaryShow];
    self.activityTimeLabel.text = [NSString stringWithFormat:@"截止日期:  %@", row[@"end_time"]];
    
    CGFloat activityImageViewX = 16;
    CGFloat activityImageViewY = 16;
    CGFloat activityImageViewW = self.cellW - 2 * activityImageViewX;
    CGFloat activityImageViewH = activityImageViewW * (212/656.0);
    self.activityImageView.frame = CGRectMake(activityImageViewX, activityImageViewY, activityImageViewW, activityImageViewH);
    
    CGFloat activityTypeLabelW = 14;
    CGFloat activityTypeLabelH = 14;
    CGFloat activityTypeLabelX = activityImageViewY;
    CGFloat activityTypeLabelY = CGRectGetMaxY(self.activityImageView.frame) + 12;
    self.activityTypeLabel.frame = CGRectMake(activityTypeLabelX, activityTypeLabelY, activityTypeLabelW, activityTypeLabelH);
    
    CGFloat activityTitleLabelW = self.cellW - 32 - 22;
    CGSize activityTitleLabelSize = [self.activityTitleLabel.text boundingRectWithSize:CGSizeMake(activityTitleLabelW, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.activityTitleLabel.font} context:nil].size;
    CGFloat activityTitleLabelX = CGRectGetMaxX(self.activityTypeLabel.frame) + 8;
    CGFloat activityTitleLabelY = activityTypeLabelY;
    self.activityTitleLabel.frame = CGRectMake(activityTitleLabelX, activityTitleLabelY, activityTitleLabelSize.width, activityTitleLabelSize.height);
    
    CGFloat activityTimeLabelX = activityTitleLabelX;
    CGFloat activityTimeLabelY = CGRectGetMaxY(self.activityTitleLabel.frame) + 8;
    CGFloat activityTimeLabelW = activityTitleLabelW;
    CGFloat activityTimeLabelH = 10;
    self.activityTimeLabel.frame = CGRectMake(activityTimeLabelX, activityTimeLabelY, activityTimeLabelW, activityTimeLabelH);
    
    self.activityLineView.frame = CGRectMake(16, CGRectGetMaxY(self.activityTimeLabel.frame) + 8, self.cellW - 32, 1.0);
    
    CGFloat cellHeight =  CGRectGetMaxY(self.activityLineView.frame);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZActivityTableViewCellToVCSetupCellHeightNot" object:nil userInfo:@{@"cellHeight": @(cellHeight)}];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
