//
//  ChatMessage.h
//  XiuCheZai
//
//  Created by QSH on 16/10/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatMessage : NSObject

@property (assign, nonatomic) BOOL isSend;

@property (copy, nonatomic) NSString *type;
@property (copy, nonatomic) NSString *content;
@property (copy, nonatomic) NSString *playTime;

@property (copy, nonatomic) NSString *senderTime;
@property (copy, nonatomic) NSString *senderId;
@property (copy, nonatomic) NSString *senderName;
@property (copy, nonatomic) NSString *receiverId;
@property (copy, nonatomic) NSString *receiverName;

@end
