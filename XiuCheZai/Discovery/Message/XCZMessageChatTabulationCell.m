//
//  XCZMessageChatTabulationCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/30.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageChatTabulationCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "DiscoveryConfig.h"
#import "XCZCityManager.h"

@interface XCZMessageChatTabulationCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) UILabel *userNameLabel;
@property (weak, nonatomic) UIImageView *brand_logoImaegView;
@property (weak, nonatomic) IBOutlet UILabel *siteCircleLabel;


@end

@implementation XCZMessageChatTabulationCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.iconImageView.layer.cornerRadius = self.iconImageView.bounds.size.height * 0.5;
    self.iconImageView.layer.masksToBounds = YES;
    UILabel *userNameLabel = [[UILabel alloc] init];
    [self addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    
    UIImageView *brand_logoImaegView = [[UIImageView alloc] init];
    [self addSubview:brand_logoImaegView];
    self.brand_logoImaegView = brand_logoImaegView;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    NSLog(@"rowrowrow:%@", row);
    NSString *iconImageStr = [self changeIconStr:row[@"avatar"]];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:iconImageStr] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    
    self.userNameLabel.font = [UIFont systemFontOfSize:14];
    self.userNameLabel.textColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1.0];
    
    NSString *userText = row[@"nick"];
    NSString *userNameText = [NSString stringWithFormat:@"%@", row[@"user_name"]];
    self.userNameLabel.text = userText.length ? userText : userNameText;
    
    CGSize userNameLabelSize = [self.userNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.userNameLabel.font} context:nil].size;
    self.userNameLabel.frame = CGRectMake(58 + XCZNewDetailRemarkRowMarginX, XCZNewDetailRemarkRowMarginY, userNameLabelSize.width, userNameLabelSize.height);
    
    self.brand_logoImaegView.frame = CGRectMake(CGRectGetMaxX(self.userNameLabel.frame) + 4, self.userNameLabel.frame.origin.y, self.userNameLabel.frame.size.height, self.userNameLabel.frame.size.height);
    [self.brand_logoImaegView sd_setImageWithURL:[NSURL URLWithString:[self changeIconStr:row[@"brand_logo"]]] placeholderImage:nil];
    self.brand_logoImaegView.layer.cornerRadius = self.brand_logoImaegView.bounds.size.height * 0.5;
    self.brand_logoImaegView.layer.masksToBounds = YES;
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:row[@"province_id"] cityId:row[@"city_id"] andTownId:row[@"area_id"]];
    if (!addr.length) {
        self.siteCircleLabel.text = ((NSString *)row[@"join_forum"]).length ? [NSString stringWithFormat:@"%@", row[@"join_forum"]] : @"";
    } else {
        self.siteCircleLabel.text = ((NSString *)row[@"join_forum"]).length ? [NSString stringWithFormat:@"%@ · %@", row[@"join_forum"], addr] : [NSString stringWithFormat:@"%@", addr];
    }
}

/**
 *  头像地址处理
 */
- (NSString *)changeIconStr:(NSString *)iconStr
{
    NSString *avatar;
    if ([iconStr containsString:@"http"]) {
        avatar = iconStr;
    } else {
        if (iconStr.length) {
            if ([[iconStr substringToIndex:1] isEqualToString:@"/"]) {
                avatar = [NSString stringWithFormat:@"%@%@", [XCZConfig imgBaseURL], iconStr];
            } else {
                avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], iconStr];
            }
        } else {
            avatar = @"";
        }
    }
    return avatar;
}

@end
