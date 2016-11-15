//
//  XCZMessagePraiseViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessagePraiseViewCell;

@protocol XCZMessagePraiseViewCellDelegate <NSObject>

@optional
- (void)praiseViewCell:(XCZMessagePraiseViewCell *)praiseViewCell praiseViewDidClick:(NSDictionary *)row;
- (void)praiseViewCell:(XCZMessagePraiseViewCell *)praiseViewCell brandsViewDidClick:(NSDictionary *)row;

@end

@interface XCZMessagePraiseViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *row;
@property (weak, nonatomic) id <XCZMessagePraiseViewCellDelegate> delegate;

@end
