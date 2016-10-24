//
//  ChatConfig.m
//  XiuCheZai
//
//  Created by QSH on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatConfig.h"

@implementation ChatConfig

static NSString *const kDefaultHost = @"192.168.2.63";
static NSUInteger const kDefaultPort = 9999;
static NSTimeInterval const kHeartbeatInterval = 5.0;
static NSString *const kTerminator = @"\n";

+ (NSString *)defaultHost {
    return kDefaultHost;
}

+ (NSUInteger)defaultPort {
    return kDefaultPort;
}

+ (NSTimeInterval)heartbeatInterval {
    return kHeartbeatInterval;
}

+ (NSString *)terminator {
    return kTerminator;
}

@end
