//
//  ChatService.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatService.h"
#import "GCDAsyncSocket.h"
#import "ChatConfig.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"

@interface ChatService () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;

@end

@implementation ChatService

- (void)start {
    NSLog(@"startWithSenderId");
    NSDictionary *chatSender = [[NSUserDefaults standardUserDefaults] objectForKey:@"chatSender"];
    self.senderId = chatSender[@"senderId"];
    self.senderName = chatSender[@"senderName"];
    
    if (!self.asyncSocket) [self setupSocket];
    if (!self.asyncSocket.isConnected) [self connectToHost:HOST onPort:PORT];
}

- (void)stop {
    NSLog(@"stop");
    [self stopHeartbeat];
    [self.asyncSocket disconnect];
}

- (void)setupSocket {
    NSLog(@"setupSocket");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
}

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port {
    NSLog(@"connectToHost");
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) NSLog(@"connectToHost : %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
    [self loginWithSenderId:self.senderId];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect : %@", err);
}

- (void)loginWithSenderId:(NSString *)senderId {
    NSLog(@"loginWithSenderId");
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", senderId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)echo {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *type = message[@"type"];
    if ([type isEqualToString:@"LOGIN"]) [self handleLogin:message];
    if ([type isEqualToString:@"MESSAGE"]) [self handleMessage:message];
    if ([type isEqualToString:@"ECHO"]) [self handleEcho:message];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)handleLogin:(NSDictionary *)message {
    NSLog(@"handleLogin %@ : ", message);
    NSArray *offlineMessages = message[@"message"];
    for (NSDictionary *msg in offlineMessages) {
        ChatMessage *chatMessage = [[ChatMessage alloc] init];
        chatMessage.isSend = NO;
        chatMessage.type = msg[@"msg_type"];
        chatMessage.content = msg[@"msg_content"];
        chatMessage.playTime = msg[@"play_time"];
        chatMessage.senderTime = msg[@"send_time"];
        chatMessage.senderId = msg[@"sender_id"];
        chatMessage.senderName = msg[@"sender_name"];
        chatMessage.receiverId = msg[@"receiver_id"];
        chatMessage.receiverName = msg[@"receiver_name"];
        [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:chatMessage.receiverId];
    }
    [self startHeartbeat];
    // [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)startHeartbeat {
    NSLog(@"startHeartbeat");
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(echo) userInfo:nil repeats:YES];
}

- (void)stopHeartbeat {
    NSLog(@"stopHeartbeat");
    if (self.timer.valid) [self.timer invalidate];
}

- (void)handleMessage:(NSDictionary *)message {
    NSLog(@"handleMessage %@ : ", message);
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:[message[@"msg"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    chatMessage.isSend = NO;
    chatMessage.type = msg[@"msg_type"];
    chatMessage.content = msg[@"msg_content"];
    chatMessage.playTime = msg[@"play_time"];
    chatMessage.senderTime = msg[@"send_time"];
    chatMessage.senderId = msg[@"sender_id"];
    chatMessage.senderName = msg[@"sender_name"];
    chatMessage.receiverId = msg[@"receiver_id"];
    chatMessage.receiverName = msg[@"receiver_name"];
    [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:msg[@"sender_id"]];
}

- (void)handleEcho:(NSDictionary *)message {
    NSLog(@"handleEcho %@ : ", message);
}

@end
