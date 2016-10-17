//
//  ChatOtherInputView.m
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatOtherInputView.h"

@interface ChatOtherInputView () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSArray *buttonImages;

@end

@implementation ChatOtherInputView

#define BUTTON_IMAGE_WIDTH       50.0
#define BUTTON_IMAGE_HEIGHT      50.0

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonImages = @[@"vic", @"add"];
        
        CGFloat imagePadding = (frame.size.width - BUTTON_IMAGE_WIDTH * 5) / 10;
        int numberOfRows = ceil(self.buttonImages.count / 5.0);
        CGFloat contentViewHeight = (BUTTON_IMAGE_WIDTH + imagePadding * 2) * numberOfRows;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, contentViewHeight)];
        for (int i = 0; i < numberOfRows; i++) {
            for (int j = 0; j < 5; j++) {
                if ((j + i * 5) > (self.buttonImages.count - 1)) break;
                UIButton *button = [[UIButton alloc] init];
                [button setBackgroundImage:[UIImage imageNamed:self.buttonImages[j + i * 7]] forState:UIControlStateNormal];
                button.frame = CGRectMake((BUTTON_IMAGE_WIDTH + imagePadding * 2) * j + imagePadding,
                                          (BUTTON_IMAGE_WIDTH + imagePadding * 2) * i + imagePadding, BUTTON_IMAGE_WIDTH, BUTTON_IMAGE_HEIGHT);
                [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = j + i * 5;
                [self.contentView addSubview:button];
            }
        }
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = self.contentView.frame.size;
        [self.scrollView addSubview:_contentView];
        [self addSubview:self.scrollView];
    }
    return self;
}

- (void)selectButton:(id)sender {
    [self.delegate otherInputView:self didSelectButton:((UIButton *)sender).tag];
}

@end
