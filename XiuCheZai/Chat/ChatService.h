//
//  ChatService.h
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatService : NSObject

@property (strong, readonly, nonatomic) NSString *senderId;
@property (strong, readonly, nonatomic) NSString *senderName;
@property (strong, readonly, nonatomic) NSString *senderAvatar;

- (void)start;
- (void)stop;

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page;
- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type;

@end
