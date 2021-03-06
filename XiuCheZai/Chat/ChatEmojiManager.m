//
//  ChatEmojiManager.m
//  XiuCheZai
//
//  Created by QSH on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatEmojiManager.h"
#import "ChatEmojiAttachment.h"

@implementation ChatEmojiManager

+ (NSAttributedString *)emojiStringFromPlainString:(NSString *)plainString withFont:(UIFont *)font {
    NSMutableAttributedString *emojiString = [[NSMutableAttributedString alloc] initWithString:plainString attributes:@{NSFontAttributeName:font}];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\^d_([a-z]*)\\^" options:0 error:nil];
    NSArray* matches = [regex matchesInString:[emojiString string] options:NSMatchingWithoutAnchoringBounds range:NSMakeRange(0, emojiString.length)];
    NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Emoji" ofType:@"json"]];
    NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
    CGSize emojiSize = CGSizeMake(font.lineHeight, font.lineHeight);
    
    for (NSTextCheckingResult* result in [matches reverseObjectEnumerator]) {
        NSRange matchRange = [result range];
        NSString *placeholder = [emojiString.string substringWithRange:matchRange];
        UIImage *emojiImage = [UIImage imageNamed:emojiJson[placeholder]];
        UIGraphicsBeginImageContextWithOptions(emojiSize, NO, 0.0);
        [emojiImage drawInRect:CGRectMake(0.0, 0.0, emojiSize.width, emojiSize.height)];
        UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        ChatEmojiAttachment *emojiAttachment = [[ChatEmojiAttachment alloc] init];
        emojiAttachment.emojiTag = placeholder;
        emojiAttachment.image = resizedImage;
        NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:emojiAttachment];
        [emojiString replaceCharactersInRange:matchRange withAttributedString:attachmentString];
    }
    return emojiString;
}

+ (NSString *)plainStringFromEmojiString:(NSAttributedString *)emojiString {
    NSMutableString *plainString = [emojiString.string mutableCopy];
    [emojiString enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, emojiString.length) options:NSAttributedStringEnumerationReverse usingBlock:^(id value, NSRange range, BOOL *stop) {
        if ([value isKindOfClass:[ChatEmojiAttachment class]]) [plainString replaceCharactersInRange:range withString:((ChatEmojiAttachment *)value).emojiTag];
    }];
    return plainString;
}

@end
