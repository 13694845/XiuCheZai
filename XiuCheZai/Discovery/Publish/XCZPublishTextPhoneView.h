//
//  UIPublishTextPhoneView.h
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
#define XCZPublishTextPhoneViewPWordText @"当下的感想"

@class XCZPublishTextPhoneView, XCZPublishTextPhoneButton;

@protocol XCZPublishTextPhoneViewDelegate <NSObject>
@optional

- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtns:(NSArray *)phoneBtns;
- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtnDidClick:(XCZPublishTextPhoneButton *)selectedPhoneButton;
- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtnRemoveOver:(NSArray *)phoneBtns;
- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView lastPhoneButton:(XCZPublishTextPhoneButton *)lastPhoneButton  height:(CGFloat)height;
@end

@interface XCZPublishTextPhoneView : UIView

@property (nonatomic, strong) UITextField *titleField;
@property (nonatomic, weak) UITextView *textView;
@property (nonatomic, strong) NSMutableArray *phoneBtns;
/** 是否没有标题 YES:没有标题 NO:有标题 */
@property (nonatomic, assign) BOOL isNoTopic;
@property (nonatomic, assign) NSInteger selectedPhoneBtnTag;
@property (nonatomic, strong) NSDictionary *imageDict;
@property (nonatomic, strong) NSDictionary *removeImageDict;
@property (nonatomic, weak) UILabel *commentPlaceholderLabel;

@property (nonatomic, weak) id<XCZPublishTextPhoneViewDelegate> delegate;

- (void)frameHasChange;

@end
