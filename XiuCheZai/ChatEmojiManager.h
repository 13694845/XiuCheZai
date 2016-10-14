//
//  ChatEmojiManager.h
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatEmojiManager : NSObject

+ (NSAttributedString *)emojiStringFromPlainString:(NSString *)plainString withFont:(UIFont *)font;
+ (NSString *)plainStringFromEmojiString:(NSAttributedString *)emojiString;

@end
