//
//  ChatOtherInputView.m
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatOtherInputView.h"

@interface ChatOtherInputView ()

@property (strong, nonatomic) UIScrollView *scrollView;
@property (strong, nonatomic) UIView *contentView;
@property (strong, nonatomic) NSArray *buttonImages;

@end

@implementation ChatOtherInputView

#define NUMBER_OF_COLUMNS       4
#define BUTTON_WIDTH            50.0
#define BUTTON_HEIGHT           50.0

- (NSArray *)buttonImages {
    if (!_buttonImages) _buttonImages = @[@"camera", @"album", @"movie_camera", @"movie_pick"];
    return _buttonImages;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        CGFloat imagePadding = (frame.size.width - BUTTON_WIDTH * NUMBER_OF_COLUMNS) / (NUMBER_OF_COLUMNS * 2);
        int numberOfRows = ceil(self.buttonImages.count / (float)NUMBER_OF_COLUMNS);
        CGFloat contentViewHeight = (BUTTON_WIDTH + imagePadding * 2) * numberOfRows;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, contentViewHeight)];
        for (int i = 0; i < numberOfRows; i++) {
            for (int j = 0; j < NUMBER_OF_COLUMNS; j++) {
                if ((j + i * NUMBER_OF_COLUMNS) > (self.buttonImages.count - 1)) break;
                UIButton *button = [[UIButton alloc] init];
                button.layer.borderWidth = 1.0;
                button.layer.borderColor = [UIColor colorWithRed:221.0/255.0 green:221.0/255.0 blue:221.0/255.0 alpha:1.0].CGColor;
                button.layer.cornerRadius = 4.0;
                button.frame = CGRectMake((BUTTON_WIDTH + imagePadding * 2) * j + imagePadding, (BUTTON_WIDTH + imagePadding * 2) * i + imagePadding, BUTTON_WIDTH, BUTTON_HEIGHT);
                [button addTarget:self action:@selector(selectButton:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = j + i * NUMBER_OF_COLUMNS;
                UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.buttonImages[j + NUMBER_OF_COLUMNS * i]]];
                imageView.frame = CGRectMake((button.frame.size.width - 22.0) / 2, (button.frame.size.height - 22.0) / 2, 22.0, 22.0);
                [button addSubview:imageView];
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

- (void)selectButton:(UIButton *)sender {
    [self.delegate otherInputView:self didSelectButtonWithButtonTag:sender.tag];
}

@end
