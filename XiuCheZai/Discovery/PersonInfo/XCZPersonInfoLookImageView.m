//
//  XCZPersonInfoLookImageView.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoLookImageView.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface XCZPersonInfoLookImageView() <UIScrollViewDelegate>

@property (nonatomic) UIScrollView *scrollView;
@property (nonatomic) UIImageView *leftImageView;
@property (nonatomic) UIImageView *currentImageView;
@property (nonatomic) UIImageView *rightImageView;
@property (nonatomic) UIPageControl *pageControl;
@property (nonatomic) NSTimer *timer;

@property (copy, nonatomic) NSArray *banners;
@property (nonatomic) int index;

@end

@implementation XCZPersonInfoLookImageView

- (void)layoutSubviews {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.frame];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = [UIColor blackColor];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.contentSize = CGSizeMake(self.bounds.size.width * 3, self.bounds.size.height);
    [self addSubview:self.scrollView];
    self.leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.leftImageView.userInteractionEnabled = YES;
    self.leftImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.leftImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.leftImageView];
    self.currentImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 1, 0, self.bounds.size.width, self.bounds.size.height)];
    self.currentImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.currentImageView.userInteractionEnabled = YES;
    [self.currentImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.currentImageView];
    self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.bounds.size.width * 2, 0, self.bounds.size.width, self.bounds.size.height)];
    self.rightImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.rightImageView.userInteractionEnabled = YES;
    [self.rightImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBanner:)]];
    [self.scrollView addSubview:self.rightImageView];
    self.pageControl = [[UIPageControl alloc] init];
    [self addSubview:self.pageControl];
    [self reloadData];
}

- (void)reloadData {
//    [self stopAutoPlay];
    self.banners = [self.dataSource bannersForBannerView:self];
    [self resetPages];
    [self resetImages];
//    [self startAutoPlay];
}

- (void)resetPages {
    CGSize size = [self.pageControl sizeForNumberOfPages:self.banners.count];
    self.pageControl.frame = CGRectMake((self.bounds.size.width - size.width) * 0.5, self.bounds.size.height - size.height + 10.0, size.width, size.height);
    self.pageControl.numberOfPages = self.banners.count;
    self.pageControl.currentPage = self.index;
}

- (void)resetImages {
    [self.leftImageView sd_setImageWithURL:[self imageURLLeftIndex:self.index] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    [self.currentImageView sd_setImageWithURL:[self imageURLAtIndex:self.index] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    [self.rightImageView sd_setImageWithURL:[self imageURLRightIndex:self.index] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic.jpg"]];
    
    self.scrollView.contentOffset = self.currentImageView.frame.origin;
    self.pageControl.currentPage = self.index;
    if ([self.delegate respondsToSelector:@selector(bannerView:currentImageNum:currentImage:)]) {
        [self.delegate bannerView:self currentImageNum:(self.index + 1) currentImage:self.currentImageView.image];
    }
}

- (NSURL *)imageURLAtIndex:(int)index {
    if (index < 0 || index >= self.banners.count) return nil;
    
    NSString *chuanruUrlStr = self.banners[index];
    if (![chuanruUrlStr containsString:@"http"]) {
        chuanruUrlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], chuanruUrlStr];
    }
    return [NSURL URLWithString:chuanruUrlStr];
}

- (NSURL *)imageURLLeftIndex:(int)index {
    if (--index < 0) index = self.banners.count - 1;
    return [self imageURLAtIndex:index];
}

- (NSURL *)imageURLRightIndex:(int)index {
    if (++index >= self.banners.count) index = 0;
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
    if (++self.index >= self.banners.count) self.index = 0;
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
        if (++self.index >= self.banners.count) self.index = 0;
    }
    [self resetImages];
}

- (void)tapBanner:(UIGestureRecognizer *)sender {
    [self.delegate bannerView:self didSelectBanner:self.banners[self.index]];
}


@end
