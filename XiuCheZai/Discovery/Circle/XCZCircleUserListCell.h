//
//  XCZCircleUserListCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleUserListCell;

@protocol XCZCircleUserListCellDelegate <NSObject>

@optional
- (void)circleUserListViewCell:(XCZCircleUserListCell *)circleUserListViewCell siteCircleLabelDidClick:(int)clazz;

@end

@interface XCZCircleUserListCell : UITableViewCell

@property (nonatomic, copy) NSString *tieziUser_id;
@property (nonatomic, copy) NSDictionary *row;
@property (nonatomic, weak) id<XCZCircleUserListCellDelegate> delegate;

@end
