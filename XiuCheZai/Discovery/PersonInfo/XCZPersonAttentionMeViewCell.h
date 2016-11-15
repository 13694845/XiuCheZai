//
//  XCZPersonAttentionMeViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/27.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPersonAttentionMeViewCell;

@protocol XCZPersonAttentionMeViewCellDelegate <NSObject>

@optional
- (void)personAttentionMeViewCell:(XCZPersonAttentionMeViewCell *)personAttentionMeViewCell siteCircleLabelDidClick:(int)clazz;

@end

@interface XCZPersonAttentionMeViewCell : UITableViewCell

@property (nonatomic, copy) NSDictionary *row;
@property (nonatomic, weak) id<XCZPersonAttentionMeViewCellDelegate> delegate;

@end
