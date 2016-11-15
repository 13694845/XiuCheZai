//
//  XCZClubCircleViewMemberCellTwoView.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZClubCircleViewMemberCellTwoView, XCZClubCircleViewMemberCellUserView, XCZClubCircleViewMemberCellUserAddView;

@protocol XCZClubCircleViewMemberCellTwoViewDelegate <NSObject>

@optional

- (void)clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView userViewDidClick:(XCZClubCircleViewMemberCellUserView *)userView;
- (void)clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView addViewDidClick:(XCZClubCircleViewMemberCellUserAddView *)addView;

@end


@interface XCZClubCircleViewMemberCellTwoView : UIView

@property (nonatomic, assign) CGFloat cellW;
@property (nonatomic, strong) NSArray *rows;

@property (nonatomic, weak) id<XCZClubCircleViewMemberCellTwoViewDelegate> delegate;


@end
