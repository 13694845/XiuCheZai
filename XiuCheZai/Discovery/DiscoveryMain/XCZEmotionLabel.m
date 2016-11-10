//
//  XCZEmotionLabel.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/9.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZEmotionLabel.h"

@implementation XCZTextAttachmentTwo

- (void)setExpression:(NSDictionary *)expression
{
    _expression = expression;
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", expression[@"facePath"]]];
}

- (void)setImg:(NSString *)img
{
    _img = img;
    
//    NSLog(@"img:%@", img);
    
    self.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@", img]];
}


@end

@interface XCZEmotionLabel()

@property(nonatomic, strong)NSDictionary *expression;

@end

@implementation XCZEmotionLabel

- (void)appendEmotion:(NSDictionary *)expression
{
    _expression = expression;
    
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
    
    // 创建一个带有图片表情的富文本
    XCZTextAttachmentTwo *attach = [[XCZTextAttachmentTwo alloc] init];
    attach.expression = expression;
    attach.bounds = CGRectMake(0, -3, self.font.lineHeight, self.font.lineHeight);
    NSAttributedString *attachString = [NSAttributedString attributedStringWithAttachment:attach];
    
    // 记录表情的插入位置
    NSUInteger insertIndex = self.text.length;
    
    // 插入表情图片到光标位置
    [attributedText insertAttributedString:attachString atIndex:insertIndex];
    // 设置字体
    [attributedText addAttribute:NSFontAttributeName value:self.font range:NSMakeRange(0, attributedText.length)];
    
    // 重新赋值(光标会自动回到文字的最后面)
    self.attributedText = attributedText;
}

- (NSString *)fullTextWithExpression
{
    // 1.用来拼接所有文字
    NSMutableString *string = [NSMutableString string];
    
    // 2.遍历富文本里面的所有内容
    [self.attributedText enumerateAttributesInRange:NSMakeRange(0, self.attributedText.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        XCZTextAttachmentTwo *attach = attrs[@"NSAttachment"];
        if (attach) { // 如果是带有附件的富文本
            [string appendString:[NSString stringWithFormat:@"[%@]", attach.expression[@"faceName"]]];
        } else { // 普通的文本
            // 截取range范围的普通文本
            NSString *substr = [self.attributedText attributedSubstringFromRange:range].string;
            [string appendString:substr];
        }
    }];
    
    return string;
}


@end
