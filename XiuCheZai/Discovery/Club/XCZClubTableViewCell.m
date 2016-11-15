//
//  XCZClubTableViewCell.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZClubTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *describeLabel;

@end

@implementation XCZClubTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    [self.iconView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], row[@"forum_style"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    self.nameLabel.text = row[@"forum_name"];
    self.describeLabel.text = row[@"forum_remark"];
}


@end
