//
//  ReminderView.m
//  XiuCheZai
//
//  Created by QSH on 16/4/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "ReminderView.h"

@interface ReminderView ()

@property (nonatomic) UITextView *textView;
@property (nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSString *text;
@property (nonatomic) CGFloat contentHeight;

@end

@implementation ReminderView

- (void)layoutSubviews {
    self.textView = [[UITextView alloc] initWithFrame:self.bounds];
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.font = [UIFont systemFontOfSize:13.0];
    self.textView.textColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
    [self addSubview:self.textView];
    
    [self reloadData];
}

- (void)reloadData {
    [self stopAutoPlay];
    self.text = [self.dataSource textForReminderView:self];
    [self startAutoPlay];
}

- (void)startAutoPlay {
    self.textView.text = self.text;
    self.contentHeight = self.textView.contentSize.height;
    self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.text, self.text];
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
}

- (void)stopAutoPlay {
    if (self.timer.valid) [self.timer invalidate];
}

- (void)autoPlay {
    CGFloat const kRowHeight = 15.5;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.textView.contentOffset = CGPointMake(0, self.textView.contentOffset.y + kRowHeight);
    } completion:^(BOOL finished) {
        if (self.textView.contentOffset.y + kRowHeight > self.contentHeight) self.textView.contentOffset = CGPointZero;
    }];
}

@end
