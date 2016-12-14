//
//  XCZCircleDetailGoodsView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleDetailGoodsView.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"

@interface XCZCircleDetailGoodsView()

@property (nonatomic, weak) UIImageView *pictureView;
@property (nonatomic, weak) UILabel *contentLabel;
@property (nonatomic, weak) UILabel *numLabel;
@property (nonatomic, weak) UILabel *priceLabel;

@end

@implementation XCZCircleDetailGoodsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat pictureViewX = 8;
        CGFloat pictureViewY = 8;
        CGFloat pictureViewH = frame.size.height - 16;
        CGFloat pictureViewW = pictureViewH;
        UIImageView *pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(pictureViewX, pictureViewY, pictureViewW, pictureViewH)];
        [self addSubview:pictureView];
        self.pictureView = pictureView;
        
        CGFloat contentLabelX = CGRectGetMaxX(pictureView.frame) + 8;
        CGFloat contentLabelY = 8;
        CGFloat contentLabelW = frame.size.width - contentLabelX - 8;
        CGFloat contentLabelH = pictureViewH * 0.5;
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentLabelX, contentLabelY, contentLabelW, contentLabelH)];
        contentLabel.numberOfLines = 2;
        contentLabel.font = [UIFont systemFontOfSize:14];
        contentLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
        [self addSubview:contentLabel];
        self.contentLabel = contentLabel;
        
        CGFloat priceLabelW = 100;
        CGFloat priceLabelX = frame.size.width - 8 - priceLabelW;
        CGFloat priceLabelH = 18;
        CGFloat priceLabelY = frame.size.height - 8 - priceLabelH + 2;
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH)];
        priceLabel.font = [UIFont systemFontOfSize:16];
        priceLabel.textColor = [UIColor colorWithRed:232/255.0 green:37/255.0 blue:30/255.0 alpha:1.0];
        priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
        
        CGFloat numLabelX = contentLabelX;
        CGFloat numLabelH = 12;
        CGFloat numLabelY = frame.size.height - 8 - numLabelH;
        CGFloat numLabelW = contentLabelW - 8 - priceLabelW;
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(numLabelX, numLabelY, numLabelW, numLabelH)];
        numLabel.font = [UIFont systemFontOfSize:10];
        numLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self addSubview:numLabel];
        self.numLabel = numLabel;
    }
    return self;
}

- (void)setGoods_remark:(NSDictionary *)goods_remark
{
    _goods_remark = goods_remark;
    
    NSString *goods_img = [goods_remark[@"img"] containsString:@"http"] ? [NSString stringWithFormat:@"%@", goods_remark[@"img"]] : [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], goods_remark[@"img"]];
    [self.pictureView sd_setImageWithURL:[NSURL URLWithString:goods_img] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    self.contentLabel.text = goods_remark[@"name"];
    self.numLabel.text = [NSString stringWithFormat:@"共%@件", goods_remark[@"num"]];
    self.priceLabel.text = ([[goods_remark objectForKey:@"amount"] doubleValue] >= 10000) ? [NSString stringWithFormat:@"￥%.2f万", [[goods_remark objectForKey:@"amount"] doubleValue]/10000] : [NSString stringWithFormat:@"￥%@", goods_remark[@"amount"]];
}


@end
