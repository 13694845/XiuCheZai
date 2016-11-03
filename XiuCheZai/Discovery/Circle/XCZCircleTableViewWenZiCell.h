//
//  XCZCircleTableViewWenZiCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZCircleTableViewWenZiCell;

@protocol XCZCircleTableViewWenZiCellDelegate <NSObject>

@optional

- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row;
- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row;

@end

@interface XCZCircleTableViewWenZiCell : UITableViewCell

@property (assign, nonatomic) CGFloat selfW;
@property (assign, nonatomic) int sourceType;
@property (strong, nonatomic) NSDictionary *row;

@property (weak, nonatomic) id <XCZCircleTableViewWenZiCellDelegate> delegate;

@end
