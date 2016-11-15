//
//  XCZKeyboardExpressionView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/4.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZKeyboardExpressionView;

@interface XCZExBtn : UIButton
@property(nonatomic, strong)NSDictionary *expression;
@end

@protocol XCZKeyboardExpressionViewDelegate <NSObject>
@optional
- (void)expressionView:(XCZKeyboardExpressionView *)expressionView exBtnDidClick:(XCZExBtn *)exBtn;
@end

@interface XCZKeyboardExpressionView : UIView

@property (nonatomic, strong) NSArray *expressions;
@property (nonatomic, weak) id<XCZKeyboardExpressionViewDelegate> delegate;

@end
