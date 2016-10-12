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

- (void)saveMessage:(ChatMessage *)message {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *filePath = [documentDirectories.firstObject stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.msg", message.receiverId]];
    NSLog(@"filePath : %@", filePath);
    [NSKeyedArchiver archiveRootObject:message toFile:filePath];

}

- (void)saveMessages:(NSArray *)messages {
    
}

@end
