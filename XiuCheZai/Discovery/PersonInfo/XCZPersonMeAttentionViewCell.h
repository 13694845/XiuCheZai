//
//  XCZPersonMeAttentionViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/28.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZPersonMeAttentionViewCell;

@protocol XCZPersonMeAttentionViewCellDelegate <NSObject>

@optional
- (void)personMeAttentionViewCell:(XCZPersonMeAttentionViewCell *)personMeAttentionViewCell siteCircleLabelDidClick:(int)clazz;

@end

@interface XCZPersonMeAttentionViewCell : UITableViewCell

/** 是否不显示关注 YES:不显示关注, NO:显示关注 */
@property (nonatomic, assign) BOOL isNoShowGuanzhu;
@property (nonatomic, copy) NSDictionary *row;
@property (nonatomic, weak) id<XCZPersonMeAttentionViewCellDelegate> delegate;

@end
