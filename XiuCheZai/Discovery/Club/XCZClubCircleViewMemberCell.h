//
//  XCZClubCircleViewMemberCell.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/25.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZClubCircleViewMemberCell, XCZClubCircleViewMemberCellTwoView, XCZClubCircleViewMemberCellUserView, XCZClubCircleViewMemberCellUserAddView;

@protocol XCZClubCircleViewMemberCellDelegate <NSObject>

@optional
- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell cellOneViewDidClick:(UIView *)cellOneView;
- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView userViewDidClick:(XCZClubCircleViewMemberCellUserView *)userView;
- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView addViewDidClick:(XCZClubCircleViewMemberCellUserAddView *)addView;


@end


@interface XCZClubCircleViewMemberCell : UITableViewCell

@property (nonatomic, assign) CGFloat cellW;
@property (strong, nonatomic) NSDictionary *hzRow;
@property (nonatomic, strong) NSArray *rows;

@property (nonatomic, weak) id<XCZClubCircleViewMemberCellDelegate> delegate;

@end
