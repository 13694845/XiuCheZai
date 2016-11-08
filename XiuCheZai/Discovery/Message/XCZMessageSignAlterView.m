//
//  XCZMessageSignAlterView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/27.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageSignAlterView.h"

#define XCZMessageSignAlterViewAlertViewH 48

@interface XCZMessageSignAlterView()<UITextFieldDelegate>

@property (nonatomic, weak) UIView *alertView;
@property (nonatomic, weak) UIButton *determineBtn;
@property (nonatomic, weak) UITextField *textField;
@property (nonatomic, assign) CGFloat alertViewRectY;
@property (nonatomic, assign) int delegateMethodType; // 1.调用背景点击代理 2.确定按钮点击代理

@end

@implementation XCZMessageSignAlterView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height, frame.size.width, XCZMessageSignAlterViewAlertViewH)];
        alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:alertView];
        self.alertView = alertView;
        
        CGFloat determineBtnW = 50;
        CGFloat determineBtnH = 30;
        UIButton *determineBtn = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 8 - determineBtnW, (XCZMessageSignAlterViewAlertViewH - determineBtnH) * 0.5, determineBtnW, determineBtnH)];
        [determineBtn setTitle:@"确定" forState:UIControlStateNormal];
        [determineBtn setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
        determineBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [alertView addSubview:determineBtn];
        self.determineBtn = determineBtn;
        
        CGFloat textFieldH = 30;
        UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(8, (XCZMessageSignAlterViewAlertViewH - textFieldH) * 0.5, frame.size.width - determineBtnW - 8 - 16, textFieldH)];
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.placeholder = @"给自己来一个与众不同的签名吧!";
        textField.font = [UIFont systemFontOfSize:14];
        textField.delegate = self;
        [alertView addSubview:textField];
        self.textField = textField;
        
       CGRect alertViewRect = alertView.frame;
        alertViewRect.origin.y = frame.size.height - XCZMessageSignAlterViewAlertViewH;
        [UIView animateWithDuration:0.3 animations:^{
            alertView.frame = alertViewRect;
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backDidClick:)]];
        [determineBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(determineBtnDidClick)]];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                    name:@"UITextFieldTextDidChangeNotification"
                                                  object:textField];
    }
    return self;
}

- (void)backDidClick:(UIGestureRecognizer *)grz
{
    self.alertViewRectY = self.bounds.size.height;
    self.delegateMethodType = 1;
    [self.textField isFirstResponder] ? [self.textField resignFirstResponder] : [self hidenAlertView];
}

- (void)determineBtnDidClick
{
    self.alertViewRectY = self.bounds.size.height;
    self.delegateMethodType = 2;
    [self.textField isFirstResponder] ? [self.textField resignFirstResponder] : [self hidenAlertView];
}

- (void)hidenAlertView
{
    CGRect alertViewRect = self.alertView.frame;
    alertViewRect.origin.y = self.alertViewRectY;
    [UIView animateWithDuration:0.3 animations:^{
        self.alertView.frame = alertViewRect;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        if (self.delegateMethodType == 1) {
            if ([self.delegate respondsToSelector:@selector(messageSignAlterViewBackDidClick:)]) {
                [self.delegate messageSignAlterViewBackDidClick:self];
            }
        } else if (self.delegateMethodType == 2) {
            if ([self.delegate respondsToSelector:@selector(messageSignAlterView:determineBtnDidClick:)]) {
                [self.delegate messageSignAlterView:self determineBtnDidClick:self.textField];
            }
        }
    }];
}

#pragma mark - 通知处理
- (void)keyboardWillShow:(NSNotification *)notification
{
//    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect alertViewRect = self.alertView.frame;
//    alertViewRect.origin.y = self.bounds.size.height - keyboardFrame.size.height - self.alertView.bounds.size.height;
//    [UIView animateWithDuration:0.3 animations:^{
//        self.alertView.frame = alertViewRect;
//    }];
//    
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        CGRect keyboardFrame = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
        CGRect alertViewRect = self.alertView.frame;
        alertViewRect.origin.y = self.bounds.size.height - keyboardFrame.size.height - self.alertView.bounds.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            self.alertView.frame = alertViewRect;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self hidenAlertView];
}

#define kMaxLength 20

-(void)textFiledEditChanged:(NSNotification *)obj{
    UITextField *textField = (UITextField *)obj.object;
    
    NSString *toBeString = textField.text;
    NSString *lang = [[UITextInputMode currentInputMode] primaryLanguage]; // 键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) { // 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (toBeString.length > kMaxLength) {
                textField.text = [toBeString substringToIndex:kMaxLength];
                NSLog(@"textField:%@", textField);
            }
        } else { // 有高亮选择的字符串，则暂不对文字进行统计和限制
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (toBeString.length > kMaxLength) {
            textField.text = [toBeString substringToIndex:kMaxLength];
        }
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
