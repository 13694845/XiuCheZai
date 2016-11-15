//
//  XCZMessageRecommendedViewCell.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageRecommendedViewCell.h"

@interface XCZMessageRecommendedViewCell()

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *contentViews;


@end

@implementation XCZMessageRecommendedViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    for (UIView *contentView in self.contentViews) {
        [contentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentViewDidClick:)]];
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)contentViewDidClick:(UIGestureRecognizer *)grz
{
    if ([self.delegate respondsToSelector:@selector(recommendedViewCell:contentViewDidClick:)]) {
        [self.delegate recommendedViewCell:self contentViewDidClick:self.recommendedId];
    }
}

@end
