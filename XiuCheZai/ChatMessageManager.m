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

@end
