//
//  ChatSocketManager.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatSocketManager.h"
#import "GCDAsyncSocket.h"

#define HOST        @"192.168.2.63"
#define PORT        9999
#define TERMINATOR  @"\n"

@interface ChatSocketManager () <GCDAsyncSocketDelegate>

@end

@implementation ChatSocketManager

+ (instancetype)sharedManager {
    static ChatSocketManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
