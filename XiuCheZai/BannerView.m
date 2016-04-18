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

@property (nonatomic) NSArray *banners;
@property (nonatomic) int index;

@end

@implementation BannerView

- (NSArray *)banners {
    if (!_banners) _banners = @[@{kBannerImageKey:@"img/438f03803070a5ff855f8d361aa86c21.jpg", kBannerURLKey:@"/service/detail/index.html?uid=6716"},
                                @{kBannerImageKey:@"img/bfa756c4f82b4e00c75114f689f9fc67.jpg", kBannerURLKey:@"/ad/free_share/index.html"}];
    return _banners;
}

- (void)awakeFromNib {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@/%@", [manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LunBoAction.do"];
    NSDictionary *parameters = @{@"page_id":@"1", @"ad_id":@"1"};
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.banners = [[responseObject objectForKey:@"data"] objectForKey:@"detail"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

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
    
    [self resetImages];
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
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [Config webBaseURL], [self.banners[index] objectForKey:kBannerImageKey]]];
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
