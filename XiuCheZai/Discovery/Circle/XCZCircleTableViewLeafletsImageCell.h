//
//  XCZCircleTableViewLeafletsImageCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#define XCZCircleTableViewLeafletsImageCellImageHeight 120

@class XCZCircleTableViewLeafletsImageCell;

@protocol XCZCircleTableViewLeafletsImageCellDelegate <NSObject>

@optional

- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row;
- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row;

@end

@interface XCZCircleTableViewLeafletsImageCell : UITableViewCell

@property (assign, nonatomic) CGFloat selfW;
@property (assign, nonatomic) int sourceType;
@property (strong, nonatomic) NSDictionary *row;
@property (weak, nonatomic) id <XCZCircleTableViewLeafletsImageCellDelegate> delegate;

@end
