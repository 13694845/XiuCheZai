//
//  XCZPublishOrderTopicProductView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishOrderProductView.h"
#import "UIImageView+WebCache.h"
#import "XCZConfig.h"

@interface XCZPublishOrderProductView()

/** 1.图片 */
@property (nonatomic, weak) UIImageView *imageView;
/** 2.内容 */
@property (nonatomic, weak) UILabel *textLabel;
/** 3.件数 */
@property (nonatomic, weak) UILabel *numberLabel;
/** 4.价格 */
@property (nonatomic, weak) UILabel *priceLabel;

@end

@implementation XCZPublishOrderProductView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *textLabel = [[UILabel alloc] init];
        textLabel.font = [UIFont systemFontOfSize:14];
        [self addSubview:textLabel];
        self.textLabel = textLabel;
        
        UILabel *numberLabel = [[UILabel alloc] init];
        numberLabel.font = [UIFont systemFontOfSize:10];
        numberLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self addSubview:numberLabel];
        self.numberLabel = numberLabel;
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.font = [UIFont systemFontOfSize:17];
        priceLabel.textColor = [UIColor colorWithRed:232/255.0 green:37/255.0 blue:30/255.0 alpha:1.0];
        priceLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = CGRectMake(8, 8, 75, 75);
    CGFloat textLabelX = CGRectGetMaxX(self.imageView.frame) + 8;
    self.textLabel.frame = CGRectMake(textLabelX, 8, self.bounds.size.width - 16 - textLabelX, 35);
    
    CGFloat numberLabelH = 14;
    CGFloat numberLabelW = 75;
    CGFloat numberLabelX = textLabelX;
    CGFloat numberLabelY = CGRectGetMaxY(self.imageView.frame) - numberLabelH;
    self.numberLabel.frame = CGRectMake(numberLabelX, numberLabelY, numberLabelW, numberLabelH);
    
    CGFloat priceLabelW = 138;
    CGFloat priceLabelH = 20;
    CGFloat priceLabelX = self.bounds.size.width - 16 - priceLabelW;
    CGFloat priceLabelY = self.bounds.size.height - 8 - priceLabelH;
    self.priceLabel.frame = CGRectMake(priceLabelX, priceLabelY, priceLabelW, priceLabelH);
}

- (void)setOrder_good:(NSDictionary *)order_good
{
    _order_good = order_good;
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",  [XCZConfig imgBaseURL], order_good[@"goods_main_img"]]] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    self.textLabel.text = order_good[@"goods_name"];
    self.numberLabel.text = [NSString stringWithFormat:@"共%@件", order_good[@"goods_num"]];
    self.priceLabel.text = [NSString stringWithFormat:@"￥%@", order_good[@"amounts"]];
    
}

@end
