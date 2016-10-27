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
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePathForReceiverId:receiverId]];
}

- (void)saveMessage:(ChatMessage *)message withReceiverId:(NSString *)receiverId {
    [self saveMessages:@[message] withReceiverId:receiverId];
}

- (void)saveMessages:(NSArray *)messages withReceiverId:(NSString *)receiverId {
    NSMutableArray *exsitMessages = [[self messagesForReceiverId:receiverId] mutableCopy];
    if (!exsitMessages) exsitMessages = [NSMutableArray array];
    [exsitMessages addObjectsFromArray:messages];
    [NSKeyedArchiver archiveRootObject:exsitMessages toFile:[self filePathForReceiverId:receiverId]];
    
    [self saveUnreadCount:([self unreadCountForReceiverId:receiverId] + messages.count) withReceiverId:receiverId];
}

- (NSString *)filePathForReceiverId:(NSString *)receiverId {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [documentDirectories.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.msg", receiverId]];
    return filePath;
}

- (NSInteger)unreadCountForReceiverId:(NSString *)receiverId {
    NSMutableDictionary *unreadCounter = [NSMutableDictionary dictionaryWithContentsOfFile:[self filePathForUnreadCounter]];
    return [unreadCounter[receiverId] integerValue];
}

- (void)saveUnreadCount:(NSUInteger)unreadCount withReceiverId:(NSString *)receiverId {
    NSMutableDictionary *unreadCounter = [NSMutableDictionary dictionaryWithContentsOfFile:[self filePathForUnreadCounter]];
    if (!unreadCounter) unreadCounter = [NSMutableDictionary dictionary];
    unreadCounter[receiverId] = [NSNumber numberWithInteger:unreadCount];
    [unreadCounter writeToFile:[self filePathForUnreadCounter] atomically:YES];
}

- (void)resetUnreadCountForReceiverId:(NSString *)receiverId {
    [self saveUnreadCount:0 withReceiverId:receiverId];
}

- (NSString *)filePathForUnreadCounter {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [documentDirectories.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"unread.cnt"]];
    return filePath;
}

@end
