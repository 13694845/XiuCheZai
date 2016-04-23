//
//  BannerView.m
//  XiuCheZai
//
//  Created by QSH on 16/1/15.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "BannerView.h"
#import "Config.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface BannerView () <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) UIImageView *currentImageView;
@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSArray *banners;
@property (nonatomic) int index;

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
    self.currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 1, 0, self.bounds.size.width, self.bounds.size.height)];
    self.currentImageView.userInteractionEnabled = YES;
    [self.currentImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.currentImageView];
    self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 2, 0, self.bounds.size.width, self.bounds.size.height)];
    self.rightImageView.userInteractionEnabled = YES;
    [self.rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.rightImageView];
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.bounds.size.width - 45.0, self.bounds.size.height - 25.0, 30.0, 30.0)];
    self.pageControl.numberOfPages = self.banners.count;
    self.pageControl.currentPage = self.index;
    [self addSubview:self.pageControl];
    
    [self reloadData];
}

- (void)reloadData {
    self.banners = [self.dataSource bannersForBannerView:self];
    [self resetImages];
    [self stopAutoPlay];
    [self startAutoPlay];
}

- (void)resetImages {
    [self.leftImageView sd_setImageWithURL:[self imageURLLeftIndex:self.index]];
    [self.currentImageView sd_setImageWithURL:[self imageURLAtIndex:self.index]];
    [self.rightImageView sd_setImageWithURL:[self imageURLRightIndex:self.index]];
    self.scrollView.contentOffset = self.currentImageView.frame.origin;
    self.pageControl.currentPage = self.index;
}

- (NSURL *)imageURLAtIndex:(int)index {
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [Config baseURL], [self.banners[index] objectForKey:kBannerImageKey]]];
}

- (NSURL *)imageURLLeftIndex:(int)index {
    if (--index < 0) index = self.banners.count - 1;
    return [self imageURLAtIndex:index];
}

- (NSURL *)imageURLRightIndex:(int)index {
    if (++index == self.banners.count) index = 0;
    return [self imageURLAtIndex:index];
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
    if (++self.index == self.banners.count) self.index = 0;
    [self resetImages];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopAutoPlay];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == self.leftImageView.frame.origin.x) {
        if (--self.index < 0) self.index = self.banners.count - 1;
    }
    if (scrollView.contentOffset.x == self.rightImageView.frame.origin.x) {
        if (++self.index == self.banners.count) self.index = 0;
    }
    [self resetImages];
    [self startAutoPlay];
}

- (void)tapBanner:(UIGestureRecognizer *)sender {
    [self.delegate bannerView:self didSelectBanner:self.banners[self.index]];
}

@end
