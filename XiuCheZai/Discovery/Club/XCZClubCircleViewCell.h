//
//  XCZCircleTableViewCell.h
//  XiuCheZai
//
//  Created by QSH on 16/8/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCZClubCircleViewCell;

@protocol XCZClubCircleViewCellDelegate <NSObject>

@optional
- (void)circleTableViewCell:(XCZClubCircleViewCell *)circleTableViewCell cellHeaderViewDidClick:(UIView *)cellHeaderView;
- (void)circleTableViewCell:(XCZClubCircleViewCell *)circleTableViewCell cellContentViewDidClick:(UIView *)cellContentView;

@end

@interface XCZClubCircleViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *row;
@property (weak, nonatomic) id <XCZClubCircleViewCellDelegate> delegate;

@end