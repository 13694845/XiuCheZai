//
//  XCZEmotionLabel.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/9.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XCZTextAttachmentTwo;

@interface XCZTextAttachmentTwo : NSTextAttachment

@property(nonatomic, strong)NSDictionary *expression;
@property(nonatomic, copy)NSString *img;

@end


@interface XCZEmotionLabel : UILabel

/**
 *  拼接表情到光标后面
 */
- (void)appendEmotion:(NSDictionary *)expression;

- (NSString *)fullTextWithExpression;

@end
