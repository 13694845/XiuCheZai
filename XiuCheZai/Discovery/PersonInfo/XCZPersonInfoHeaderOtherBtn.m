//
//  XCZPersonInfoHeaderOtherBtn.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoHeaderOtherBtn.h"

@interface XCZPersonInfoHeaderOtherBtn()




@end

@implementation XCZPersonInfoHeaderOtherBtn

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /** 2.valueLabel */
        UILabel *valueLabel = [[UILabel alloc] init];
        valueLabel.font = [UIFont systemFontOfSize:16];
        valueLabel.textColor = [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0];
        valueLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:valueLabel];
        self.valueLabel = valueLabel;
        
        /** 1.ziLabel */
        UILabel *ziLabel = [[UILabel alloc] init];
        ziLabel.font = [UIFont systemFontOfSize:10];
        ziLabel.textColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0];
        ziLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:ziLabel];
        self.ziLabel = ziLabel;

        /** 3.竖线 */
        UILabel *lineLabel = [[UILabel alloc] init];
        lineLabel.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
        lineLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lineLabel];
        self.lineLabel = lineLabel;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupFrame];
}

- (void)setupFrame
{
    self.valueLabel.frame = CGRectMake(0, -2 + _deatY, self.bounds.size.width - 1, 14);
    self.ziLabel.frame = CGRectMake(0, 16 + _deatY, self.bounds.size.width - 1, 18);
    self.lineLabel.frame = CGRectMake(self.bounds.size.width - 1, 0, 1, 32);
}

@end













