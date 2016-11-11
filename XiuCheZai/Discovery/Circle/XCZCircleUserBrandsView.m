//
//  XCZCircleUserBrandsView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleUserBrandsView.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "XCZCityManager.h"

@interface XCZCircleUserBrandsView()

@property (nonatomic, weak) UIImageView *iconView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UIImageView *logoView;
@property (nonatomic, weak) UILabel *circleCityLabel;

@end

@implementation XCZCircleUserBrandsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 42, 42)];
        iconView.layer.cornerRadius = iconView.bounds.size.height * 0.5;
        [self addSubview:iconView];
        self.iconView = iconView;
        
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
        nameLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
    
        UIImageView *logoView = [[UIImageView alloc] init];
        [self addSubview:logoView];
        self.logoView = logoView;
        
        CGFloat circleCityLabelH = 10;
        CGFloat circleCityLabelY = frame.size.height - 12 - circleCityLabelH;
        CGFloat circleCityLabelX = 58;
        CGFloat circleCityLabelW = frame.size.width - circleCityLabelX - 16;
        UILabel *circleCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(circleCityLabelX, circleCityLabelY, circleCityLabelW, circleCityLabelH)];
        [self addSubview:circleCityLabel];
        circleCityLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        circleCityLabel.font = [UIFont systemFontOfSize:10];
        self.circleCityLabel = circleCityLabel;
    }
    return self;
}

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], artDict[@"avatar"]];
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    
    NSString *userName = (artDict[@"nick"] && (![artDict[@"nick"] isEqual:[NSNull null]] && ![(NSString *)artDict[@"nick"] isEqualToString:@""])) ? artDict[@"nick"] : artDict[@"login_name"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@", userName];
    
    NSString *logoViewImageStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], artDict[@"brand_logo"]];
    [self.logoView sd_setImageWithURL:[NSURL URLWithString:logoViewImageStr]];
    
     NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:@"" cityId:artDict[@"city_id"] andTownId:artDict[@"area_id"]];
    if (!addr.length) {
        self.circleCityLabel.text = [NSString stringWithFormat:@"%@", artDict[@"user_forum_name"]];
    } else {
        if (((NSString *)artDict[@"user_forum_name"]).length) {
            self.circleCityLabel.text = [NSString stringWithFormat:@"%@ · %@", artDict[@"user_forum_name"], addr];
        } else {
            self.circleCityLabel.text = [NSString stringWithFormat:@"%@", addr];
        }
    }
    
    CGFloat nameLabelX = CGRectGetMaxX(self.iconView.frame) + 8;
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width * 0.9 - nameLabelX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    CGFloat nameLabelW = nameLabelSize.width;
    self.nameLabel.frame = CGRectMake(nameLabelX, 12, nameLabelW, 14);
    
    CGFloat logoViewX = CGRectGetMaxX(self.nameLabel.frame);
    CGFloat logoViewH = self.nameLabel.bounds.size.height;
    CGFloat logoViewW = logoViewH;
    self.logoView.frame = CGRectMake(logoViewX, 12, logoViewW, logoViewH);
    
    
}


@end
