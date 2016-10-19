//
//  ChatOtherInputView.h
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ChatOtherInputView;

typedef NS_ENUM(NSUInteger, OtherInputViewButtonTag) {
    OtherInputViewButtonTagImageFromCamera,
    OtherInputViewButtonTagImageFromPhotoLibrary,
    OtherInputViewButtonTagMovieFromCamera
};

@protocol ChatOtherInputViewDelegate <NSObject>

- (void)otherInputView:(ChatOtherInputView *)otherInputView didSelectButtonWithButtonTag:(OtherInputViewButtonTag)buttonTag;

@end

@interface ChatOtherInputView : UIView

@property (weak, nonatomic) id <ChatOtherInputViewDelegate> delegate;

@end
