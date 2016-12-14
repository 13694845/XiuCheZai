//
//  XCZClubCircleViewMemberCellUserView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewMemberCellUserView.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"
#import "XCZCityManager.h"

@interface XCZClubCircleViewMemberCellUserView()

/** 1.iconView */
@property (nonatomic, weak) UIImageView *iconView;
/** 2.nameLabel */
@property (nonatomic, weak) UILabel *nameLabel;
/** 3.suosuLabel */
@property (nonatomic, weak) UILabel *suosuLabel;

@end

@implementation XCZClubCircleViewMemberCellUserView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        /** 1.iconView */
        UIImageView *iconView = [[UIImageView alloc] init];
        [self addSubview:iconView];
        self.iconView = iconView;
        
        /** 2.nameLabel */
        UILabel *nameLabel = [[UILabel alloc] init];
        nameLabel.font = [UIFont systemFontOfSize:14];
        nameLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
        nameLabel.numberOfLines = 1;
        [self addSubview:nameLabel];
        self.nameLabel = nameLabel;
    
        /** 3.suosuLabel */
        UILabel *suosuLabel = [[UILabel alloc] init];
        suosuLabel.font = [UIFont systemFontOfSize:10];
        suosuLabel.textColor = [UIColor colorWithRed:164/255.0 green:164/255.0 blue:164/255.0 alpha:1.0];
        [self addSubview:suosuLabel];
        self.suosuLabel = suosuLabel;
    }
    return self;
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    
    [self setupAttr];
    [self setupFrame];
}

- (void)setupAttr
{
    NSString *avatar = _row[@"avatar"];
    avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], _row[@"avatar"]];
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    NSString *nameLabelText;
    if (!_row[@"nick"] || [_row[@"nick"] isEqualToString:@""] || [_row[@"nick"] isEqual:[NSNull null]]) {
        nameLabelText = _row[@"login_name"];
    } else {
        nameLabelText = _row[@"nick"];
    }
    self.nameLabel.text = [NSString stringWithFormat:@"%@", nameLabelText];
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:_row[@"province_id"] cityId:_row[@"city_id"] andTownId:_row[@"area_id"]];
    if (!addr.length) {
        self.suosuLabel.text = [NSString stringWithFormat:@"%@", _row[@"forum_name"]];
    } else {
        self.suosuLabel.text = [NSString stringWithFormat:@"%@ · %@", _row[@"forum_name"], addr];
    }
}

- (void)setupFrame
{
    self.iconView.frame = CGRectMake(8, 8, 42, 42);
    self.iconView.layer.cornerRadius = self.iconView.bounds.size.height * 0.5;
    self.iconView.layer.masksToBounds = YES;
    
    CGFloat nameLabelMaxW = self.cellW - CGRectGetMaxX(self.iconView.frame) - 8;
    CGSize nameLabelSize = [self.nameLabel.text boundingRectWithSize:CGSizeMake(nameLabelMaxW, 15) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.nameLabel.font} context:nil].size;
    CGFloat nameLabelX = CGRectGetMaxX(self.iconView.frame) + 8;
    CGFloat nameLabelW = self.type ? (self.cellW * 0.5 - nameLabelX - 8): (self.cellW - nameLabelX - 8);
    self.nameLabel.frame = CGRectMake(nameLabelX, 12, nameLabelW, nameLabelSize.height);

    CGSize suosuLabelSize = [self.suosuLabel.text boundingRectWithSize:CGSizeMake(nameLabelMaxW, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.suosuLabel.font} context:nil].size;
    self.suosuLabel.frame = CGRectMake(nameLabelX, CGRectGetMaxY(self.nameLabel.frame) + 4, nameLabelW, suosuLabelSize.height);
}

@end
