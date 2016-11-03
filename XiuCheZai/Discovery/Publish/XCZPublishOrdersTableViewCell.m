//
//  XCZPublishOrdersTableViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishOrdersTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZPublishOrdersTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end


@implementation XCZPublishOrdersTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)setOrder_good:(NSDictionary *)order_good
{
    _order_good = order_good;
    
    [self.productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], order_good[@"goods_main_img"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    self.contentLabel.text = order_good[@"goods_name"];
    self.numberLabel.text = [NSString stringWithFormat:@"共%@件", order_good[@"goods_num"]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", order_good[@"amounts"]];
}

- (void)setOrder:(NSDictionary *)order
{
    _order = order;
    
//    NSLog(@"order:%@", order);
//    
    [self.productImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], order[@"goods_main_img"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    self.contentLabel.text = order[@"goods_name"];
    self.numberLabel.text = [NSString stringWithFormat:@"共%@件", order[@"num"]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", order[@"order_amount"]];
}

@end
