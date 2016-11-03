//
//  XCZClubCircleViewMemberCellTwoView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewMemberCellTwoView.h"
#import "XCZClubCircleViewMemberCellUserView.h"
#import "XCZClubCircleViewMemberCellUserAddView.h"
#import "DiscoveryConfig.h"

@interface XCZClubCircleViewMemberCellTwoView()

/** 1.头部部分 */
@property (nonatomic, weak)  UIView *headerView;
/** 1.1.会长Label */
@property (nonatomic, weak) UILabel *hzLabel;
/** 1.2.中间分割线 */
@property (nonatomic, weak) UIView *middleLineView;
/** 2.底部分割线 */
@property (nonatomic, weak) UIView *bottomLineView;

/** 3.缓存字典 */
@property (nonatomic, strong) NSMutableDictionary *cachesUserView;

@end


@implementation XCZClubCircleViewMemberCellTwoView

- (NSMutableDictionary *)cachesUserView
{
    if (!_cachesUserView) {
        _cachesUserView = [NSMutableDictionary dictionary];
    }
    return _cachesUserView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
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

        
        UIView *bottomLineView = [[UIView alloc] init];
        bottomLineView.backgroundColor = kXCDIVIDINGLINEANDCALLOUTCOLOR;
        [self addSubview:bottomLineView];
        self.bottomLineView = bottomLineView;
    }
    return self;
}

- (void)setRows:(NSArray *)rows
{
    _rows = rows;
    
    if (rows.count) {
        self.hzLabel.text = @"全部成员";
        CGSize hzLabelSize = [self.hzLabel.text boundingRectWithSize:CGSizeMake(self.cellW * 0.5, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.hzLabel.font} context:nil].size;
        self.hzLabel.frame = CGRectMake(16, 8, hzLabelSize.width, hzLabelSize.height);
        self.middleLineView.frame = CGRectMake(8, CGRectGetMaxY(self.hzLabel.frame) + 8, self.cellW - 16, 1.0);
        self.headerView.frame = CGRectMake(0, 0, self.cellW, CGRectGetMaxY(self.middleLineView.frame));
        XCZClubCircleViewMemberCellUserAddView *addView = [[XCZClubCircleViewMemberCellUserAddView alloc] init];
        int i = 0;
        CGFloat userViewW = self.cellW * 0.5;
        CGFloat userViewH = 58;
        for (NSDictionary *row in self.rows) {
            XCZClubCircleViewMemberCellUserView *userView = [self.cachesUserView objectForKey:@(i)];
            int liehao = i%2;
            int hanghao = i/2;
            CGFloat userViewX = liehao * userViewW;
            CGFloat userViewY = hanghao * userViewH + CGRectGetMaxY(self.headerView.frame);
            if (!userView) {
                XCZClubCircleViewMemberCellUserView *userView = [[XCZClubCircleViewMemberCellUserView alloc] init];
                userView.tag = i;
                userView.cellW = self.cellW * 0.5;
                userView.row = row;
                userView.frame = CGRectMake(userViewX, userViewY, userViewW, userViewH);
                [self addSubview:userView];
                NSDictionary *userViewDict = [NSDictionary dictionaryWithObject:userView forKey:@(i)];
                [self.cachesUserView addEntriesFromDictionary:userViewDict];
                
                [userView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userViewDidClick:)]
                ];
            }
            
            i++;
            if (i == self.rows.count) { // 最后一个
                addView.cellW = self.cellW;
                CGFloat addViewX = liehao ? 0 : userViewW;
                CGFloat addViewY = liehao ? (userViewY + userViewH): userViewY;
                addView.frame = CGRectMake(addViewX, addViewY, userViewW, userViewH);
//                [self addSubview:addView];
                self.frame = CGRectMake(0, 0, self.cellW, CGRectGetMaxY(addView.frame) - userViewH);
//                [addView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addViewDidClick:)]];
            }
        }
    }
}

- (void)userViewDidClick:(UIGestureRecognizer *)grz
{
    XCZClubCircleViewMemberCellUserView *userView = (XCZClubCircleViewMemberCellUserView *)grz.view;
    if ([self.delegate respondsToSelector:@selector(clubCircleViewMemberCellTwoView:userViewDidClick:)]) {
        [self.delegate clubCircleViewMemberCellTwoView:self userViewDidClick:userView];
    }
}

- (void)addViewDidClick:(UIGestureRecognizer *)grz
{
    XCZClubCircleViewMemberCellUserAddView *addView =  (XCZClubCircleViewMemberCellUserAddView *)grz.view;
    if ([self.delegate respondsToSelector:@selector(clubCircleViewMemberCellTwoView:addViewDidClick:)]) {
        [self.delegate clubCircleViewMemberCellTwoView:self addViewDidClick:addView];
    }
}


@end
