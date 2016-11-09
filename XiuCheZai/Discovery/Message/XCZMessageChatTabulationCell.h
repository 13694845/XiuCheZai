//
//  XCZMessageChatTabulationCell.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/30.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XCZMessageChatTabulationCell : UITableViewCell

/** 未读聊天数目 */
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) NSDictionary *row;

@end
