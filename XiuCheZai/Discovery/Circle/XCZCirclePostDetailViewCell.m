//
//  XCZCirclePostDetailViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/2.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCirclePostDetailViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZCirclePostDetailViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end

@implementation XCZCirclePostDetailViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setOrder_good:(NSDictionary *)order_good
{
    _order_good = order_good;

    [self.productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], order_good[@"goods_main_img"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    self.contentLabel.text = order_good[@"goods_name"];
    self.numberLabel.text = [NSString stringWithFormat:@"共%@件", order_good[@"goods_num"]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", order_good[@"price3"]];
}

@end
