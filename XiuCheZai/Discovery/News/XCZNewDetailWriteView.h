//
//  XCZNewDetailWriteView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/1.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZNewDetailWriteView;

@protocol XCZNewDetailWriteViewDelegate <NSObject>

@optional
- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn;
- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text;

@end

@interface XCZNewDetailWriteView : UIView

//commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
@property (nonatomic, weak) UITextView *commentTextView;
@property (nonatomic, weak) id<XCZNewDetailWriteViewDelegate> delegate;


@end
