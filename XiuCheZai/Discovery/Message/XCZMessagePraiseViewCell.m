//
//  XCZMessagePraiseViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessagePraiseViewCell.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZCityManager.h"

@interface XCZMessagePraiseViewCell()

@property (weak, nonatomic) IBOutlet UIView *brandsView;
@property (weak, nonatomic) IBOutlet UIImageView *brandsImageView;
@property (weak, nonatomic) UILabel *headerNameLabel;
@property (weak, nonatomic) UIImageView *headerIconView;
@property (weak, nonatomic) IBOutlet UILabel *brandsSuosuLabel;

@property (weak, nonatomic) IBOutlet UIView *praiseView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;


@end

@implementation XCZMessagePraiseViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    
    UILabel *headerNameLabel = [[UILabel alloc] init];
    headerNameLabel.font = [UIFont systemFontOfSize:14];
    headerNameLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    [self.brandsView addSubview:headerNameLabel];
    self.headerNameLabel = headerNameLabel;
    
    UIImageView *headerIconView = [[UIImageView alloc] init];
    [self.brandsView addSubview:headerIconView];
    self.headerIconView = headerIconView;
    UIImage *image = [UIImage imageNamed:@"bbs_dongDuiHuaKuang"];
    self.contentBackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.brandsImageView.layer.cornerRadius = self.brandsImageView.bounds.size.height * 0.5;
    self.brandsImageView.layer.masksToBounds = YES;
    
    [self.brandsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(brandsViewDidClick)]];
    [self.praiseView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(praiseViewDidClick)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    [self setupAttrAndFrame];
}

- (void)setupAttrAndFrame
{
    NSString *avatar;
    if ([_row[@"avatar"] containsString:@"http"]) {
        avatar = _row[@"avatar"];
    } else {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], _row[@"avatar"]];
    }
    [self.brandsImageView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    
    if ([_row[@"brand_name"] isEqualToString:@""]) {
        if (_row[@"nick"] && ![_row[@"nick"] isEqualToString:@""]) {
            self.headerNameLabel.text = [NSString stringWithFormat:@"%@", _row[@"nick"]];
        } else {
            self.headerNameLabel.text = [NSString stringWithFormat:@"%@", _row[@"login_name"]];
        }
    } else {
        if (_row[@"nick"] && ![_row[@"nick"] isEqualToString:@""]) {
           self.headerNameLabel.text = [NSString stringWithFormat:@"%@.%@", _row[@"nick"], _row[@"brand_name"]];
        } else {
           self.headerNameLabel.text = [NSString stringWithFormat:@"%@.%@", _row[@"login_name"], _row[@"brand_name"]];
        }
        
        [self.headerIconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [XCZConfig imgBaseURL], _row[@"brand_logo"]]] placeholderImage:nil];
    }
    
   
     NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceId:_row[@"province_id"] cityId:_row[@"city_id"] andTownId:_row[@"area_id"]];
    
    if (!addr.length) {
        self.brandsSuosuLabel.text = [NSString stringWithFormat:@"%@", _row[@"forum_name"]];
    } else {
        self.brandsSuosuLabel.text = [NSString stringWithFormat:@"%@ · %@", _row[@"forum_name"], addr];
    }
    self.contentLabel.text = [NSString stringWithFormat:@"%@: %@", @"赞了我的帖子", _row[@"content"]];
    
    CGSize headerNameLabelSize = [self.headerNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 100, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.headerNameLabel.font} context:nil].size;
    self.headerNameLabel.frame = CGRectMake(64, 12, headerNameLabelSize.width, headerNameLabelSize.height);
    self.headerIconView.frame = CGRectMake(CGRectGetMaxX(self.headerNameLabel.frame), self.headerNameLabel.frame.origin.y, self.headerNameLabel.bounds.size.height, self.headerNameLabel.bounds.size.height);
}

- (void)brandsViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(praiseViewCell:brandsViewDidClick:)]) {
        [self.delegate praiseViewCell:self brandsViewDidClick:self.row];
    }
}

- (void)praiseViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(praiseViewCell:praiseViewDidClick:)]) {
        [self.delegate praiseViewCell:self praiseViewDidClick:self.row];
    }
}

@end
