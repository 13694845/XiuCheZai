//
//  ChatOtherInputView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatOtherInputView;

@protocol ChatEmojiInputViewDelegate <NSObject>

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectFunc:(NSDictionary *)emojiInfo;

@end


@interface ChatOtherInputView : UIView

@end
