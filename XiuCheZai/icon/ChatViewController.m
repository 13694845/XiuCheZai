//
//  ViewController.m
//  Chat
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "ChatConfig.h"
#import "GCDAsyncSocket.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"
#import "ChatEmojiManager.h"
#import "ChatEmojiInputView.h"

#define BUBBLE_VIEW_MARGIN_TOP      15.0
#define BUBBLE_VIEW_MARGIN_LEFT     12.0
#define BUBBLE_VIEW_MARGIN_RIGHT    12.0
#define BUBBLE_TEXT_PADDING         8.0

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    for (UIView *cellView in cell.subviews) [cellView removeFromSuperview];
    
    ChatMessage *message = self.rows[indexPath.row];
    UIView *bubbleView = [self bubbleViewForMessage:message];
    CGRect rect = bubbleView.frame;
    if (message.isSend) rect.origin.x += BUBBLE_VIEW_MARGIN_LEFT;
    else rect.origin.x = cell.frame.size.width - rect.size.width - BUBBLE_VIEW_MARGIN_RIGHT;
    rect.origin.y += BUBBLE_VIEW_MARGIN_TOP;
    bubbleView.frame = rect;
    [cell addSubview:bubbleView];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
}

- (UIView *)bubbleViewForMessage:(ChatMessage *)message {
    NSAttributedString *attributedText = [ChatEmojiManager emojiStringFromPlainString:message.content withFont:[UIFont systemFontOfSize:14.0]];
    CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
    UIImage *avatarImage = [UIImage imageNamed:@"发送到"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    else avatarImageView.frame = CGRectMake(bubbleView.frame.size.width - 32.0, 0.0, 32.0, 32.0);
    avatarImageView.backgroundColor = [UIColor redColor];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 16.0;
    [bubbleView addSubview:avatarImageView];
    
    UIView *bubbleImageView = [[UIView alloc] init];
    bubbleImageView.backgroundColor = message.isSend ? [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] : [UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:232.0/255.0 alpha:1.0];
    bubbleImageView.layer.cornerRadius = 5.0;
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, TextRect.size.width, TextRect.size.height)];
    bubbleText.textColor = message.isSend ? [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] : [UIColor whiteColor];
    bubbleText.font = [UIFont systemFontOfSize:14.0];
    bubbleText.numberOfLines = 0;
    bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
    bubbleText.attributedText = attributedText;
    [bubbleImageView addSubview:bubbleText];
    return bubbleView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    self.textView.layer.cornerRadius = 5.0;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.senderId = @"555";
    self.senderName = @"zhangsan";
    self.senderAvatar = nil;
    self.receiverId = @"123";
    self.receiverName = @"lisi";
    self.receiverAvatar = nil;
    
    if (!self.asyncSocket) [self setupSocket];
    if (!self.asyncSocket.isConnected) [self connectToHost:HOST onPort:PORT];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSString *content = [ChatEmojiManager plainStringFromEmojiString:textView.attributedText];
        [self sendMessageWithContent:[content stringByReplacingOccurrencesOfString:@"\n" withString:@""]];
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
    if (![self.asyncSocket connectToHost:host onPort:port error:&error]) NSLog(@"connectToHost : %@", error);
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost");
    [((AppDelegate *)[UIApplication sharedApplication].delegate).chatService stop];
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

- (void)sendMessageWithContent:(NSString *)content {
    NSLog(@"sendMessageWithContent");
    [self sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:@"txt"];
}

- (void)sendMessageFromSender:(NSDictionary *)sender toReceiver:(NSDictionary *)receiver withContent:(NSString *)content type:(NSString *)type {
    NSString *messageFormat = @"{\"type\":\"MESSAGE\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"sender_name\":\"%@\", \"receiver_name\":\"%@\", \"msg_content\":\"%@\", \"msg_type\":\"%@\", \"play_time\":\"%@\", \"contact\":\"1\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, sender[@"sender_id"], receiver[@"receiver_id"], sender[@"sender_name"], receiver[@"receiver_name"], content, type, @"-1"];
    NSLog(@"sendMessage : %@", message);
    [self.asyncSocket writeData:[message dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1.0 tag:0];
    [self.asyncSocket readDataToData:[TERMINATOR dataUsingEncoding:NSASCIIStringEncoding] withTimeout:-1.0 tag:0];
}

- (void)historyMessagesForSenderId:(NSString *)senderId receiverId:(NSString *)receiverId sendTime:(NSString *)sendTime page:(NSString *)page {
    NSLog(@"historyMessagesForSenderId");
    NSString *messageFormat = @"{\"type\":\"CHATHISTORY\", \"sender_id\":\"%@\", \"receiver_id\":\"%@\", \"send_time\":\"%@\", \"NowPage\":\"%@\"}\n";
    NSString *message = [NSString stringWithFormat:messageFormat, senderId, receiverId, sendTime, page];
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
    NSLog(@"handleLogin %@ : ", message);
    NSArray *localHistoryMessages = [[ChatMessageManager sharedManager] messagesForReceiverId:self.receiverId];
    if (localHistoryMessages.count) {
        self.rows = [localHistoryMessages mutableCopy];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        [self historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:@"2016-10-14 20:00:00" page:[NSString stringWithFormat:@"%d", 1]];
    }
}

- (void)startHeartbeat {
    NSLog(@"startHeartbeat");
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(echo) userInfo:nil repeats:YES];
}

- (void)stopHeartbeat {
    NSLog(@"stopHeartbeat");
    if (self.timer.valid) [self.timer invalidate];
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
    [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:self.receiverId];
    [self.rows addObject:chatMessage];
    
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
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
    [[ChatMessageManager sharedManager] saveMessage:chatMessage withReceiverId:self.receiverId];
    [self.rows addObject:chatMessage];
    
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
    [[ChatMessageManager sharedManager] saveMessages:chatMessages withReceiverId:self.receiverId];
    [chatMessages addObjectsFromArray:self.rows];
    self.rows = chatMessages;
    
    [self.tableView reloadData];
    if (self.rows.count) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)handleEcho:(NSDictionary *)message {
    NSLog(@"handleEcho %@ : ", message);
}



// ******
- (IBAction)showVoicePad:(id)sender {
    NSLog(@"showVoicePad");
    
    
    self.textView.inputView = nil;
    [self.textView reloadInputViews];
    // [self.textView resignFirstResponder];

}

- (IBAction)showEmotionPad:(id)sender {
    NSLog(@"showEmotionPad");
    
    
    
    // self.view.frame.size.height - 200.0
    ChatEmojiInputView *emojiInputView = [[ChatEmojiInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 253.0)];
    emojiInputView.backgroundColor = [UIColor grayColor];
    
    
    
    
    
    /*
    for (NSString *key in emojiJson) {
        NSString *value = emojiJson[key];
        NSLog(@"Value: %@ for key: %@", value, key);
    }
    */
    
    // [self.view addSubview:emojiInputView];
    
    
    
    
    self.textView.inputView = emojiInputView;
    [self.textView reloadInputViews];

    [self.textView becomeFirstResponder];

    
}

- (IBAction)showOtherPad:(id)sender {
    NSLog(@"showOtherPad");
}
// ******



- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect KeyboardFrameEnd = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    NSLog(@"KeyboardFrameEnd : %@", NSStringFromCGRect(KeyboardFrameEnd));
    
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

- (void)viewDidUnload {
    NSLog(@"viewDidUnload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
