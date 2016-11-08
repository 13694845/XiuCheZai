//
//  UIPublishTextPhoneView.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishTextPhoneView.h"
#import "XCZPublishTextPhoneButton.h"
#import "MBProgressHUD+ZHM.h"


@interface XCZPublishTextPhoneView()


/** 2.phoneBtns */
@property (nonatomic, strong) NSMutableArray *phoneBtns;
/** 3.showImages */
@property (nonatomic, strong) NSMutableArray *showImages;

@end

@implementation XCZPublishTextPhoneView

- (NSMutableArray *)phoneBtns
{
    if (_phoneBtns == nil) {
        _phoneBtns = [NSMutableArray array];
    }
    return _phoneBtns;
}

static CGFloat const XCZPublishTextPhoneButtonMarginX = 16;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UITextField *titleField = [[UITextField alloc] initWithFrame:CGRectMake(16, 16, frame.size.width - 32, 18)];
        titleField.placeholder = @" 标题可选";
        [self addSubview:titleField];
        self.titleField = titleField;
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(titleField.frame) + 8 + 16, frame.size.width - 32, 101)];
        textView.text = @"";
        textView.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        [self addSubview:textView];
        self.textView = textView;
        
        UILabel *commentPlaceholderLabel = [[UILabel alloc] init];
        commentPlaceholderLabel.userInteractionEnabled = NO;
        commentPlaceholderLabel.text = XCZPublishTextPhoneViewPWordText;
        commentPlaceholderLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        commentPlaceholderLabel.font = [UIFont systemFontOfSize:14];
        commentPlaceholderLabel.frame = CGRectMake(8, 8, 120, 14);
        [textView addSubview:commentPlaceholderLabel];
        self.commentPlaceholderLabel = commentPlaceholderLabel;
        
        CGFloat phoneBtnMarginX = 16;
        CGFloat phoneBtnW = (frame.size.width - 5 * phoneBtnMarginX) * 0.25;
        CGFloat phoneBtnH = phoneBtnW;
        XCZPublishTextPhoneButton *phoneBtn = [[XCZPublishTextPhoneButton alloc] initWithFrame:CGRectMake(phoneBtnMarginX, CGRectGetMaxY(textView.frame) + XCZPublishTextPhoneButtonMarginX, phoneBtnW, phoneBtnH)];
        [self addSubview:phoneBtn];
        [self.phoneBtns addObject:phoneBtn];
        
        [self outgingPhoneBtns];
    }
    return self;
}

- (void)setIsNoTopic:(BOOL)isNoTopic
{
    _isNoTopic = isNoTopic;
    
    if (isNoTopic) {
        CGRect textViewRect = self.textView.frame;
        textViewRect.origin.y = 16;
        self.textView.frame = textViewRect;
        XCZPublishTextPhoneButton *phoneBtn = [self.phoneBtns firstObject];
        CGRect phoneBtnRect = phoneBtn.frame;
        phoneBtnRect.origin.y = CGRectGetMaxY(self.textView.frame) + XCZPublishTextPhoneButtonMarginX;
        phoneBtn.frame = phoneBtnRect;
        [self.titleField removeFromSuperview];
        self.titleField = nil;
    }
}

- (void)setImageDict:(NSDictionary *)imageDict
{
    _imageDict = imageDict;
    
    for (int i = 0; i<self.phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = self.phoneBtns[i];
        if (self.selectedPhoneBtnTag == phoneBtn.tag) {
            phoneBtn.imageDict = imageDict;
        }
    }
    
    if (self.selectedPhoneBtnTag == (self.phoneBtns.count - 1)) {
        XCZPublishTextPhoneButton *lastPhoneBtn = [self.phoneBtns lastObject];
        // 创建phoneBtn
            CGFloat phoneBtnX = !(self.phoneBtns.count % 4) ? XCZPublishTextPhoneButtonMarginX : CGRectGetMaxX(lastPhoneBtn.frame) + XCZPublishTextPhoneButtonMarginX;
            CGFloat phoneBtnY = !(self.phoneBtns.count % 4) ? CGRectGetMaxY(lastPhoneBtn.frame) + XCZPublishTextPhoneButtonMarginX : lastPhoneBtn.frame.origin.y;
         if (self.phoneBtns.count <= 8) {
            XCZPublishTextPhoneButton *phoneBtn = [[XCZPublishTextPhoneButton alloc] initWithFrame:CGRectMake(phoneBtnX, phoneBtnY, lastPhoneBtn.bounds.size.width, lastPhoneBtn.bounds.size.height)];
            [self addSubview:phoneBtn];
            [self.phoneBtns addObject:phoneBtn];
//            lastPhoneBtn = phoneBtn;
        }
        
        // 设置代理方法
        [self outgingPhoneBtns];
        
        if (!((self.phoneBtns.count - 1) % 4)) {
            if ([self.delegate respondsToSelector:@selector(textPhoneView:lastPhoneButton:height:)]) {
                [self.delegate textPhoneView:self lastPhoneButton:[self.phoneBtns lastObject] height:phoneBtnY + lastPhoneBtn.bounds.size.height];
            }
        }
    }
    if ([self.delegate respondsToSelector:@selector(textPhoneView:phoneBtns:)]) {
        [self.delegate textPhoneView:self phoneBtns:self.phoneBtns];
    }
}

- (void)frameHasChange
{
    [self outgingPhoneBtns];
}

- (void)outgingPhoneBtns
{
    NSMutableArray *showImages = [NSMutableArray array];
    for (int i = 0; i<self.phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = self.phoneBtns[i];
        phoneBtn.tag = i;
        [phoneBtn addTarget:self action:@selector(phoneBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        if (phoneBtn.currentImage) {
            [showImages addObject:phoneBtn.currentImage];
        }
    }
}

- (void)phoneBtnDidClick:(XCZPublishTextPhoneButton *)phoneBtn
{
    if ([self.delegate respondsToSelector:@selector(textPhoneView:phoneBtnDidClick:)]) {
        [self.delegate textPhoneView:self phoneBtnDidClick:phoneBtn];
    }
}

- (void)setRemoveImageDict:(NSDictionary *)removeImageDict
{
    _removeImageDict = removeImageDict;
    
    for (int i = 0; i<self.phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = self.phoneBtns[i];
        if (phoneBtn.tag == self.selectedPhoneBtnTag) {
            [self.phoneBtns removeObject:phoneBtn];
            [phoneBtn removeFromSuperview];
            phoneBtn = nil;
            if (self.selectedPhoneBtnTag == 8) {
                XCZPublishTextPhoneButton *phoneBtn7 = self.phoneBtns[7];
                XCZPublishTextPhoneButton *phoneBtn = [[XCZPublishTextPhoneButton alloc] initWithFrame:CGRectMake(XCZPublishTextPhoneButtonMarginX, phoneBtn7.frame.origin.y + phoneBtn7.bounds.size.height + XCZPublishTextPhoneButtonMarginX, phoneBtn7.bounds.size.width, phoneBtn7.bounds.size.height)];
                phoneBtn.tag = 8;
                [self addSubview:phoneBtn];
                [self.phoneBtns addObject:phoneBtn];
            }
        }
    }
    
    for (int i = 0; i<self.phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = self.phoneBtns[i];
        if (phoneBtn.tag > self.selectedPhoneBtnTag) {
            CGRect rect =  phoneBtn.frame;
            if (i == 3 || i == 7) { // 向上移
                rect.origin.y -= rect.size.height + XCZPublishTextPhoneButtonMarginX;
                rect.origin.x = self.bounds.size.width - XCZPublishTextPhoneButtonMarginX - rect.size.width;
            } else { // 向左移
                rect.origin.x -= rect.size.width + XCZPublishTextPhoneButtonMarginX;
            }
            [UIView animateWithDuration:0.3 animations:^{
                phoneBtn.frame = rect;
            }];
        }
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        XCZPublishTextPhoneButton *lastPhoneBtn = [self.phoneBtns lastObject];
        CGFloat height = CGRectGetMaxY(lastPhoneBtn.frame);
        if ([self.delegate respondsToSelector:@selector(textPhoneView:lastPhoneButton:height:)]) {
            [self.delegate textPhoneView:self lastPhoneButton:[self.phoneBtns lastObject] height:height];
        }
    } completion:^(BOOL finished) {
        [MBProgressHUD ZHMShowSuccess:@"已删除"];
        XCZPublishTextPhoneButton *zuihouPhoneBtn = [self.phoneBtns lastObject];
        if (zuihouPhoneBtn.currentImage) {
            XCZPublishTextPhoneButton *zuihoujiaPhoneBtn = [[XCZPublishTextPhoneButton alloc] initWithFrame:CGRectMake(XCZPublishTextPhoneButtonMarginX, CGRectGetMaxY(zuihouPhoneBtn.frame) + XCZPublishTextPhoneButtonMarginX, zuihouPhoneBtn.bounds.size.width, zuihouPhoneBtn.bounds.size.height)];
            [self addSubview:zuihoujiaPhoneBtn];
            [self.phoneBtns addObject:zuihoujiaPhoneBtn];
            
            CGFloat height = CGRectGetMaxY(zuihoujiaPhoneBtn.frame);
            if ([self.delegate respondsToSelector:@selector(textPhoneView:lastPhoneButton:height:)]) {
                [self.delegate textPhoneView:self lastPhoneButton:[self.phoneBtns lastObject] height:height];
            }
        }
    }];
}



@end
