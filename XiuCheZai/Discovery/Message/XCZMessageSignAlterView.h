//
//  XCZMessageSignAlterView.h
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/27.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XCZMessageSignAlterView;

@protocol XCZMessageSignAlterViewDelegate <NSObject>

@optional
- (void)messageSignAlterViewBackDidClick:(XCZMessageSignAlterView *)alterView;
- (void)messageSignAlterView:(XCZMessageSignAlterView *)alterView determineBtnDidClick:(UITextField *)textField;

@end



@interface XCZMessageSignAlterView : UIView

@property (nonatomic, weak) id<XCZMessageSignAlterViewDelegate> delegate;

@end
