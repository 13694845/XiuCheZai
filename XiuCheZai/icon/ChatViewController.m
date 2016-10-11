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

#define HOST        @"192.168.2.63"
#define PORT        9999
#define TERMINATOR  @"\n"

#define BUBBLE_VIEW_MARGIN_TOP  15.0
#define BUBBLE_VIEW_MARGIN_LEFT 12.0
#define BUBBLE_TEXT_PADDING     8.0

typedef NS_ENUM(NSUInteger, TableViewTransform) {
    TableViewTransformNone,
    TableViewTransformTranslate,
    TableViewTransformScale
};

@interface ChatViewController () <GCDAsyncSocketDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;
@property (strong, nonatomic) NSMutableArray *rows;

@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *emotionButton;
@property (weak, nonatomic) IBOutlet UIButton *othersButton;

@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;

@property (strong, nonatomic) NSString *senderId;
@property (strong, nonatomic) NSString *senderName;
@property (strong, nonatomic) NSString *receiverId;
@property (strong, nonatomic) NSString *receiverName;
@property (assign, nonatomic) NSUInteger historyPage;

@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) TableViewTransform tableViewTransform;

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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatMessage *message = self.rows[indexPath.row];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return TextRect.size.height + BUBBLE_TEXT_PADDING * 2 + BUBBLE_VIEW_MARGIN_TOP * 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    } else {
        for (UIView *cellView in cell.subviews) [cellView removeFromSuperview];
    }
    ChatMessage *message = self.rows[indexPath.row];
    [cell addSubview:[self bubbleViewForMessage:message]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (UIView *)bubbleViewForMessage:(ChatMessage *)message {
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
    CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    // NSLog(@"TextRect : %@", NSStringFromCGRect(TextRect));
    
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(BUBBLE_VIEW_MARGIN_LEFT, BUBBLE_VIEW_MARGIN_TOP, 32.0 + 8.0 + TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    // bubbleView.backgroundColor = [UIColor grayColor];
    
    UIImage *avatarImage = [UIImage imageNamed:@"发送到"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    avatarImageView.backgroundColor = [UIColor redColor];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 16.0;
    [bubbleView addSubview:avatarImageView];
    
    UIImage *bubbleImage = [UIImage imageNamed:message.isSend ? @"sender_bubble" : @"receiver_bubble"];
    UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubbleImage stretchableImageWithLeftCapWidth:floorf(bubbleImage.size.width / 2) topCapHeight:floorf(bubbleImage.size.height / 2)]];
    bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(8.0, 8.0, TextRect.size.width, TextRect.size.height)];
    bubbleText.backgroundColor = [UIColor clearColor];
    bubbleText.font = [UIFont systemFontOfSize:14.0];
    bubbleText.numberOfLines = 0;
    bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
    bubbleText.text = message.content;
    [bubbleImageView addSubview:bubbleText];
    return bubbleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.senderId = @"555";
    self.senderName = @"zhangsan";
    self.receiverId = @"123";
    self.receiverName = @"lisi";
    
    /*
    self.senderId = @"123";
    self.senderName = @"lisi";
    self.receiverId = @"555";
    self.receiverName = @"zhangsan";
    */
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = self.receiverName;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    self.textView.layer.cornerRadius = 4.0;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (!self.asyncSocket) [self setupSocket];
    [self connectToHost:HOST onPort:PORT];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [self sendMessageWithContent:[textView.text stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
        textView.text = nil;
        return NO;
    }
    return YES;
}

- (void)setupSocket {
    NSLog(@"setupSocket");
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:mainQueue];
}

- (void)connectToHost:(NSString *)host onPort:(uint16_t)port {
    NSLog(@"connectToHost");
    NSError *error = nil;
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) {
        NSLog(@"connectToHost : %@", error);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    [self setupHeartbeat];
    [self loginWithSenderId:self.senderId];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"socketDidDisconnect : %@", err);
}

- (void)setupHeartbeat {
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(echo) userInfo:nil repeats:YES];
}

- (void)echo {
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"ECHO\"}\n"];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)loginWithSenderId:(NSString *)senderId {
    NSLog(@"loginWithSenderId");
    NSString *message = [NSString stringWithFormat:@"{\"type\":\"LOGIN\", \"sender_id\":\"%@\"}\n", senderId];
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)sendMessageWithContent:(NSString *)content {
    // NSLog(@"sendMessageWithContent");
    [self sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:@"txt"];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\", \"contact\":\"1\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, sender[@"sender_id"], receiver[@"receiver_id"], sender[@"sender_name"], receiver[@"receiver_name"], content, type, @"-1"];
    // NSLog(@"sendMessage : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page {
    NSLog(@"historyMessagesForSenderId");
    NSString *messageFormat = @"{\"type\":\"CHATHISTORY\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"send_time\":\"%@\", \"NowPage\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, senderId, receiverId, sendTime, page];
    // NSLog(@"historyMessages : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    NSString *type = message[@"type"];
    if ([type isEqualToString:@"LOGIN"]) {
        [self handleLogin:message]; return;
    }
    if ([type isEqualToString:@"RECEIPT"]) {
        [self handleReceipt:message]; return;
    }
    if ([type isEqualToString:@"MESSAGE"]) {
        [self handleMessage:message]; return;
    }
    if ([type isEqualToString:@"CHATHISTORY"]) {
        [self handleHistory:message]; return;
    }
    if ([type isEqualToString:@"ECHO"]) {
        [self handleEcho:message]; return;
    }
    NSLog(@"ERROR : %@", message);
}

- (void)handleLogin:(NSDictionary *)message {
    // NSLog(@"handleLogin %@ : ", message);
    [self historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:@"2016-10-10 20:00:00" page:[NSString stringWithFormat:@"%ld", ++self.historyPage]];
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
    [self.rows addObject:chatMessage];
    NSLog(@"SEND : %@", msg[@"msg_content"]);
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)handleMessage:(NSDictionary *)message {
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
    [self.rows addObject:chatMessage];
    NSLog(@"RECV : %@", msg[@"msg_content"]);
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
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

- (void)handleEcho:(NSDictionary *)message {
    // NSLog(@"handleEcho %@ : ", message);
}

- (IBAction)showEmotionPad:(id)sender {
    NSLog(@"showEmotionPad");
}

- (IBAction)showVoicePad:(id)sender {
    NSLog(@"showVoicePad");
}

- (IBAction)showOtherPad:(id)sender {
    NSLog(@"showOtherPad");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect KeyboardFrameEnd = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardDeltaHeight = KeyboardFrameEnd.size.height - self.keyboardHeight;
    switch (self.tableViewTransform) {
        case TableViewTransformTranslate: {
            self.tableViewTop.constant -= keyboardDeltaHeight; break;
        }
        case TableViewTransformScale: {
            self.tableViewHeight.constant -= keyboardDeltaHeight; break;
        }
        case TableViewTransformNone: {
            CGFloat tableFooterBottom = self.tableView.tableFooterView.frame.origin.y;
            if (tableFooterBottom > self.tableView.frame.size.height) {
                self.tableViewTop.constant -= keyboardDeltaHeight;
                self.tableViewTransform = TableViewTransformTranslate;
            } else {
                self.tableViewHeight.constant -= keyboardDeltaHeight;
                self.tableViewTransform = TableViewTransformScale;
            }
            break;
        }
        default: break;
    }
    self.keyboardHeight = KeyboardFrameEnd.size.height;

    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.barView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.rows.count) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    switch (self.tableViewTransform) {
        case TableViewTransformTranslate: {
            self.tableViewTop.constant += self.keyboardHeight; break;
        }
        case TableViewTransformScale: {
            self.tableViewHeight.constant += self.keyboardHeight; break;
        }
        default: break;
    }
    self.tableViewTransform = TableViewTransformNone;
    self.keyboardHeight = 0.0;
    
    CGFloat animationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:animationDuration animations:^{
        [self.barView layoutIfNeeded];
        [self.tableView layoutIfNeeded];
    } completion:^(BOOL finished) {}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
