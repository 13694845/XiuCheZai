//
//  ViewController.m
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "GCDAsyncSocket.h"

@interface ChatViewController () <GCDAsyncSocketDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;

@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *emotionButton;
@property (weak, nonatomic) IBOutlet UIButton *othersButton;

@end

@implementation ChatViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        for (UIView *view in cell.subviews){
            [view removeFromSuperview];
        }
    }
    cell.textLabel.text = @"textLabel";
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.rows = [@[@"aaa", @"bbb", @"ccc"] mutableCopy];
}

- (void)viewDidAppear:(BOOL)animated {
    [self setupSocket];
    [self conn];
    // [self send];
    
    [self loginWithUserId:@"123"];
    // [self sendMessageFromSender:@{@"sender_id":@"555", @"sender_name":@"zhangsan"} toReceiver:@{@"receiver_id":@"123", @"receiver_name":@"lisi"} withContent:@"content" type:@"txt"];
    
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
    // NSLog(@"didConnectToHost");
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
    // NSLog(@"didWriteDataWithTag");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"didReadData : %@", msg);
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"json : %@", json);
    
    NSString *type = json[@"type"];
    // NSLog(@"type : %@", type);
    
    if ([type isEqualToString:@"LOGIN"]) {
        // NSLog(@"LOGIN : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"MESSAGE"]) {
        // NSLog(@"MESSAGE : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"CHATHISTORY"]) {
        // NSLog(@"CHATHISTORY : %@", json[@"content"]);
    }
    
    if ([type isEqualToString:@"ECHO"]) {
        // NSLog(@"ECHO : %@", json[@"content"]);
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    // NSLog(@"socketDidDisconnect error: %@", err);
}

- (void)loginWithUserId:(NSString *)userId {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", userId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [@"\n" dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\", \"contact\":\"0\"}\n";
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

- (IBAction)showEmotionPad:(id)sender {
    NSLog(@"showEmotionPad");
    NSString *content = self.textView.text;
    if (content)
        [self sendMessageFromSender:@{@"sender_id":@"555", @"sender_name":@"zhangsan"} toReceiver:@{@"receiver_id":@"123", @"receiver_name":@"lisi"} withContent:content type:@"txt"];
}

@end
