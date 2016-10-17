//
//  ChatOtherInputView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatOtherInputView;

@protocol ChatOtherInputViewDelegate <NSObject>

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectButton:(NSDictionary *)buttonInfo;

@end

@interface ChatOtherInputView : UIView

@property (weak, nonatomic) id <ChatOtherInputViewDelegate> delegate;

@end
