//
//  BannerView.m
//  XiuCheZai
//
//  Created by QSH on 16/1/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "BannerView.h"
#import "Config.h"

@interface BannerView () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;

@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) int index;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSTimer *timer;

@end

@implementation BannerView

- (void)layoutSubviews {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor colorWithRed:240.0/255.0 green:240.0/255.0 blue:240.0/255.0 alpha:1.0];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    [self addSubview:self.scrollView];
    
    self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.leftImageView.userInteractionEnabled = YES;
    [self.leftImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.leftImageView];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 1, 0, self.bounds.size.width, self.bounds.size.height)];
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.imageView];
    self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 2, 0, self.bounds.size.width, self.bounds.size.height)];
    self.rightImageView.userInteractionEnabled = YES;
    [self.rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.rightImageView];
    [self reorderImages];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width - 45.0, self.bounds.size.height - 25.0, 30.0, 30.0)];
    self.pageControl.numberOfPages = [Config banners].count;
    self.pageControl.currentPage = self.index;
    [self addSubview:self.pageControl];
    
    [self startAutoPlay];
}

- (void)reorderImages {
    self.imageView.image = [self imageAtIndex:self.index];
    self.leftImageView.image = [self imageLeftIndex:self.index];
    self.rightImageView.image = [self imageRightIndex:self.index];
    self.scrollView.contentOffset = self.imageView.frame.origin;
    self.pageControl.currentPage = self.index;
}

- (UIImage *)imageAtIndex:(int)index {
    return [UIImage imageNamed:[[Config banners][index] objectForKey:@"image"]];
}

- (UIImage *)imageLeftIndex:(int)index {
    index --;
    if (index < 0) index = [Config banners].count - 1;
    return [UIImage imageNamed:[[Config banners][index] objectForKey:@"image"]];
}

- (UIImage *)imageRightIndex:(int)index {
    index ++;
    if (!(index < [Config banners].count)) index = 0;
    return [UIImage imageNamed:[[Config banners][index] objectForKey:@"image"]];
}

- (void)startAutoPlay {
    if (!self.timer.valid) self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(autoPlay) userInfo:nil repeats:YES];
}

- (void)stopAutoPlay {
    if (self.timer.valid) [self.timer invalidate];
}

- (void)autoPlay {
    [self.scrollView scrollRectToVisible:self.rightImageView.frame animated:YES];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.index ++;
    if (!(self.index < [Config banners].count)) self.index = 0;
    [self reorderImages];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoPlay];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == self.leftImageView.frame.origin.x) {
        self.index --;
        if (self.index < 0) self.index = [Config banners].count - 1;
    }
    if (scrollView.contentOffset.x == self.rightImageView.frame.origin.x) {
        self.index ++;
        if (!(self.index < [Config banners].count)) self.index = 0;
    }
    [self reorderImages];
    [self startAutoPlay];
}

- (void)tapBanner:(UIGestureRecognizer *)sender {
    [self.delegate bannerView:self didSelectBanner:[Config banners][self.index]];
}

@end
