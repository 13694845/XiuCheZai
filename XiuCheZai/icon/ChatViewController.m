//
//  ChatViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "AppDelegate.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "GCDAsyncSocket.h"
#import "ChatConfig.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"
#import "ChatEmojiAttachment.h"
#import "ChatEmojiManager.h"
#import "ChatEmojiInputView.h"
#import "ChatOtherInputView.h"
#import "QCEncodeAudio.h"

@import AVFoundation;

#define BUBBLE_VIEW_MARGIN_TOP      15.0
#define BUBBLE_VIEW_MARGIN_LEFT     12.0
#define BUBBLE_VIEW_MARGIN_RIGHT    12.0
#define BUBBLE_TEXT_PADDING         8.0
#define BUBBLE_IMAGE_HEIGHT         100.0

typedef NS_ENUM(NSUInteger, TableViewTransform) {
    TableViewTransformNone,
    TableViewTransformTranslate,
    TableViewTransformScale
};

typedef NS_ENUM(NSUInteger, InputViewType) {
    InputViewTypeKeyboard,
    InputViewTypeEmoji,
    InputViewTypeOther,
    InputViewTypeVoice
};

@interface ChatViewController () <GCDAsyncSocketDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, ChatEmojiInputViewDelegate, ChatOtherInputViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, AVAudioRecorderDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTop;
@property (strong, nonatomic) NSMutableArray *rows;

@property (weak, nonatomic) IBOutlet UIView *barView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *voiceButton;
@property (weak, nonatomic) IBOutlet UIButton *emotionButton;
@property (weak, nonatomic) IBOutlet UIButton *othersButton;
@property (strong, nonatomic) UIButton *recordVoiceButton;

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger historyPage;

@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) TableViewTransform tableViewTransform;
@property (assign, nonatomic) InputViewType inputViewType;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@end

@implementation ChatViewController

@synthesize rows = _rows;

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [XCZConfig version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (void)setInputViewType:(InputViewType)inputViewType {
    _inputViewType = inputViewType;
    switch (inputViewType) {
        case InputViewTypeKeyboard: {
            [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [self.recordVoiceButton removeFromSuperview];
            [self.emotionButton setBackgroundImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
            [self.othersButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            break;
        }
        case InputViewTypeEmoji: {
            [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [self.recordVoiceButton removeFromSuperview];
            [self.othersButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            break;
        }
        case InputViewTypeOther: {
            [self.voiceButton setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
            [self.recordVoiceButton removeFromSuperview];
            [self.emotionButton setBackgroundImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
            break;
        }
        case InputViewTypeVoice: {
            [self.emotionButton setBackgroundImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
            [self.othersButton setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
            break;
        }
        default: break;
    }
}

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
    CGFloat height = 0.0;
    ChatMessage *message = self.rows[indexPath.row];
    if ([message.type isEqualToString:@"txt"]) {
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:message.content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]}];
        CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        height = TextRect.size.height + BUBBLE_TEXT_PADDING * 2 + BUBBLE_VIEW_MARGIN_TOP * 2;
    }
    if ([message.type isEqualToString:@"img"]) {
        height = BUBBLE_IMAGE_HEIGHT + BUBBLE_TEXT_PADDING * 2 + BUBBLE_VIEW_MARGIN_TOP * 2;
    }
    if ([message.type isEqualToString:@"msc"]) {
        height = 22.0 + BUBBLE_TEXT_PADDING * 2 + BUBBLE_VIEW_MARGIN_TOP * 2;
    }
    if ([message.type isEqualToString:@"mov"]) {
        height = 22.0 + BUBBLE_TEXT_PADDING * 2 + BUBBLE_VIEW_MARGIN_TOP * 2;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    for (UIView *cellView in cell.subviews) [cellView removeFromSuperview];
    ChatMessage *message = self.rows[indexPath.row];
    UIView *bubbleView;
    if ([message.type isEqualToString:@"txt"]) {
        bubbleView = [self textBubbleViewForMessage:message];
    }
    if ([message.type isEqualToString:@"img"]) {
        bubbleView = [self imageBubbleViewForMessage:message];
    }
    if ([message.type isEqualToString:@"msc"]) {
        bubbleView = [self voiceBubbleViewForMessage:message];
    }
    if ([message.type isEqualToString:@"mov"]) {
        bubbleView = [self movieBubbleViewForMessage:message];
    }
    
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

- (UIView *)textBubbleViewForMessage:(ChatMessage *)message {
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

- (UIView *)imageBubbleViewForMessage:(ChatMessage *)message {
    CGRect imageRect = CGRectMake(0.0, 0.0, BUBBLE_IMAGE_HEIGHT, BUBBLE_IMAGE_HEIGHT);
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
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
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView sd_setImageWithURL:[NSURL URLWithString:message.content]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, imageRect.size.width, imageRect.size.height);
    
    
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = bubbleView.frame;
    button.backgroundColor = [UIColor grayColor];
    [button addTarget:self action:@selector(<#selector#>) forControlEvents:<#(UIControlEvents)#>]
    [bubbleImageView addSubview:button];
    
    
    // [bubbleImageView addSubview:imgView];
    return bubbleView;
}


- (void)viewImage:(UIImage *)image {
    NSLog(@"viewImage");
}


- (UIView *)movieBubbleViewForMessage:(ChatMessage *)message {
    NSLog(@"movieBubbleViewForMessage");
    CGRect imageRect = CGRectMake(0.0, 0.0, 22.0, 22.0);
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
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
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    /*
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView sd_setImageWithURL:[NSURL URLWithString:message.content]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, imageRect.size.width, imageRect.size.height);
    [bubbleImageView addSubview:imgView];
     */
    return bubbleView;
}

- (UIView *)voiceBubbleViewForMessage:(ChatMessage *)message {
    NSLog(@"soundBubbleViewForMessage");
    CGRect imageRect = CGRectMake(0.0, 0.0, 22.0, 22.0);
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
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
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    /*
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView sd_setImageWithURL:[NSURL URLWithString:message.content]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, imageRect.size.width, imageRect.size.height);
    [bubbleImageView addSubview:imgView];
     */
    return bubbleView;
}

- (void)goBack:(id)sender {
    NSLog(@"goBack");
    [self.asyncSocket disconnect];
    [((AppDelegate *)[UIApplication sharedApplication].delegate).chatService start];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = self.receiverName;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    
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
    
    [((AppDelegate *)[UIApplication sharedApplication].delegate).chatService stop];
    
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

- (void)sendMessageWithContent:(NSString *)content contentType:(NSString *)contentType {
    NSLog(@"sendMessageWithContent");
    [self sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:contentType];
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
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:[dateFormatter stringFromDate:[NSDate date]] page:[NSString stringWithFormat:@"%d", 1]];
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

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.inputViewType = InputViewTypeKeyboard;
    return YES;
}

- (IBAction)showVoicePad:(id)sender {
    NSLog(@"showVoicePad");
    if (self.inputViewType == InputViewTypeVoice) {
        [sender setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
        [self.recordVoiceButton removeFromSuperview];
        [self.textView becomeFirstResponder];
        return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeVoice;
    [self.textView resignFirstResponder];
    
    if (!self.recordVoiceButton) {
        self.recordVoiceButton = [[UIButton alloc] init];
        self.recordVoiceButton.layer.borderWidth = 1.0;
        self.recordVoiceButton.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
        self.recordVoiceButton.layer.cornerRadius = 4.0;
        self.recordVoiceButton.backgroundColor = [UIColor whiteColor];
        self.recordVoiceButton.titleLabel.font =[UIFont systemFontOfSize:14.0];
        [self.recordVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.recordVoiceButton.frame = self.textView.frame;
        [self.recordVoiceButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
        [self.recordVoiceButton addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.recordVoiceButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.barView addSubview:self.recordVoiceButton];
}

- (void)startRecord:(UIButton *)sender {
    NSLog(@"startRecord");
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *wavPath = [documentsPath stringByAppendingPathComponent:@"sampleSound.wav"];
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
    
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:wavPath] settings:[self getAudioSetting] error:&error];
    self.audioRecorder.delegate = self;
    if (error) {
        NSLog(@"startRecord ：%@", error.localizedDescription); return;
    }
    [self.audioRecorder record];
}

- (NSDictionary *)getAudioSetting {
    NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
    [dicM setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
    [dicM setObject:@(8000) forKey:AVSampleRateKey];
    [dicM setObject:@(1) forKey:AVNumberOfChannelsKey];
    [dicM setObject:@(8) forKey:AVLinearPCMBitDepthKey];
    [dicM setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
    return dicM;
}

- (void)stopRecord:(UIButton *)sender {
    NSLog(@"stopRecord");
    [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.audioRecorder stop];
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag {
    NSLog(@"audioRecorderDidFinishRecording");
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *wavPath = [documentsPath stringByAppendingPathComponent:@"sampleSound.wav"];
    
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath] error:&error];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
    if (error) {
        NSLog(@"audioRecorderDidFinishRecording ：%@", error.localizedDescription); return;
    }
    
    NSData *data = [NSData dataWithContentsOfFile:wavPath];
    NSLog(@"wav size : %ld", data.length);
    NSData *wavData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:wavPath]];
    NSData *amrData = [QCEncodeAudio convertWavToAmrFile:wavData];
    NSLog(@"amr size : %ld", amrData.length);
    
    [self uploadAmrWithAmrData:amrData];
}

- (void)uploadAmrWithAmrData:(NSData *)amrData {
    NSLog(@"image size : %ld", amrData.length);
    
    NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    NSDictionary *parameters = nil;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:amrData name:@"file" fileName:@"filename.amr" mimeType:@"audio/amr"];
    } progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"NSDictionary : %@", result);
        NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], result[@"filepath"]];
        [self sendMessageWithContent:fileURL contentType:@"msc"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (IBAction)showEmotionPad:(UIButton *)sender {
    if (self.inputViewType == InputViewTypeEmoji) {
        [sender setBackgroundImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder];
        return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeEmoji;
    ChatEmojiInputView *emojiInputView = [[ChatEmojiInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 216.0)];
    emojiInputView.delegate = self;
    UITextView *textView = [[UITextView alloc] init];
    [self.barView addSubview:textView];
    textView.inputView = emojiInputView;
    [textView becomeFirstResponder];
}

- (void)emojiInputView:(ChatEmojiInputView *)emojiInputView didSelectEmojiWithEmojiInfo:(NSDictionary *)emojiInfo {
    NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"json"]];
    NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
    CGSize emojiSize = CGSizeMake([UIFont systemFontOfSize:14.0].lineHeight, [UIFont systemFontOfSize:14.0].lineHeight);
    
    NSString *placeholder = emojiInfo[@"faceName"];
    UIImage *emojiImage = [UIImage imageNamed:emojiJson[placeholder]];
    UIGraphicsBeginImageContextWithOptions(emojiSize, NO, 0.0);
    [emojiImage drawInRect:CGRectMake(0, 0, emojiSize.width, emojiSize.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    ChatEmojiAttachment *emojiAttachment = [[ChatEmojiAttachment alloc] init];
    emojiAttachment.emojiTag = placeholder;
    emojiAttachment.image = resizedImage;
    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:emojiAttachment];
    [self.textView.textStorage insertAttributedString:attachmentString atIndex:self.textView.selectedRange.location];
    self.textView.selectedRange = NSMakeRange(self.textView.selectedRange.location + 1, 0);
}

- (IBAction)showOtherPad:(id)sender {
    if (self.inputViewType == InputViewTypeOther) {
        [sender setBackgroundImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder];
        return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeOther;
    ChatOtherInputView *otherInputView = [[ChatOtherInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 216.0)];
    otherInputView.delegate = self;
    UITextView *textView = [[UITextView alloc] init];
    [self.barView addSubview:textView];
    textView.inputView = otherInputView;
    [textView becomeFirstResponder];
}

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectButtonWithButtonTag:(OtherInputViewButtonTag)buttonTag {
    switch (buttonTag) {
        case OtherInputViewButtonTagImageFromPhotoLibrary: {
            NSLog(@"OtherInputViewButtonTagImageFromPhotoLibrary");
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil]; break;
        }
        case OtherInputViewButtonTagImageFromCamera: {
            NSLog(@"OtherInputViewButtonTagImageFromCamera");
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil]; break;
        }
        case OtherInputViewButtonTagMovieFromCamera: {
            NSLog(@"OtherInputViewButtonTagMovieFromCamera");
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            imagePickerController.delegate = self;
            [self presentViewController:imagePickerController animated:YES completion:nil]; break;
        }
        default: break;
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeImage]) {
        NSLog(@"kUTTypeImage");
        [self uploadImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    }
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeMovie]) {
        NSLog(@"kUTTypeMovie");
        [self uploadMovieWithMovieURL:[info objectForKey:UIImagePickerControllerMediaURL]];
    }
}

- (void)uploadImage:(UIImage *)image {
    image = [self resizeImage:image toSize:CGSizeMake(image.size.width / 2, image.size.height / 2)];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    NSLog(@"image size : %ld", data.length);
    
    NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    NSDictionary *parameters = nil;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"NSDictionary : %@", result);
        NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], result[@"filepath"]];
        [self sendMessageWithContent:fileURL contentType:@"img"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (void)uploadMovieWithMovieURL:(NSURL *)movieURL {
    NSLog(@"movieURL : %@", movieURL);
    NSString *mp4Path = [self mp4FromMovURL:movieURL];
    NSLog(@"mp4 : %@", mp4Path);
    NSData *data = [NSData dataWithContentsOfFile:mp4Path];
    NSLog(@"mp4 size : %ld", data.length);
    
    NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    NSDictionary *parameters = nil;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:data name:@"file" fileName:@"filename.mp4" mimeType:@"video/mp4"];
    } progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"NSDictionary : %@", result);
        NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], result[@"filepath"]];
        [self sendMessageWithContent:fileURL contentType:@"mov"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (NSString *)mp4FromMovURL:(NSURL *)movURL {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mp4Path = [documentsPath stringByAppendingPathComponent:@"sampleVideo.mp4"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
    exportSession.outputFileType = AVFileTypeMPEG4;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {}];
    return mp4Path;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGRect KeyboardFrameEnd = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // NSLog(@"KeyboardFrameEnd : %@", NSStringFromCGRect(KeyboardFrameEnd));
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
