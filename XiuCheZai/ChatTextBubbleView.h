//
//  ChatTextBubbleView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatMessage.h"

@interface ChatTextBubbleView : UIView

- (instancetype)initWithMessage:(ChatMessage *)message;

@end
