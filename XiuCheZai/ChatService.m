//
//  ChatDaemonController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatService.h"
#import "GCDAsyncSocket.h"

#define HOST        @"192.168.2.63"
#define PORT        9999
#define TERMINATOR  @"\n"

@interface ChatService () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;
@property (assign, nonatomic) NSUInteger historyPage;

@end

@implementation ChatService

/*
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
*/




- (void)start {
    NSLog(@"start");
    
    [self startHeartbeat];
    /*
    if (!self.asyncSocket) [self setupSocket];
    [self connectToHost:HOST onPort:PORT];
     */
}

- (void)stop {
    NSLog(@"stop");

}

- (void)startHeartbeat {
    NSLog(@"startHeartbeat");
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(echo) userInfo:nil repeats:YES];
}

- (void)stopHeartbeat {
    NSLog(@"stopHeartbeat");
    if (self.timer.valid) [self.timer invalidate];
}

- (void)echo {
    NSLog(@"AppDelegate : %@", [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"]);
}







- (void)setupSocket {
    NSLog(@"setupSocket");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];

    if (!self.asyncSocket) [self setupSocket];
    [self connectToHost:HOST onPort:PORT];
}

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port {
    NSLog(@"connectToHost");
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"connectToHost : %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    // [self setupHeartbeat];
    NSLog(@"didConnectToHost");

    [self loginWithSenderId:self.senderId];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)loginWithSenderId:(NSString *)senderId {
    NSLog(@"loginWithSenderId");
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", senderId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

@end
