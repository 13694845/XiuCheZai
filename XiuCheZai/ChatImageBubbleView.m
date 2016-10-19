//
//  ChatImageBubbleView.m
//  XiuCheZai
//
//  Created by QSH on 16/10/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatImageBubbleView.h"

#define BUBBLE_VIEW_MARGIN_TOP      15.0
#define BUBBLE_VIEW_MARGIN_LEFT     12.0
#define BUBBLE_VIEW_MARGIN_RIGHT    12.0
#define BUBBLE_IMAGE_HEIGHT         100.0

@implementation ChatImageBubbleView

- (instancetype)initWithMessage:(ChatMessage *)message {
    self = [super init];
    if (self) {
        NSAttributedString *attributedText = [ChatEmojiManager emojiStringFromPlainString:message.content withFont:[UIFont systemFontOfSize:14.0]];
        CGRect TextRect = [attributedText boundingRectWithSize:CGSizeMake(180.0, 20000.0) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        self.frame = CGRectMake(0.0, 0.0, 32.0 + 8.0 + TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
        
        UIImage *avatarImage = [UIImage imageNamed:@"发送到"];
        UIImageView *avatarImageView = [[UIImageView alloc] initWithImage:avatarImage];
        if (message.isSend) avatarImageView.frame = CGRectMake(0.0, 0.0, 32.0, 32.0);
        else avatarImageView.frame = CGRectMake(self.frame.size.width - 32.0, 0.0, 32.0, 32.0);
        avatarImageView.backgroundColor = [UIColor redColor];
        avatarImageView.layer.masksToBounds = YES;
        avatarImageView.layer.cornerRadius = 16.0;
        [self addSubview:avatarImageView];
        
        UIView *bubbleImageView = [[UIView alloc] init];
        bubbleImageView.backgroundColor = message.isSend ? [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0] : [UIColor colorWithRed:30.0/255.0 green:130.0/255.0 blue:232.0/255.0 alpha:1.0];
        bubbleImageView.layer.cornerRadius = 5.0;
        if (message.isSend) bubbleImageView.frame = CGRectMake(32.0 + 8.0, 0.0, TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
        else bubbleImageView.frame = CGRectMake(0.0, 0.0, TextRect.size.width + BUBBLE_TEXT_PADDING * 2, TextRect.size.height + BUBBLE_TEXT_PADDING * 2);
        [self addSubview:bubbleImageView];
        
        UILabel *bubbleText = [[UILabel alloc] initWithFrame:CGRectMake(BUBBLE_TEXT_PADDING, BUBBLE_TEXT_PADDING, TextRect.size.width, TextRect.size.height)];
        bubbleText.textColor = message.isSend ? [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0] : [UIColor whiteColor];
        bubbleText.font = [UIFont systemFontOfSize:14.0];
        bubbleText.numberOfLines = 0;
        bubbleText.lineBreakMode = NSLineBreakByWordWrapping;
        bubbleText.attributedText = attributedText;
        [bubbleImageView addSubview:bubbleText];
    }
    return self;
}

@end
