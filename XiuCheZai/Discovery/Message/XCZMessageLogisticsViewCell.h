//
//  XCZMessageLogisticsViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessageLogisticsViewCell;

@protocol XCZMessageLogisticsViewCellDelegate <NSObject>

@optional
- (void)logisticsViewCell:(XCZMessageLogisticsViewCell *)logisticsViewCell detailsViewDidClick:(NSString *)recommendedId;

@end

@interface XCZMessageLogisticsViewCell : UITableViewCell

@property(nonatomic, strong)NSString *logisticsId;
@property (weak, nonatomic) id <XCZMessageLogisticsViewCellDelegate> delegate;


@end
