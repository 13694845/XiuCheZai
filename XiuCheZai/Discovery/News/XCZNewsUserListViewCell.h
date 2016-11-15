//
//  XCZNewsUserListViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/8.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewsUserListViewCell;

@protocol XCZNewsUserListViewCellDelegate <NSObject>

@optional
- (void)newsUserListViewCell:(XCZNewsUserListViewCell *)newsUserListViewCell siteCircleLabelDidClick:(int)clazz;

@end

@interface XCZNewsUserListViewCell : UITableViewCell


@property (nonatomic, copy) NSDictionary *row;
@property (nonatomic, weak) id<XCZNewsUserListViewCellDelegate> delegate;

@end
