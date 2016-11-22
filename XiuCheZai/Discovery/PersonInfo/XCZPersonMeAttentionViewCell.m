//
//  XCZPersonMeAttentionViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/28.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonMeAttentionViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "DiscoveryConfig.h"
#import "XCZCityManager.h"

@interface XCZPersonMeAttentionViewCell()

@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) UILabel *userNameLabel;
@property (weak, nonatomic) UIImageView *brand_logoImaegView;
@property (weak, nonatomic) IBOutlet UILabel *siteCircleLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;

@end

@implementation XCZPersonMeAttentionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.iconImageView.layer.cornerRadius = self.iconImageView.bounds.size.height * 0.5;
    
    UILabel *userNameLabel = [[UILabel alloc] init];
    [self.container addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    
    UIImageView *brand_logoImaegView = [[UIImageView alloc] init];
    [self.container addSubview:brand_logoImaegView];
    self.brand_logoImaegView = brand_logoImaegView;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    NSString *iconImageStr = [self changeIconStr:row[@"brand_logo"]];
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:iconImageStr] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    
    self.userNameLabel.font = [UIFont systemFontOfSize:14];
    self.userNameLabel.textColor = [UIColor colorWithRed:20/255.0 green:20/255.0 blue:20/255.0 alpha:1.0];
    
    
    NSString *userText = row[@"nick"];
    NSString *userNameText = [NSString stringWithFormat:@"%@", row[@"login_name"]];
    self.userNameLabel.text = ([userText length] && ![userText hasPrefix:@"null"]) ? userText : userNameText;
    CGSize userNameLabelSize = [self.userNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.userNameLabel.font} context:nil].size;
    self.userNameLabel.frame = CGRectMake(50 + XCZNewDetailRemarkRowMarginX, XCZNewDetailRemarkRowMarginY, userNameLabelSize.width, userNameLabelSize.height);
    
    self.brand_logoImaegView.frame = CGRectMake(CGRectGetMaxX(self.userNameLabel.frame) + 4, self.userNameLabel.frame.origin.y, self.userNameLabel.frame.size.height, self.userNameLabel.frame.size.height);
    [self.brand_logoImaegView sd_setImageWithURL:[NSURL URLWithString:[self changeIconStr:row[@"brand_logo"]]] placeholderImage:nil];
    self.brand_logoImaegView.layer.cornerRadius = self.brand_logoImaegView.bounds.size.height * 0.5;
    self.brand_logoImaegView.layer.masksToBounds = YES;
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:@"" cityId:row[@"city_id"] andTownId:row[@"area_id"]];
    if (!addr.length) {
        self.siteCircleLabel.text = ((NSString *)row[@"forum_name"]).length ? [NSString stringWithFormat:@"%@", row[@"forum_name"]] : @"";
    } else {
        self.siteCircleLabel.text = ((NSString *)row[@"forum_name"]).length ? [NSString stringWithFormat:@"%@ · %@", row[@"forum_name"], addr] : [NSString stringWithFormat:@"%@", addr];
    }

    if (_isNoShowGuanzhu) { // 不显示关注
        [self updateGuanZhu];
        self.attentionLabel.userInteractionEnabled = NO;
        self.attentionLabel.text = @"";
    } else { // 显示关注
        self.attentionLabel.userInteractionEnabled = YES;
        [self.attentionLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(siteCircleLabelDidClick)]];
        [self updateGuanZhu];
    }
}

- (void)clearData
{
    self.iconImageView.image = nil;
    self.userNameLabel.text = @"";
    self.brand_logoImaegView.image = nil;
    self.attentionLabel.text = @"";
}

#pragma mark - 监听按钮点击
- (void)siteCircleLabelDidClick
{
    if ([self.delegate respondsToSelector:@selector(personMeAttentionViewCell:siteCircleLabelDidClick:)]) {
        [self.delegate personMeAttentionViewCell:self siteCircleLabelDidClick:[_row[@"clazz"] intValue]];
    }
}

#pragma mark - 私有方法
- (void)updateGuanZhu
{
    if (![_row[@"clazz"] intValue]) {
        self.attentionLabel.text = @"加关注";
        self.attentionLabel.textColor = [UIColor colorWithRed:29/255.0 green:220/255.0 blue:56/255.0 alpha:1.0];
    } else {
        self.attentionLabel.text = @"已关注";
        self.attentionLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
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
