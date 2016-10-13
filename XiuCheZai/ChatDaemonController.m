//
//  ChatDaemonController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatDaemonController.h"
#import "GCDAsyncSocket.h"

#define HOST        @"192.168.2.63"
#define PORT        9999
#define TERMINATOR  @"\n"

@interface ChatDaemonController () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;
@property (assign, nonatomic) NSUInteger historyPage;

@end

@implementation ChatDaemonController

- (instancetype)init {
    if (self = [super init]) {
        NSLog(@"ok");
        self.senderId = @"555";
        self.senderName = @"zhangsan";
        self.receiverId = @"123";
        self.receiverName = @"lisi";
        
        
    }
    return self;
}

@end
