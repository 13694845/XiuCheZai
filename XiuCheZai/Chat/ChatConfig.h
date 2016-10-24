//
//  ChatConfig.h
//  XiuCheZai
//
//  Created by QSH on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatConfig : NSObject

#define HOST        @"192.168.2.63"
#define PORT        9999
#define TERMINATOR  @"\n"

+ (NSString *)defaultHost;
+ (NSUInteger)defaultPort;
+ (NSTimeInterval)heartbeatInterval;
+ (NSString *)terminator;

@end
