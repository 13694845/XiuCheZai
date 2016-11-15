//
//  QCEmotionTextView.h
//  cehx
//
//  Created by 企商汇 on 16/4/23.
//  Copyright © 2016年 qishanghui. All rights reserved.
//
//  input输入框
//

#import <UIKit/UIKit.h>
@class XCZTextAttachment;

@interface XCZTextAttachment : NSTextAttachment

@property(nonatomic, strong)NSDictionary *expression;
@property(nonatomic, copy)NSString *img;

@end

@interface XCZEmotionTextView : UITextView

/**
 *  拼接表情到光标后面
 */
- (void)appendEmotion:(NSDictionary *)expression;

- (NSString *)fullTextWithExpression;

@end
