//
//  ChatMessageManager.h
//  XiuCheZai
//
//  Created by QSH on 16/10/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessage.h"

@interface ChatMessageManager : NSObject

+ (instancetype)sharedManager;

- (NSArray *)messagesForReceiverId:(NSString *)receiverId;
- (void)saveMessage:(ChatMessage *)message withReceiverId:(NSString *)receiverId;
- (void)saveMessages:(NSArray *)messages withReceiverId:(NSString *)receiverId;

- (NSInteger)unreadCountForReceiverId:(NSString *)receiverId;
- (void)resetUnreadCountForReceiverId:(NSString *)receiverId;

@end
