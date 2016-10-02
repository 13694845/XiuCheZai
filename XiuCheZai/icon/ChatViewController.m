//
//  ViewController.m
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "GCDAsyncSocket.h"

@interface ChatViewController () <GCDAsyncSocketDelegate> {
    GCDAsyncSocket *asyncSocket;
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupSocket];
    [self conn];
    [self login];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupSocket {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
}

#define HOST @"192.168.2.63"
#define PORT 9999
- (void)conn {
    NSString *host = HOST;
    uint16_t port = PORT;
    
    NSError *error = nil;
    if (![asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"conn error: %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
}

- (void)send {
    NSString *msg = @"{\"type\":\"TEST\"}\n";
    
    NSString *requestStr = msg;
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    
    // [asyncSocket readDataWithTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSLog(@"didWriteDataWithTag");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"didReadData : %@", msg);
}

- (void)login {
    NSString *msg = @"{\"type\":\"LOGIN\", \"sender_id\":\"555\"}\n";
    
    NSString *requestStr = msg;
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [asyncSocket writeData:requestData withTimeout:-1.0 tag:0];
    
    // [asyncSocket readDataWithTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

@end
