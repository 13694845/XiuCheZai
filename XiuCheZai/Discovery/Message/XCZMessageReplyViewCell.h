//
//  XCZMessageReplyViewCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessageReplyViewCell;

@protocol XCZMessageReplyViewCellDelegate <NSObject>

@optional
- (void)replyViewCell:(XCZMessageReplyViewCell *)replyViewCell replyViewDidClick:(NSDictionary *)row;
- (void)replyViewCell:(XCZMessageReplyViewCell *)replyViewCell brandsViewDidClick:(NSString *)user_id;

@end


@interface XCZMessageReplyViewCell : UITableViewCell

@property (nonatomic, strong) NSDictionary *row;
@property (weak, nonatomic) id <XCZMessageReplyViewCellDelegate> delegate;




@end
