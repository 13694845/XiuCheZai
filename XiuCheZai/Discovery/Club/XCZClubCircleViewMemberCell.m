//
//  XCZClubCircleViewMemberCell.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewMemberCell.h"
#import "XCZClubCircleViewMemberCellOneView.h"
#import "XCZClubCircleViewMemberCellTwoView.h"
#import "XCZClubCircleViewMemberCellUserView.h"
#import "XCZClubCircleViewMemberCellUserAddView.h"

@interface XCZClubCircleViewMemberCell()<XCZClubCircleViewMemberCellTwoViewDelegate>

@property (nonatomic, weak) XCZClubCircleViewMemberCellOneView *cellOneView;
@property (nonatomic, weak) XCZClubCircleViewMemberCellTwoView *cellTwoView;

@end

@implementation XCZClubCircleViewMemberCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        if ([self.reuseIdentifier isEqualToString:@"CellE"]) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            XCZClubCircleViewMemberCellOneView *cellOneView = [[XCZClubCircleViewMemberCellOneView alloc] init];
            cellOneView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
            [self.contentView addSubview:cellOneView];
            self.cellOneView = cellOneView;
        }
        
        if ([self.reuseIdentifier isEqualToString:@"CellF"]) {
            self.selectionStyle = UITableViewCellSelectionStyleNone;
            XCZClubCircleViewMemberCellTwoView *cellTwoView = [[XCZClubCircleViewMemberCellTwoView alloc] init];
            cellTwoView.delegate = self;
            [self addSubview:cellTwoView];
            self.cellTwoView = cellTwoView;
        }
    }
    return self;
}

- (void)setHzRow:(NSDictionary *)hzRow
{
    _hzRow = hzRow;
    self.cellOneView.cellW = self.cellW;
    self.cellOneView.hzRow = hzRow;
    
    [self setupHzFrame];
    [self.cellOneView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellOneViewDidClick:)]];
}

- (void)setRows:(NSArray *)rows
{
    _rows = rows;
    
    self.cellTwoView.cellW = self.cellW;
    self.cellTwoView.rows = rows;
    [self setupRowsFrame];
}

- (void)setupHzFrame
{
    if ([self.reuseIdentifier isEqualToString:@"CellE"]) {
       self.cellOneView.frame = CGRectMake(0, 0, self.cellW, 98);
    }
}

- (void)setupRowsFrame
{
    if ([self.reuseIdentifier isEqualToString:@"CellF"]) {
        CGFloat height;
        CGFloat dheight = 58;
        height = 31 + (self.rows.count + 1) * dheight;
        self.cellTwoView.frame = CGRectMake(0, 0, self.cellW, self.cellTwoView.bounds.size.height);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"clubCircleViewMemberCellHeightToVC" object:nil userInfo:@{@"cellTwoViewHeight": [NSString stringWithFormat:@"%f", self.cellTwoView.bounds.size.height]}];
    }
}

#pragma mark - 按钮点击
- (void)cellOneViewDidClick:(UIGestureRecognizer *)grz
{
    UIView *cellOneView = grz.view;
    if ([self.delegate respondsToSelector:@selector(clubCircleViewMemberCell:cellOneViewDidClick:)]) {
//        NSLog(@"hzRowhzRowhzRow:%@", self);
        [self.delegate clubCircleViewMemberCell:self cellOneViewDidClick:cellOneView];
    }
}

#pragma mark - 代理方法
- (void)clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView userViewDidClick:(XCZClubCircleViewMemberCellUserView *)userView
{
    if ([self.delegate respondsToSelector:@selector(clubCircleViewMemberCell:clubCircleViewMemberCellTwoView:userViewDidClick:)]) {
        [self.delegate clubCircleViewMemberCell:self clubCircleViewMemberCellTwoView:memberCellTwoView userViewDidClick:userView];
    }
}

- (void)clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView addViewDidClick:(XCZClubCircleViewMemberCellUserAddView *)addView
{
    if ([self.delegate respondsToSelector:@selector(clubCircleViewMemberCell:clubCircleViewMemberCellTwoView:addViewDidClick:)]) {
        [self.delegate clubCircleViewMemberCell:self clubCircleViewMemberCellTwoView:memberCellTwoView addViewDidClick:addView];
    }
}


@end
