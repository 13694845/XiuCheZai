//
//  ChatOtherInputView.m
//  XiuCheZai
//
//  Created by QSH on 16/10/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatOtherInputView.h"

@implementation ChatOtherInputView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor grayColor];
        
        /*
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmojiImages" ofType:@"json"]];
        NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
        self.emojiImages = emojiJson[@"emojiImages"];
        
        CGFloat imagePadding = (frame.size.width - EMOJI_IMAGE_WIDTH * 7) / 14;
        int numberOfRows = ceil(self.emojiImages.count / 7.0);
        CGFloat contentViewHeight = (EMOJI_IMAGE_WIDTH + imagePadding * 2) * numberOfRows;
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, contentViewHeight)];
        for (int i = 0; i < numberOfRows; i++) {
            for (int j = 0; j < 7; j++) {
                if ((j + i * 7) > (self.emojiImages.count - 1)) break;
                UIButton *button = [[UIButton alloc] init];
                [button setBackgroundImage:[UIImage imageNamed:self.emojiImages[j + i * 7][kEmojiImagePathKey]] forState:UIControlStateNormal];
                button.frame = CGRectMake((EMOJI_IMAGE_WIDTH + imagePadding * 2) * j + imagePadding,
                                          (EMOJI_IMAGE_WIDTH + imagePadding * 2) * i + imagePadding, EMOJI_IMAGE_WIDTH, EMOJI_IMAGE_HEIGHT);
                [button addTarget:self action:@selector(selectEmoji:) forControlEvents:UIControlEventTouchUpInside];
                button.tag = j + i * 7;
                [self.contentView addSubview:button];
            }
        }
        self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.contentSize = self.contentView.frame.size;
        [self.scrollView addSubview:_contentView];
        [self addSubview:self.scrollView];
         */
    }
    return self;
}

- (void)selectEmoji:(id)sender {
    // [self.delegate emojiInputView:self didSelectEmoji:self.emojiImages[((UIButton *)sender).tag]];
}

@end
