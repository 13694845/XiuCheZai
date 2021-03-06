//
//  ChatConfig.m
//  XiuCheZai
//
//  Created by QSH on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatConfig.h"

@implementation ChatConfig

static NSString *const kDefaultHost = @"121.40.149.236";  // @"192.168.2.63";
static NSUInteger const kDefaultPort = 39999;   // 9999;
static NSString *const kTerminator = @"\n";
static NSTimeInterval const kHeartbeatInterval = 20.0;

+ (NSString *)defaultHost {
    return kDefaultHost;
}

+ (NSUInteger)defaultPort {
    return kDefaultPort;
}

+ (NSString *)terminator {
    return kTerminator;
}

+ (NSTimeInterval)heartbeatInterval {
    return kHeartbeatInterval;
}

@end
