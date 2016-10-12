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

- (void)saveMessage:(ChatMessage *)message;
- (void)saveMessages:(NSArray *)messages;

@end
