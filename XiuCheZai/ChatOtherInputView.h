//
//  ChatOtherInputView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatOtherInputView;

typedef NS_ENUM(NSUInteger, OtherInputViewButton) {
    OtherInputViewButtonImageFromCamera,
    OtherInputViewButtonImageFromPhotoLibrary,
    OtherInputViewButtonMovieFromCamera
};

@protocol ChatOtherInputViewDelegate <NSObject>

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectButton:(OtherInputViewButton)button;

@end

@interface ChatOtherInputView : UIView

@property (weak, nonatomic) id <ChatOtherInputViewDelegate> delegate;

@end
