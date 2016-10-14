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

- (instancetype)initWithFrame:(CGRect)frame {
    
    NSLog(@"initWithFrame");
    self = [super initWithFrame:frame];
    if (self) {
        
        NSLog(@"initWithFrame : %@", NSStringFromCGRect(frame));
        
        
        
        
        
        NSData *emojiData = [[NSData alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"EmojiImages" ofType:@"json"]];
        NSDictionary *emojiJson = [NSJSONSerialization JSONObjectWithData:emojiData options:NSJSONReadingMutableLeaves error:nil];
        NSArray *emojiImages = emojiJson[@"emojiImages"];
        

    }
    return self;
}

@end
