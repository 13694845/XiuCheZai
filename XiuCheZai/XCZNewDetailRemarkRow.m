//
//  XCZNewDetailRemarkCell.m
//  XiuCheZai
//
//  Created by QSH on 16/9/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewDetailRemarkRow.h"

@interface XCZNewDetailRemarkRow ()

@property (nonatomic, assign) CGFloat height;

@end

@implementation XCZNewDetailRemarkRow

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // UIView *subView = [[UIView alloc] init];
    // [self addSubview:subView];
    // self.height += subView.bound.size.height;
    // ...
    // self.frame.size.height = self.height;
}

- (CGFloat)height {
    return _height;
}

@end
