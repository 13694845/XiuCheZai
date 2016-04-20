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

@property (nonatomic, copy) NSString *text;

@end

@implementation ReminderView

- (void)layoutSubviews {
    self.textView = [[UITextView alloc] initWithFrame:self.bounds];
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.font = [UIFont systemFontOfSize:13.0];
    [self addSubview:self.textView];
    
    [self reloadData];
}

- (void)reloadData {
    self.text = [self.dataSource textForReminderView:self];
    [self stopAutoPlay];
    [self startAutoPlay];
}

- (void)startAutoPlay {
    self.textView.text = self.text;
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
}

- (void)stopAutoPlay {
    if (self.timer.valid) [self.timer invalidate];
}

#define LINE_HEIGHT 15.0

- (void)autoPlay {
    if (self.textView.contentOffset.y + LINE_HEIGHT * 2 > self.textView.contentSize.height) {
        self.textView.text = [NSString stringWithFormat:@"%@\n%@", self.text, self.text];
        [UIView animateWithDuration:0.5 animations:^{
            self.textView.contentOffset = CGPointMake(0, self.textView.contentOffset.y + LINE_HEIGHT);
        } completion:^(BOOL finished) {
            self.textView.text = self.text;
            self.textView.contentOffset = CGPointZero;
        }];
        return;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.textView.contentOffset = CGPointMake(0, self.textView.contentOffset.y + LINE_HEIGHT);
    }];
}

@end
