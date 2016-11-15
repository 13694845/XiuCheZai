//
//  XCZClubCircleHeaderView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/23.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZClubCircleHeaderView;

@protocol XCZClubCircleHeaderViewDelegate <NSObject>

@optional

/** 主View被点击 */
- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView clubOneViewDidClick:(UIView *)clubOneView;
/** 添加按钮被点击 */
- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView addBtnDidClick:(UIButton *)addBtn;
/** 话题|精华|成员按钮被点击 */
- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView clubTwoViewSubBtnDidClick:(UIButton *)btn;

@end

@interface XCZClubCircleHeaderView : UIView

@property (nonatomic, assign) BOOL hasJoin;
@property (nonatomic, strong) NSDictionary *banner;
@property (nonatomic, weak) id<XCZClubCircleHeaderViewDelegate> delegate;


@end
