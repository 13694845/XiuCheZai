//
//  XCZPersonAttentionClubViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/27.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonAttentionClubViewCell.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"

@interface XCZPersonAttentionClubViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuLabel;


@end

@implementation XCZPersonAttentionClubViewCell

- (void)setRow:(NSDictionary *)row
{
    _row = row;

    NSString *avatar = row[@"avatar"];
    if (![avatar containsString:@"http"]) {
        avatar = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], avatar];
    }

    [self.iconView sd_setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
    self.nameLabel.text = row[@"forum_name"];
    self.miaoshuLabel.text = row[@"forum_remark"];
}


@end
