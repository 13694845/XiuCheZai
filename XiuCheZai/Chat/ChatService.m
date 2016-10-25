//
//  ChatService.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatService.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "GCDAsyncSocket.h"
#import "ChatConfig.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"

@interface ChatService () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *host;
@property (assign, nonatomic) NSUInteger port;

@property (strong, readwrite, nonatomic) NSString *senderId;
@property (strong, readwrite, nonatomic) NSString *senderName;
@property (strong, readwrite, nonatomic) NSString *senderAvatar;

@end

@implementation ChatService

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (void)start {
    NSLog(@"start");
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![[responseObject objectForKey:@"statu"] isEqualToString:@"0"]) return;
        NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ContactServlet.do"];
        NSDictionary *parameters = nil;
        [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *senderInfo = [[responseObject objectForKey:@"data"] firstObject];
            self.senderId = senderInfo[@"user_id"];
            self.senderName = senderInfo[@"nick"];
            self.senderAvatar = senderInfo[@"avatar"];
            NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ContactChannelNumServlet.do"];
            NSDictionary *parameters = @{@"terminal":@"1"};
            [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                self.host = [responseObject objectForKey:@"ip"] ? : [ChatConfig defaultHost];
                self.port = [[responseObject objectForKey:@"port"] integerValue] ? : [ChatConfig defaultPort];
                [self startService];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)startService {
    NSLog(@"startService");
    if (!self.asyncSocket) [self setupSocket];
    if (!self.asyncSocket.isConnected) [self connectToHost:self.host onPort:self.port];
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
    NSLog(@"connectToHost : %@ %ld", self.host, self.port);
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) NSLog(@"connectToHost : %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
    [self loginWithSenderId:self.senderId];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect : %@ %ld", self.host, self.port);
}

- (void)loginWithSenderId:(NSString *)senderId {
    NSLog(@"loginWithSenderId : %@", senderId);
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", senderId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[[ChatConfig terminator] dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)echo {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[[ChatConfig terminator] dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page {
    NSLog(@"historyMessagesForSenderId");
    NSString *messageFormat = @"{\"type\":\"CHATHISTORY\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"send_time\":\"%@\", \"NowPage\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, senderId, receiverId, sendTime, page];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\", \"contact\":\"1\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, sender[@"sender_id"], receiver[@"receiver_id"], sender[@"sender_name"], receiver[@"receiver_name"], content, type, @"-1"];
    NSLog(@"sendMessage : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *type = message[@"type"];
    if ([type isEqualToString:@"LOGIN"]) [self handleLogin:message];
    if ([type isEqualToString:@"RECEIPT"]) [self handleReceipt:message];
    if ([type isEqualToString:@"MESSAGE"]) [self handleReceive:message];
    if ([type isEqualToString:@"CHATHISTORY"]) [self handleHistory:message];
    if ([type isEqualToString:@"ECHO"]) [self handleEcho:message];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)handleLogin:(NSDictionary *)message {
    NSLog(@"handleLogin");
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
        [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:chatMessage.senderId];
    }
    [self startHeartbeat];
    NSDictionary *sender = @{@"senderId":self.senderId, @"senderName":self.senderName, @"senderAvatar":self.senderAvatar};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZChatServiceDidHandleLogin" object:nil userInfo:@{@"sender":sender}];
}

- (void)startHeartbeat {
    NSLog(@"startHeartbeat");
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:[ChatConfig heartbeatInterval] target:self selector:@selector(echo) userInfo:nil repeats:YES];
}

- (void)stopHeartbeat {
    NSLog(@"stopHeartbeat");
    if (self.timer.valid) [self.timer invalidate];
}

- (void)handleEcho:(NSDictionary *)message {
    NSLog(@"handleEcho");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZChatServiceDidHandleEcho" object:nil userInfo:@{@"echoMessage":message}];
}

- (void)handleHistory:(NSDictionary *)message {
    NSMutableArray *historyMessages = [NSMutableArray array];
    for (NSDictionary *msg in message[@"content"]) {
        ChatMessage *chatMessage = [[ChatMessage alloc] init];
        chatMessage.isSend = [[msg[@"sender_id"] description] isEqualToString:self.senderId];
        chatMessage.type = msg[@"msg_type"];
        chatMessage.content = msg[@"msg_content"];
        chatMessage.playTime = msg[@"play_time"];
        chatMessage.senderTime = msg[@"send_time"];
        chatMessage.senderId = msg[@"sender_id"];
        chatMessage.senderName = msg[@"sender_name"];
        chatMessage.receiverId = msg[@"receiver_id"];
        chatMessage.receiverName = msg[@"receiver_name"];
        [historyMessages addObject:chatMessage];
    }
    if (historyMessages.count) {
        ChatMessage *aMessage = historyMessages.firstObject;
        [[ChatMessageManager sharedManager] saveMessages:historyMessages withReceiverId:(aMessage.isSend ? aMessage.receiverId : aMessage.senderId)];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZChatServiceDidHandleHistory" object:nil userInfo:@{@"historyMessages":historyMessages}];
}

- (void)handleReceipt:(NSDictionary *)message {
    NSLog(@"handleReceipt %@ : ", message);
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:[message[@"msg"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    ChatMessage *chatMessage = [[ChatMessage alloc] init];
    chatMessage.isSend = YES;
    chatMessage.type = msg[@"msg_type"];
    chatMessage.content = msg[@"msg_content"];
    chatMessage.playTime = msg[@"play_time"];
    chatMessage.senderTime = msg[@"send_time"];
    chatMessage.senderId = msg[@"sender_id"];
    chatMessage.senderName = msg[@"sender_name"];
    chatMessage.receiverId = msg[@"receiver_id"];
    chatMessage.receiverName = msg[@"receiver_name"];
    [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:chatMessage.receiverId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZChatServiceDidHandleReceipt" object:nil userInfo:@{@"receiptMessage":chatMessage}];
}

- (void)handleReceive:(NSDictionary *)message {
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
    [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:chatMessage.senderId];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZChatServiceDidHandleReceive" object:nil userInfo:@{@"receiveMessage":chatMessage}];
}

@end
