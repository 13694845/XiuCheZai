//
//  XCZMessageReplyViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageReplyViewCell.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZCityManager.h"

@interface XCZMessageReplyViewCell()

//@property (weak, nonatomic) IBOutlet UIView *brandsView;
//@property (weak, nonatomic) IBOutlet UIView *replyView;

@property (weak, nonatomic) IBOutlet UIView *brandsView;
@property (weak, nonatomic) IBOutlet UIImageView *brandsImageView;
@property (weak, nonatomic) UILabel *headerNameLabel;
@property (weak, nonatomic) UIImageView *headerIconView;
@property (weak, nonatomic) IBOutlet UILabel *brandsSuosuLabel;
@property (weak, nonatomic) IBOutlet UIButton *brandsHuifuBtn;

@property (weak, nonatomic) IBOutlet UIView *replyView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentBackImageView;
@property (weak, nonatomic) IBOutlet UILabel *replyTextLabel;


@end

@implementation XCZMessageReplyViewCell

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
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    self.brandsHuifuBtn.layer.borderColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0].CGColor;
    self.brandsHuifuBtn.layer.borderWidth = 0.5;
    self.brandsHuifuBtn.layer.cornerRadius = 5.0;
    self.brandsHuifuBtn.layer.masksToBounds = YES;
    
    UIImage *image = [UIImage imageNamed:@"bbs_dongDuiHuaKuang"];
    self.contentBackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
    
    [self.brandsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(brandsViewDidClick)]];
    [self.replyView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyViewViewDidClick)]];
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
    self.brandsImageView.layer.cornerRadius = self.brandsImageView.bounds.size.height * 0.5;
    self.brandsImageView.layer.masksToBounds = YES;
    
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

    self.titleLabel.text = _row[@"content"];
    NSString *replyShowText = [self.row[@"clazz"] intValue] == 1 ? @"回复我的主题" : @"回复我的评论";
    self.replyTextLabel.text = [NSString stringWithFormat:@"%@: %@", replyShowText, _row[@"reply_content"]];
    
    CGSize headerNameLabelSize = [self.headerNameLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 100, 50) options:NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName : self.headerNameLabel.font} context:nil].size;
    self.headerNameLabel.frame = CGRectMake(64, 12, headerNameLabelSize.width, headerNameLabelSize.height);
    self.headerIconView.frame = CGRectMake(CGRectGetMaxX(self.headerNameLabel.frame), self.headerNameLabel.frame.origin.y, self.headerNameLabel.bounds.size.height, self.headerNameLabel.bounds.size.height);
}

- (void)brandsViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(replyViewCell:brandsViewDidClick:)]) {
        [self.delegate replyViewCell:self brandsViewDidClick:self.row[@"user_id"]];
    }
}

- (void)replyViewViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(replyViewCell:replyViewDidClick:)]) {
        [self.delegate replyViewCell:self replyViewDidClick:self.row];
    }
}

@end
