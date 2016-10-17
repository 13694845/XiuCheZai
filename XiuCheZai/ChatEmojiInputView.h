//
//  ChatEmojiInputView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatEmojiInputView;

static NSString *const kEmojiImageNameKey = @"faceName";
static NSString *const kEmojiImagePathKey = @"facePath";

@protocol ChatEmojiInputViewDelegate <NSObject>

- (void)emojiInputView:(ChatEmojiInputView *)emojiInputView didSelectEmoji:(NSDictionary *)emojiInfo;

@end

@interface ChatEmojiInputView : UIView

@property (weak, nonatomic) id <ChatEmojiInputViewDelegate> delegate;

@end
