//
//  ViewController.m
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "GCDAsyncSocket.h"

@interface ChatViewController () <GCDAsyncSocketDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (nonatomic) NSTimer *timer;

@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupSocket];
    [self conn];
    // [self send];
    // [self loginWithUserId:@"555"];
    
    [self sendMessageFromSender:@{@"sender_id":@"555", @"sender_name":@"zhangsan"} toReceiver:@{@"receiver_id":@"123", @"receiver_name":@"lisi"} withContent:@"content" type:@"txt"];
    // [self historyMessagesForSenderId:@"555" receiverId:@"123" sendTime:@"2016-10-10" page:@"1"];
    
    // [self heartbeat];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSocket {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
}

#define HOST @"192.168.2.63"
#define PORT 9999
- (void)conn {
    NSString *host = HOST;
    uint16_t port = PORT;
    
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"conn error: %@", error);
    }
    
    // [self setupTimer];
}

- (void)setupTimer {
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:YES];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
}

- (void)send {
    NSString *msg = @"{\"type\":\"TEST\"}\n";
    
    NSString *requestStr = msg;
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    
    // [asyncSocket readDataWithTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReadData : %@", msg);
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    // NSLog(@"json : %@", json);
    
    NSString *type = json[@"type"];
    NSLog(@"type : %@", type);
    
    if ([type isEqualToString:@"LOGIN"]) {
        NSLog(@"LOGIN : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"MESSAGE"]) {
        NSLog(@"MESSAGE : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"CHATHISTORY"]) {
        NSLog(@"CHATHISTORY : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"ECHO"]) {
        NSLog(@"ECHO : %@", json[@"content"]);
    }
}

- (void)loginWithUserId:(NSString *)userId {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", userId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, sender[@"sender_id"], receiver[@"receiver_id"], sender[@"sender_name"], receiver[@"receiver_name"], content, type, @"-1"];
    NSLog(@"sendMessage : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page {
    NSString *messageFormat = @"{\"type\":\"CHATHISTORY\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"send_time\":\"%@\", \"NowPage\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, senderId, receiverId, sendTime, page];
    NSLog(@"historyMessages : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)heartbeat {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

@end
