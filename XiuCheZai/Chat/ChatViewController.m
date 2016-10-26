//
//  ChatViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/10/1.
//  Copyright © 2016年 Zen. All rights reserved.
//

#import "ChatViewController.h"
#import "AFNetworking.h"
#import "SDWebImage/UIImageView+WebCache.h"
#import "MBProgressHUD.h"

#import "AppDelegate.h"
#import "XCZConfig.h"

#import "GCDAsyncSocket.h"
#import "ChatConfig.h"
#import "ChatMessage.h"
#import "ChatMessageManager.h"
#import "ChatEmojiAttachment.h"
#import "ChatEmojiManager.h"
#import "ChatEmojiInputView.h"
#import "ChatOtherInputView.h"
#import "VoiceConverter.h"

#import "ChatService.h"

@import MediaPlayer;

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

@interface ChatViewController () <GCDAsyncSocketDelegate, ChatEmojiInputViewDelegate, ChatOtherInputViewDelegate, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
@property (strong, nonatomic) ChatEmojiInputView *emojiInputView;
@property (strong, nonatomic) ChatOtherInputView *otherInputView;



@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) GCDAsyncSocket *asyncSocket;
@property (strong, nonatomic) NSTimer *timer;
@property (assign, nonatomic) NSUInteger historyPage;

@property (assign, nonatomic) CGFloat keyboardHeight;
@property (assign, nonatomic) TableViewTransform tableViewTransform;
@property (assign, nonatomic) InputViewType inputViewType;

@property (strong, nonatomic) AVAudioRecorder *audioRecorder;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (weak, nonatomic) UIView *imageViewerView;

// *****************
@property (strong, nonatomic) ChatMessage *sendingMessage;
// *****************


@property (strong, nonatomic) ChatService *chatService;


@property (copy, nonatomic) NSString *senderId;
@property (copy, nonatomic) NSString *senderName;
@property (copy, nonatomic) NSString *senderAvatar;


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

- (UIButton *)recordVoiceButton {
    if (!_recordVoiceButton) {
        _recordVoiceButton = [[UIButton alloc] init];
        _recordVoiceButton.frame = self.textView.frame;
        _recordVoiceButton.backgroundColor = [UIColor whiteColor];
        _recordVoiceButton.layer.borderWidth = 1.0;
        _recordVoiceButton.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
        _recordVoiceButton.layer.cornerRadius = 4.0;
        _recordVoiceButton.titleLabel.font =[UIFont systemFontOfSize:14.0];
        [_recordVoiceButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_recordVoiceButton addTarget:self action:@selector(startRecord:) forControlEvents:UIControlEventTouchDown];
        [_recordVoiceButton addTarget:self action:@selector(stopRecord:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recordVoiceButton;
}

- (ChatEmojiInputView *)emojiInputView {
    if (!_emojiInputView) {
        _emojiInputView = [[ChatEmojiInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 216.0)];
        _emojiInputView.delegate = self;
    }
    return _emojiInputView;
}

- (ChatOtherInputView *)otherInputView {
    if (!_otherInputView) {
        _otherInputView = [[ChatOtherInputView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, 216.0)];
        _otherInputView.delegate = self;
    }
    return _otherInputView;
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
            [self.view endEditing:YES];
            break;
        }
        default: break;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = self.receiverName;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"<" style:UIBarButtonItemStylePlain target:self action:@selector(goBack:)];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    self.textView.layer.borderWidth = 1.0;
    self.textView.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
    self.textView.layer.cornerRadius = 5.0;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.delegate = self;
    self.textView.text = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.chatService = ((AppDelegate *)[UIApplication sharedApplication].delegate).chatService;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processEcho:) name:@"XCZChatServiceDidHandleEcho" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processLogin:) name:@"XCZChatServiceDidHandleLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processHistory:) name:@"XCZChatServiceDidHandleHistory" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processReceipt:) name:@"XCZChatServiceDidHandleReceipt" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(processReceive:) name:@"XCZChatServiceDidHandleReceive" object:nil];
    
    self.receiverId = @"123";
    self.receiverName = @"lisi";
    self.receiverAvatar = nil;
}

- (void)processEcho:(NSNotification *)notification {
}

- (void)processLogin:(NSNotification *)notification {
    NSDictionary *senderInfo = [notification userInfo][@"sender"];
    self.senderId = senderInfo[@"senderId"];
    self.senderName = senderInfo[@"senderName"];
    self.senderAvatar = senderInfo[@"senderAvatar"];
    NSArray *localHistoryMessages = [[ChatMessageManager sharedManager] messagesForReceiverId:self.receiverId];
    if (localHistoryMessages.count) {
        self.rows = [localHistoryMessages mutableCopy];
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [self.chatService historyMessagesForSenderId:self.senderId receiverId:self.receiverId sendTime:[dateFormatter stringFromDate:[NSDate date]] page:@"1"];
    }
}

- (void)processHistory:(NSNotification *)notification {
    NSMutableArray *historyMessages = [[notification userInfo][@"historyMessages"] mutableCopy];
    [historyMessages addObjectsFromArray:self.rows];
    self.rows = historyMessages;
    [self.tableView reloadData];
    if (self.rows.count) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)processReceipt:(NSNotification *)notification {
    ChatMessage *chatMessage = [notification userInfo][@"receiptMessage"];
    [self.rows addObject:chatMessage];
    [self.tableView reloadData];
    if (self.rows.count) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)processReceive:(NSNotification *)notification {
    ChatMessage *chatMessage = [notification userInfo][@"receiveMessage"];
    [self.rows addObject:chatMessage];
    [self.tableView reloadData];
    if (self.rows.count) [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.rows.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)sendMessageWithContent:(NSString *)content contentType:(NSString *)contentType {
    NSLog(@"sendMessageWithContent");
    [self.chatService sendMessageFromSender:@{@"sender_id":self.senderId, @"sender_name":self.senderName} toReceiver:@{@"receiver_id":self.receiverId, @"receiver_name":self.receiverName} withContent:content type:contentType];
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
    self.inputViewType = InputViewTypeKeyboard;
}

- (UIView *)textBubbleViewForMessage:(ChatMessage *)message {
    NSAttributedString *attributedText = [ChatEmojiManager emojiStringFromPlainString:message.content withFont:[UIFont systemFontOfSize:14.0]];
    CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
    UIImage *avatarImage = [UIImage imageNamed:@"avatar_xcz"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    else avatarImageView.frame = CGRectMake(bubbleView.frame.size.width - 32.0, 0.0, 32.0, 32.0);
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
    
    UIImage *avatarImage = [UIImage imageNamed:@"avatar_xcz"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    else avatarImageView.frame = CGRectMake(bubbleView.frame.size.width - 32.0, 0.0, 32.0, 32.0);
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
    [bubbleImageView addSubview:imgView];
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = bubbleView.frame;
    button.tag = [self.rows indexOfObject:message];
    [button addTarget:self action:@selector(viewImage:) forControlEvents:UIControlEventTouchUpInside];
    [bubbleImageView addSubview:button];
    return bubbleView;
}

- (void)viewImage:(UIButton *)sender {
    ChatMessage *message = self.rows[sender.tag];
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    backgroundView.backgroundColor = [UIColor blackColor];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    [imgView sd_setImageWithURL:[NSURL URLWithString:message.content]];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.frame = self.view.bounds;
    [backgroundView addSubview:imgView];
    
    UIButton *closeButton = [[UIButton alloc] init];
    closeButton.frame = CGRectMake(20.0, 20.0, 32.0, 32.0);
    [closeButton setTitle:@"X" forState:UIControlStateNormal];
    closeButton.backgroundColor = [UIColor grayColor];
    closeButton.layer.cornerRadius = 16.0;
    [closeButton addTarget:self action:@selector(closeImageViewer) forControlEvents:UIControlEventTouchUpInside];
    [backgroundView addSubview:closeButton];
    [self.view addSubview:backgroundView];
    
    self.imageViewerView = backgroundView;
}

- (void)closeImageViewer {
    [self.imageViewerView removeFromSuperview];
}





- (UIView *)movieBubbleViewForMessage:(ChatMessage *)message {
    CGRect imageRect = CGRectMake(0.0, 0.0, 22.0, 22.0);
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
    UIImage *avatarImage = [UIImage imageNamed:@"avatar_xcz"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    else avatarImageView.frame = CGRectMake(bubbleView.frame.size.width - 32.0, 0.0, 32.0, 32.0);
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 16.0;
    [bubbleView addSubview:avatarImageView];
    
    UIView *bubbleImageView = [[UIView alloc] init];
    bubbleImageView.backgroundColor = message.isSend ? [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] : [UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:232.0/255.0 alpha:1.0];
    bubbleImageView.layer.cornerRadius = 5.0;
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_sender"]];
    if (!message.isSend) imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"movie_receiver"]];
    imgView.frame = CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, imageRect.size.width, imageRect.size.height);
    [bubbleImageView addSubview:imgView];
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = bubbleView.frame;
    button.tag = [self.rows indexOfObject:message];
    [button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
    [bubbleImageView addSubview:button];
    return bubbleView;
}

- (void)playMovie:(UIButton *)sender {
    ChatMessage *message = self.rows[sender.tag];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mp4Path = [documentsPath stringByAppendingPathComponent:@"temp.mp4"];
    NSData *mp4Data = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.content]];
    [mp4Data writeToFile:mp4Path atomically:YES];
    
    MPMoviePlayerViewController *moviePlayerViewController =[[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:mp4Path]];
    [self presentViewController:moviePlayerViewController animated:YES completion:nil];
}

- (UIView *)voiceBubbleViewForMessage:(ChatMessage *)message {
    CGRect imageRect = CGRectMake(0.0, 0.0, 22.0, 22.0);
    UIView *bubbleView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 32.0 + 8.0 + imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2)];
    
    UIImage *avatarImage = [UIImage imageNamed:@"avatar_xcz"];
    UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
    if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
    else avatarImageView.frame = CGRectMake(bubbleView.frame.size.width - 32.0, 0.0, 32.0, 32.0);
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = 16.0;
    [bubbleView addSubview:avatarImageView];
    
    UIView *bubbleImageView = [[UIView alloc] init];
    bubbleImageView.backgroundColor = message.isSend ? [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] : [UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:232.0/255.0 alpha:1.0];
    bubbleImageView.layer.cornerRadius = 5.0;
    if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    else bubbleImageView.frame = CGRectMake(0.0, 0.0, imageRect.size.width + BUBBLE_TEXT_PADDING * 2, imageRect.size.height + BUBBLE_TEXT_PADDING * 2);
    [bubbleView addSubview:bubbleImageView];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_sender"]];
    if (!message.isSend) imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"voice_receiver"]];
    imgView.frame = CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, imageRect.size.width, imageRect.size.height);
    [bubbleImageView addSubview:imgView];
    
    UIButton *button = [[UIButton alloc] init];
    button.frame = bubbleView.frame;
    button.tag = [self.rows indexOfObject:message];
    [button addTarget:self action:@selector(playVoice:) forControlEvents:UIControlEventTouchUpInside];
    [bubbleImageView addSubview:button];
    return bubbleView;
}

- (void)playVoice:(UIButton *)sender {
    ChatMessage *message = self.rows[sender.tag];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *amrPath = [documentsPath stringByAppendingPathComponent:@"temp.amr"];
    NSString *wavPath = [documentsPath stringByAppendingPathComponent:@"new.wav"];
    NSData *amrData = [NSData dataWithContentsOfURL:[NSURL URLWithString:message.content]];
    [amrData writeToFile:amrPath atomically:YES];
    if ([VoiceConverter ConvertAmrToWav:amrPath wavSavePath:wavPath]) {}
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    NSError *error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:wavPath] error:&error];
    self.audioPlayer.numberOfLoops = 0;
    [self.audioPlayer play];
    if (error) {
        NSLog(@"playVoice ：%@", error.localizedDescription); return;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        NSString *content = [ChatEmojiManager plainStringFromEmojiString:textView.attributedText];
        content = [content stringByReplacingOccurrencesOfString:[ChatConfig terminator] withString:@""];
        if (!content.length) {
            [self toastWithText:@"请输入消息内容"];
            return NO;
        }
        textView.text = nil;
        [self sendMessageWithContent:content contentType:@"txt"];
        return NO;
    }
    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.inputViewType = InputViewTypeKeyboard;
    return YES;
}

- (IBAction)showVoicePad:(id)sender {
    if (self.inputViewType == InputViewTypeVoice) {
        [sender setBackgroundImage:[UIImage imageNamed:@"mic"] forState:UIControlStateNormal];
        [self.recordVoiceButton removeFromSuperview];
        [self.textView becomeFirstResponder]; return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeVoice;
    
    [self.recordVoiceButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.barView addSubview:self.recordVoiceButton];
    [self.textView resignFirstResponder];
}

- (void)startRecord:(UIButton *)sender {
    NSLog(@"startRecord");
    [sender setTitle:@"松开 结束" forState:UIControlStateNormal];
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *wavPath = [documentsPath stringByAppendingPathComponent:@"temp.wav"];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    NSError *error = nil;
    self.audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL fileURLWithPath:wavPath] settings:[VoiceConverter GetAudioRecorderSettingDict] error:&error];
    if (error) {
        NSLog(@"startRecord ：%@", error.localizedDescription); return;
    }
    [self.audioRecorder record];
}

- (void)stopRecord:(UIButton *)sender {
    NSLog(@"stopRecord");
    [sender setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.audioRecorder stop];
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *wavPath = [documentsPath stringByAppendingPathComponent:@"temp.wav"];
    NSString *amrPath = [documentsPath stringByAppendingPathComponent:@"temp.amr"];
    if ([VoiceConverter ConvertWavToAmr:wavPath amrSavePath:amrPath]) {}
    NSData *amrData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:amrPath]];
    [self uploadAmrWithAmrData:amrData];
}

- (void)uploadAmrWithAmrData:(NSData *)amrData {
    NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    NSDictionary *parameters = nil;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:amrData name:@"file" fileName:@"filename.amr" mimeType:@"audio/amr"];
    } progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], result[@"filepath"]];
        [self sendMessageWithContent:fileURL contentType:@"msc"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
    }];
}

- (IBAction)showEmotionPad:(UIButton *)sender {
    if (self.inputViewType == InputViewTypeEmoji) {
        [sender setBackgroundImage:[UIImage imageNamed:@"emoji"] forState:UIControlStateNormal];
        [self.textView becomeFirstResponder]; return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeEmoji;
    
    UITextView *textView = [[UITextView alloc] init];
    [self.barView addSubview:textView];
    textView.inputView = self.emojiInputView;
    [textView becomeFirstResponder];
}

- (void)emojiInputView:(ChatEmojiInputView *)emojiInputView didSelectEmojiWithEmojiInfo:(NSDictionary *)emojiInfo {
    NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"json"]];
    NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
    CGSize emojiSize = CGSizeMake([UIFont systemFontOfSize:14.0].lineHeight, [UIFont systemFontOfSize:14.0].lineHeight);
    
    NSString *placeholder = emojiInfo[@"faceName"];
    UIImage *emojiImage = [UIImage imageNamed:emojiJson[placeholder]];
    UIGraphicsBeginImageContextWithOptions(emojiSize, NO, 0.0);
    [emojiImage drawInRect:CGRectMake(0.0, 0.0, emojiSize.width, emojiSize.height)];
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
        [self.textView becomeFirstResponder]; return;
    }
    [sender setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateNormal];
    self.inputViewType = InputViewTypeOther;
    
    UITextView *fakeTextView = [[UITextView alloc] init];
    [self.barView addSubview:fakeTextView];
    fakeTextView.inputView = self.otherInputView;
    [fakeTextView becomeFirstResponder];
}

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectButtonWithButtonTag:(OtherInputViewButtonTag)buttonTag {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    switch (buttonTag) {
        case OtherInputViewButtonTagImageFromPhotoLibrary: {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.delegate = self; break;
        }
        case OtherInputViewButtonTagImageFromCamera: {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.delegate = self; break;
        }
        case OtherInputViewButtonTagMovieFromCamera: {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            imagePickerController.delegate = self; break;
        }
        case OtherInputViewButtonTagMovieFromPhotoLibrary: {
            imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePickerController.mediaTypes = @[(NSString *)kUTTypeMovie];
            imagePickerController.delegate = self; break;
        }
        default: break;
    }
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeImage]) [self uploadImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    if ([picker.mediaTypes containsObject:(NSString *)kUTTypeMovie]) [self uploadMovieWithMovURL:[info objectForKey:UIImagePickerControllerMediaURL]];
}

- (void)uploadImage:(UIImage *)image {
    image = [self resizeImage:image toSize:CGSizeMake(image.size.width / 2, image.size.height / 2)];
    NSData *fileData = UIImageJPEGRepresentation(image, 0.8);
    
    NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    NSDictionary *parameters = nil;
    self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
        [formData appendPartWithFileData:fileData name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress *uploadProgress) {
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
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

- (void)uploadMovieWithMovURL:(NSURL *)movURL {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *mp4Path = [documentsPath stringByAppendingPathComponent:@"temp.mp4"];
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:movURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = [NSURL fileURLWithPath:mp4Path];
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse = YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
        NSData *fileData = [NSData dataWithContentsOfFile:mp4Path];
        
        NSString *server = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
        NSDictionary *parameters = nil;
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id formData) {
            [formData appendPartWithFileData:fileData name:@"file" fileName:@"filename.mp4" mimeType:@"video/mp4"];
        } progress:^(NSProgress *uploadProgress) {
        } success:^(NSURLSessionDataTask *task, id responseObject) {
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
            NSString *fileURL = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], result[@"filepath"]];
            [self sendMessageWithContent:fileURL contentType:@"mov"];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
        }];
    }];
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

- (void)toastWithText:(NSString *)text {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.alpha = 0.5;
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    hud.yOffset = -100.0;
    [hud hide:YES afterDelay:2.0];
}

- (void)goBack:(id)sender {
    [self.chatService stop];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
