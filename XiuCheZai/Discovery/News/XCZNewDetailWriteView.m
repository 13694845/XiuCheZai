//
//  XCZNewDetailWriteView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/1.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewDetailWriteView.h"
#import "DiscoveryConfig.h"
#define XCZNewDetailWriteViewTextViewPWordText @"说说您的看法"

@interface XCZNewDetailWriteView()<UITextViewDelegate>

@property (nonatomic, weak) UIView *commentView;
@property (nonatomic, weak) UIView *commentHeaderView;
@property (nonatomic, weak) UIButton *commentHeaderLeftBtn;
@property (nonatomic, weak) UIButton *commentHeaderRightBtn;
@property (nonatomic, weak) UILabel *commentHeaderTitleLabel;
@property (nonatomic, weak) UIView *commentHeaderLineView;
@property (nonatomic, weak) UIView *commentContentView;
@property (nonatomic, weak) UILabel *commentPlaceholderLabel;

@end

@implementation XCZNewDetailWriteView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.08];
        self.backgroundColor = [UIColor clearColor];
        
        UIView *commentView = [[UIView alloc] init];
        [self addSubview:commentView];
        self.commentView = commentView;
        
        UIView *commentHeaderView = [[UIView alloc] init];
        commentHeaderView.backgroundColor = [UIColor whiteColor];
        [commentView addSubview:commentHeaderView];
        self.commentHeaderView = commentHeaderView;
        
        UIButton *commentHeaderLeftBtn = [[UIButton alloc] init];
        [commentHeaderLeftBtn setTitle:@"取消" forState:UIControlStateNormal];
        commentHeaderLeftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentHeaderLeftBtn setTitleColor:[UIColor colorWithRed:231/255.0 green:156/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
        [commentHeaderView addSubview:commentHeaderLeftBtn];
        self.commentHeaderLeftBtn = commentHeaderLeftBtn;
        
        UIButton *commentHeaderRightBtn = [[UIButton alloc] init];
        [commentHeaderRightBtn setTitle:@"发送" forState:UIControlStateNormal];
        commentHeaderRightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [commentHeaderRightBtn setTitleColor:[UIColor colorWithRed:231/255.0 green:156/255.0 blue:25/255.0 alpha:1.0] forState:UIControlStateNormal];
        [commentHeaderView addSubview:commentHeaderRightBtn];
        self.commentHeaderRightBtn = commentHeaderRightBtn;
        
        UILabel *commentHeaderTitleLabel = [[UILabel alloc] init];
        commentHeaderTitleLabel.text = @"评论";
        commentHeaderTitleLabel.font = [UIFont systemFontOfSize:14];
        commentHeaderTitleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        [commentHeaderView addSubview:commentHeaderTitleLabel];
        self.commentHeaderTitleLabel = commentHeaderTitleLabel;
        
        UIView *commentHeaderLineView = [[UIView alloc] init];
        commentHeaderLineView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        [commentHeaderView addSubview:commentHeaderLineView];
        self.commentHeaderLineView = commentHeaderLineView;
        
        UIView *commentContentView = [[UIView alloc] init];
        commentContentView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [commentView addSubview:commentContentView];
        self.commentContentView = commentContentView;
        
        UITextView *commentTextView = [[UITextView alloc] init];
        commentTextView.backgroundColor = self.commentContentView.backgroundColor;
        commentTextView.text = @"";
        commentTextView.font = [UIFont systemFontOfSize:14];
        commentTextView.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        commentTextView.delegate = self;
        [commentContentView addSubview:commentTextView];
        self.commentTextView = commentTextView;
        
        UILabel *commentPlaceholderLabel = [[UILabel alloc] init];
        commentPlaceholderLabel.userInteractionEnabled = NO;
        commentPlaceholderLabel.text = XCZNewDetailWriteViewTextViewPWordText;
        commentPlaceholderLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        commentPlaceholderLabel.font = [UIFont systemFontOfSize:14];
        [commentTextView addSubview:commentPlaceholderLabel];
        self.commentPlaceholderLabel = commentPlaceholderLabel;
        
        [commentHeaderLeftBtn addTarget:self action:@selector(commentHeaderLeftBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [commentHeaderRightBtn addTarget:self action:@selector(commentHeaderRightBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self setupFrame];
}

- (void)setupFrame
{
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    CGFloat commentViewH;
    if (kDevice_Is_iPhone4) {
        commentViewH = 160;
    } else if (kDevice_Is_iPhone5 || kDevice_Is_iPhone6 || kDevice_Is_iPhone6Plus) {
        commentViewH = 174;
    }
    
    self.commentView.frame = CGRectMake(0, selfH - commentViewH, selfW, commentViewH);
    CGFloat commentHeaderLineViewH = 1.0;
    CGFloat commentHeaderViewH = 37;
    self.commentHeaderView.frame = CGRectMake(0, 0, selfW, commentHeaderViewH);
    CGFloat commentHeaderBtnW = 60;
    self.commentHeaderLeftBtn.frame = CGRectMake(0, 0, commentHeaderBtnW, commentHeaderViewH - commentHeaderLineViewH);
    self.commentHeaderRightBtn.frame = CGRectMake(selfW - commentHeaderBtnW, 0, commentHeaderBtnW, commentHeaderViewH - commentHeaderLineViewH);
    self.commentHeaderTitleLabel.frame = CGRectMake((selfW - commentHeaderBtnW) * 0.5, 0, commentHeaderBtnW, commentHeaderViewH - commentHeaderLineViewH);
    self.commentHeaderLineView.frame = CGRectMake(0, commentHeaderViewH - commentHeaderLineViewH, selfW, commentHeaderLineViewH);
    CGFloat commentContentViewH = commentViewH - commentHeaderViewH;
    self.commentContentView.frame = CGRectMake(0, CGRectGetMaxY(self.commentHeaderView.frame), self.commentView.bounds.size.width, commentContentViewH);
    CGFloat commentTextFieldX = 8;
    CGFloat commentTextFieldY = 0;
    CGFloat commentTextFieldW = selfW - 2 * commentTextFieldX;
    CGFloat commentTextFieldH = commentContentViewH - 2 * commentTextFieldY;
    self.commentTextView.frame = CGRectMake(commentTextFieldX, commentTextFieldY, commentTextFieldW, commentTextFieldH);
    
    self.commentPlaceholderLabel.frame = CGRectMake(8, 10, 120, 14);
}

- (void)commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
{
    if ([self.delegate respondsToSelector:@selector(newDetailWriteView:commentHeaderLeftBtnDidClick:)]) {
        [self.delegate newDetailWriteView:self commentHeaderLeftBtnDidClick:commentHeaderLeftBtn];
    }
}

- (void)commentHeaderRightBtnDidClick:(UIButton *)commentHeaderRightBtn
{
    if ([self.delegate respondsToSelector:@selector(newDetailWriteView:commentHeaderRightBtnDidClickWithText:)]) {
        [self.delegate newDetailWriteView:self commentHeaderRightBtnDidClickWithText:self.commentTextView.text];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.commentPlaceholderLabel.text = @"";
    } else {
        self.commentPlaceholderLabel.text = XCZNewDetailWriteViewTextViewPWordText;
    }
}


@end
