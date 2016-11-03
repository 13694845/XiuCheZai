//
//  XCZMessageLogisticsViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageLogisticsViewCell.h"

@interface XCZMessageLogisticsViewCell()

@property (weak, nonatomic) IBOutlet UIView *detailsView;


@end

@implementation XCZMessageLogisticsViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self.detailsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(detailsViewDidClick)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)detailsViewDidClick
{
    if ([self.delegate respondsToSelector:@selector(logisticsViewCell:detailsViewDidClick:)]) {
        [self.delegate logisticsViewCell:self detailsViewDidClick:self.logisticsId];
    }
}

@end
