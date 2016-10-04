//
//  ViewController.m
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "GCDAsyncSocket.h"
#import "ChatMessage.h"

@interface ChatViewController () <GCDAsyncSocketDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;

@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *emotionButton;
@property (weak, nonatomic) IBOutlet UIButton *othersButton;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;
@property (assign, nonatomic) NSUInteger historyPage;

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
    }
    /*
    else {
        for (UIView *view in cell.subviews){
            [view removeFromSuperview];
        }
    }
     */
    ChatMessage *message = self.rows[indexPath.row];
    
    NSString *text;
    if (message.isSend) text = [NSString stringWithFormat:@"SEND : %@", message.content];
    else text = [NSString stringWithFormat:@"RECV : %@", message.content];
    cell.textLabel.text = text;
    
    return cell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // **************************
    self.senderId = @"555";
    self.senderName = @"zhangsan";
    self.receiverId = @"123";
    self.receiverName = @"lisi";
    // **************************
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = self.receiverName;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self setupSocket];
    [self connect];
    // [self send];
    
    [self loginWithSenderId:self.senderId];
    // [self sendMessageFromSender:@{@"sender_id":@"555", @"sender_name":@"zhangsan"} toReceiver:@{@"receiver_id":@"123", @"receiver_name":@"lisi"} withContent:@"content" type:@"txt"];
    
    [self historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:@"2016-10-05 13:01:01" page:[NSString stringWithFormat:@"%ld", ++self.historyPage]];
    // [self heartbeat];
    
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSLog(@"returned");
        [self sendMessageWithContent:text];
        return NO;
    }
    return YES;
}


- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    NSLog(@"textViewShouldEndEditing");
    return YES;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setupSocket {
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
}

#define HOST @"192.168.2.63"
#define PORT 9999
#define TERMINATOR @"\n"

- (void)connect {
    NSString *host = HOST;
    uint16_t port = PORT;
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"conn error: %@", error);
    }
    // [self setupTimer];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect error: %@", err);
}

- (void)setupTimer {
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(heartbeat) userInfo:nil repeats:YES];
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    // NSLog(@"didWriteDataWithTag");
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // NSString *m = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    // NSLog(@"didReadData : %@", m);
    
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    // NSLog(@"json : %@", message);
    
    NSString *type = message[@"type"];
    // NSLog(@"type : %@", type);
    
    if ([type isEqualToString:@"LOGIN"]) {
        NSLog(@"LOGIN : %@", message);
        [self handleLogin:message];
    }
    if ([type isEqualToString:@"RECEIPT"]) {
        NSLog(@"RECEIPT : %@", message);
        [self handleReceipt:message];
    }
    if ([type isEqualToString:@"MESSAGE"]) {
        NSLog(@"MESSAGE : %@", message);
        [self handleMessage:message];
    }
    if ([type isEqualToString:@"CHATHISTORY"]) {
        NSLog(@"CHATHISTORY : %@", message);
        [self handleHistory:message];
    }
    if ([type isEqualToString:@"ECHO"]) {
        NSLog(@"ECHO : %@", message);
    }
    /*
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
     */
}



- (void)handleLogin:(NSDictionary *)message {
    /*
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:[message[@"msg"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    [self.rows addObject:[NSString stringWithFormat:@"SEND : %@", msg[@"msg_content"]]];
    [self.tableView reloadData];
     */
}



- (void)handleReceipt:(NSDictionary *)message {
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
    
    // self.rows = [@[chatMessage] mutableCopy];

    
    [self.rows addObject:chatMessage];
    
    // [self.rows addObject:[NSString stringWithFormat:@"SEND : %@", msg[@"msg_content"]]];
    [self.tableView reloadData];
    
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];

}

- (void)handleMessage:(NSDictionary *)message {
    NSLog(@"handleMessage %@ : ", message);
    
    NSDictionary *msg = [NSJSONSerialization JSONObjectWithData:[message[@"msg"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"msg_content : %@", msg[@"msg_content"]);

    [self.rows addObject:[NSString stringWithFormat:@"RECV : %@", msg[@"msg_content"]]];
    [self.tableView reloadData];
}

- (void)handleHistory:(NSDictionary *)message {
    NSMutableArray *chatMessages = [NSMutableArray array];
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
        
        [chatMessages addObject:chatMessage];
    }
    [chatMessages addObjectsFromArray:self.rows];
    self.rows = chatMessages;

    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)loginWithSenderId:(NSString *)senderId {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", senderId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}



- (void)sendMessageWithContent:(NSString *)content {
    [self sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:@"txt"];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\", \"contact\":\"1\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, sender[@"sender_id"], receiver[@"receiver_id"], sender[@"sender_name"], receiver[@"receiver_name"], content, type, @"-1"];
    NSLog(@"sendMessage : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page {
    NSString *messageFormat = @"{\"type\":\"CHATHISTORY\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"send_time\":\"%@\", \"NowPage\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, senderId, receiverId, sendTime, page];
    NSLog(@"historyMessages : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (void)heartbeat {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    NSData *terminatorData = [TERMINATOR dataUsingEncoding:NSASCIIStringEncoding];
    [self.asyncSocket readDataToData:terminatorData withTimeout:-1.0 tag:0];
}

- (IBAction)showEmotionPad:(id)sender {
    NSLog(@"showEmotionPad");
    NSString *content = self.textView.text;
    if (content)
        [self sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:@"txt"];
}

- (IBAction)showVoicePad:(id)sender {
    NSLog(@"showVoicePad");
    [self historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:@"2016-10-04 13:01:01" page:[NSString stringWithFormat:@"%ld", ++self.historyPage]];
}

- (IBAction)showOtherPad:(id)sender {
    NSLog(@"showOtherPad =");
    
    CGRect rect = self.tableView.frame;
    rect.origin.y -= 400.0;
    self.tableView.frame = rect;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect keyboardRect = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect rect = self.view.frame;
    rect.origin.y -= keyboardRect.size.height;
    [UIView animateWithDuration:0.2f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {}];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGRect rect = self.view.frame;
    rect.origin.y = 0;
    [UIView animateWithDuration:0.2f animations:^{
        self.view.frame = rect;
    } completion:^(BOOL finished) {}];
    self.view.frame = rect;
}

@end
