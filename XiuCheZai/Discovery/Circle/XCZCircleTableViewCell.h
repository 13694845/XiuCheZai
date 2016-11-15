//
//  XCZCircleTableViewCell.h
//  XiuCheZai
//
//  Created by QSH on 16/8/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCZCircleTableViewCell;

@protocol XCZCircleTableViewCellDelegate <NSObject>

@optional
- (void)circleTableViewCell:(XCZCircleTableViewCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row;
- (void)circleTableViewCell:(XCZCircleTableViewCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row;

@end

@interface XCZCircleTableViewCell : UITableViewCell

@property (strong, nonatomic) NSDictionary *row;
@property (weak, nonatomic) id <XCZCircleTableViewCellDelegate> delegate;

@end