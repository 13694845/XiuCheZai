//
//  ChatMessageManager.m
//  XiuCheZai
//
//  Created by QSH on 16/10/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatMessageManager.h"

@implementation ChatMessageManager

+ (instancetype)sharedManager {
    static ChatMessageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (NSArray *)messagesForReceiverId:(NSString *)receiverId {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self fileForReceiverId:receiverId]];
}

- (void)saveMessage:(ChatMessage *)message withReceiverId:(NSString *)receiverId {
    [self saveMessages:@[message] withReceiverId:receiverId];
}

- (void)saveMessages:(NSArray *)messages withReceiverId:(NSString *)receiverId {
    NSMutableArray *messages_ = [[self messagesForReceiverId:receiverId] mutableCopy];
    if (!messages_) messages_ = [NSMutableArray array];
    [messages_ addObjectsFromArray:messages];
    [NSKeyedArchiver archiveRootObject:messages_ toFile:[self fileForReceiverId:receiverId]];
}

- (NSString *)fileForReceiverId:(NSString *)receiverId {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [documentDirectories.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.msg", receiverId]];
}

@end
