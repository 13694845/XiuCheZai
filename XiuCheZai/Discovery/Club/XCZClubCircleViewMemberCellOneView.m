//
//  XCZClubCircleViewMemberCellOneView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewMemberCellOneView.h"
#import "XCZClubCircleViewMemberCellUserView.h"
#import "DiscoveryConfig.h"

@interface XCZClubCircleViewMemberCellOneView()

/** 1.头部部分 */
@property (nonatomic, weak)  UIView *headerView;
/** 1.1.会长Label */
@property (nonatomic, weak) UILabel *hzLabel;
/** 1.2.中间分割线 */
@property (nonatomic, weak) UIView *middleLineView;
/** 2.userView */
@property (nonatomic, weak) XCZClubCircleViewMemberCellUserView *userView;
/** 3.底部分割线 */
@property (nonatomic, weak) UIView *bottomLineView;

@end

@implementation XCZClubCircleViewMemberCellOneView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        
        UIView *headerView = [[UIView alloc] init];
        headerView.backgroundColor = [UIColor whiteColor];
        [self addSubview:headerView];
        self.headerView = headerView;
        
        UILabel *hzLabel = [[UILabel alloc] init];
        hzLabel.font = [UIFont systemFontOfSize:12];
        hzLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [headerView addSubview:hzLabel];
        self.hzLabel = hzLabel;
        
        UIView *middleLineView = [[UIView alloc] init];
        middleLineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [headerView addSubview:middleLineView];
        self.middleLineView = middleLineView;
        
        XCZClubCircleViewMemberCellUserView *userView = [[XCZClubCircleViewMemberCellUserView alloc] init];
        [self addSubview:userView];
        self.userView = userView;
        
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [self addSubview:bottomLineView];
        self.bottomLineView = bottomLineView;
    }
    return self;
}

- (void)setHzRow:(NSDictionary *)hzRow
{
    _hzRow = hzRow;
    
    self.hzLabel.text = @"会长";
    self.userView.cellW = self.cellW;
    self.userView.type = 0;
    self.userView.row = hzRow;
    
    CGSize hzLabelSize = [self.hzLabel.text boundingRectWithSize:CGSizeMake(self.cellW * 0.5, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.hzLabel.font} context:nil].size;
    self.hzLabel.frame = CGRectMake(16, 8, hzLabelSize.width, hzLabelSize.height);
    self.middleLineView.frame = CGRectMake(8, CGRectGetMaxY(self.hzLabel.frame) + 8, self.cellW - 16, 1.0);
    self.headerView.frame = CGRectMake(0, 0, self.cellW, CGRectGetMaxY(self.middleLineView.frame));
    self.userView.frame = CGRectMake(0, CGRectGetMaxY(self.middleLineView.frame), self.cellW, 58);
    self.bottomLineView.frame = CGRectMake(8, CGRectGetMaxY(self.userView.frame), self.cellW, 1.0);
}



@end
