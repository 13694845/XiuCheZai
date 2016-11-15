//
//  XCZClubBrandsTableViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubBrandsTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZClubBrandsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconVIew;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuLabel;


@end

@implementation XCZClubBrandsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    [self.iconVIew sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL] , row[@"avatar"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    self.nameLabel.text = row[@"forum_name"];
    self.miaoshuLabel.text = row[@"forum_remark"];
}



@end
