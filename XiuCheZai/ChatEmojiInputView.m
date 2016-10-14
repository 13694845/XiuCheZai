//
//  ChatEmojiInputView.m
//  XiuCheZai
//
//  Created by QSH on 16/10/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ChatEmojiInputView.h"

@interface ChatEmojiInputView () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *contentView;

/*
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) UIImageView *currentImageView;
@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSArray *banners;
@property (nonatomic) int index;
*/

@end

@implementation ChatEmojiInputView

#define EMOJI_IMAGE_WIDTH       32.0
#define EMOJI_IMAGE_HEIGHT      32.0
// #define EMOJI_IMAGE_PADDING     10.0

- (instancetype)initWithFrame:(CGRect)frame {
    
    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        
        NSLog(@"initWithFrame : %@", NSStringFromCGRect(frame));
        
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmojiImages" ofType:@"json"]];
        NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *emojiImages = emojiJson[@"emojiImages"];
        
        CGFloat imagePadding = (frame.size.width - EMOJI_IMAGE_WIDTH * 7) / 14;
        
        
        int numberOfRows = ceil(emojiImages.count / 7.0);
        
        CGFloat contentViewHeight = (EMOJI_IMAGE_WIDTH + imagePadding * 2) * numberOfRows;
        
        for (int i = 0; i < numberOfRows; i++) {
            for (int j = 0; j < 7; j++) {
                if ((j + i * 7) > (emojiImages.count - 1)) break;
                
                UIImage *image = [UIImage imageNamed:emojiImages[j + i * 7][kEmojiImagePathKey]];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                
                
                imageView.frame = CGRectMake((EMOJI_IMAGE_WIDTH + imagePadding * 2) * j + imagePadding,
                                             (EMOJI_IMAGE_WIDTH + imagePadding * 2) * i + imagePadding, EMOJI_IMAGE_WIDTH, EMOJI_IMAGE_HEIGHT);
                
                [self addSubview:imageView];
                
                
            }

        }
        
        
        

    }
    return self;
}

@end
