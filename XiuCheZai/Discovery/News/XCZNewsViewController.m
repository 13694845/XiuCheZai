//
//  XCZNewsViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsViewController.h"
#import "XCZNewsTableViewCell.h"
#import "XCZNewsDetailViewController.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "XCZNewsBannerView.h"

@interface XCZNewsViewController () <UITableViewDataSource, UITableViewDelegate, XCZNewsBannerViewDataSource, XCZNewsBannerViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (weak, nonatomic) XCZNewsBannerView *bannerView;
@property (strong, nonatomic) NSMutableArray *banners;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@property (nonatomic, strong) NSArray *oneRows;
@property (nonatomic, strong) NSArray *otherRows;

@end

@implementation XCZNewsViewController

@synthesize rows = _rows;
@synthesize banners = _banners;

- (void)setBanners:(NSMutableArray *)banners {
    _banners = banners;
 
    if (banners.count) {
        [self updateBannerView];
    }
}

- (NSMutableArray *)banners {
    return _banners;
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
//    NSLog(@"rows:%@", rows);
    self.currentPage++;
    [self endHeaderRefresh];
    [self endFooterRefresh];
    if (_rows.count) {
       [self updateTableView];
    }
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    for (UIView *view in self.bannerView.subviews) [view removeFromSuperview];
    
    XCZNewsBannerView *bannerView = [[XCZNewsBannerView alloc] init];
    CGFloat bannerViewW = self.tableView.bounds.size.width;
    CGFloat bannerViewH = (212.0/720) *bannerViewW;
    bannerView.frame = CGRectMake(0, 0, bannerViewW, bannerViewH);
    bannerView.dataSource = self;
    bannerView.delegate = self;
    self.tableView.tableHeaderView = bannerView;
    self.bannerView = bannerView;
    [self loadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
   
    
//     NSLog(@"view:%@", self.);
}

- (void)loadData {
    [self refreshData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)loadDataNeedsRefresh {
    self.currentPage = 1;
    [self requestHeaderViewNet];
    [self requestTableViewNet];
}

- (void)clearDataNeedsRefresh {
    
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)updateBannerView {
     [self.bannerView reloadData];
}

- (void)loadingMore
{
    [self requestTableViewNet];
}

#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
//     // 测试用
//    if (self.currentPage == 1) {
//        self.rows = [NSMutableArray arrayWithArray:self.oneRows];
//    } else {
//        self.otherRows = nil;
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.rows = [[self.rows arrayByAddingObjectsFromArray:self.otherRows] mutableCopy];
//        });
//    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsArtListAction.do"];
    NSDictionary *parameters = @{@"page":[NSString stringWithFormat:@"%d", self.currentPage], @"pagesize": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        if (self.currentPage == 1) {
            self.rows = [NSMutableArray arrayWithArray:rows];
        } else {
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
//         NSLog(@"rows:%@", self.rows);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)requestHeaderViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/LunBoAction.do"];
    NSDictionary *parameters = @{@"page_id":@"12", @"ad_id":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.banners = [[responseObject objectForKey:@"data"] objectForKey:@"detail"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

#pragma mark - bannerViewDelegate
- (NSArray *)bannersForBannerView:(XCZNewsBannerView *)bannerView
{
    return self.banners;
}

- (void)bannerView:(XCZNewsBannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo
{
    
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    CGFloat height = 0.0;
     NSDictionary *row = self.rows[indexPath.row];
    int img_num = [row[@"img_num"] intValue];
    if (img_num == 3) {
        height = 134;
    }
    if (img_num == 1) {
        height = 93;
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    NSDictionary *row = self.rows[indexPath.row];
    int img_num = [row[@"img_num"] intValue];
    if (img_num == 3) {
        identifier = @"CellA";
    }
    if (img_num == 1) {
        identifier = @"CellB";
    }
    XCZNewsTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.row = row;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XCZNewsDetailViewController *newsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsDetailViewController"];
    newsDetailViewController.artid = [self.rows[indexPath.row] objectForKey:@"artid"];
    [self.parentViewController.navigationController pushViewController:newsDetailViewController animated:YES];
}

#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
    if (!self.indicatorHeaderView) {
        CGFloat indicatorHeaderViewW = 40;
        CGFloat indicatorHeaderViewH = indicatorHeaderViewW;
        CGFloat indicatorHeaderViewX = (scrollView.bounds.size.width - indicatorHeaderViewW) * 0.5;
        CGFloat indicatorHeaderViewY = - indicatorHeaderViewH;
        UIActivityIndicatorView *indicatorHeaderView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorHeaderViewX, indicatorHeaderViewY, indicatorHeaderViewW, indicatorHeaderViewH)];
        indicatorHeaderView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorHeaderView.hidden = NO;
        [scrollView addSubview:indicatorHeaderView];
        self.indicatorHeaderView = indicatorHeaderView;
    }
}

- (void)morePullUpRefreshControl:(UIScrollView *)scrollView
{
    [self removeIndicatorHeaderView];
    if (!self.indicatorFooterView) {
        CGFloat indicatorFooterViewW = 40;
        CGFloat indicatorFooterViewH = indicatorFooterViewW;
        CGFloat indicatorFooterViewX = (scrollView.bounds.size.width - indicatorFooterViewW) * 0.5;
        CGFloat indicatorFooterViewY = scrollView.contentSize.height;
        UIActivityIndicatorView *indicatorFooterView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorFooterViewX, indicatorFooterViewY, indicatorFooterViewW, indicatorFooterViewH)];
        indicatorFooterView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        indicatorFooterView.hidden = NO;
        [scrollView addSubview:indicatorFooterView];
        self.indicatorFooterView = indicatorFooterView;
    }
}

- (void)startHeaderRefresh:(UIScrollView *)scrollView
{
    [self.indicatorHeaderView startAnimating];
    [self refreshData];
}

- (void)startFooterRefresh:(UIScrollView *)scrollView
{
    [self.indicatorFooterView startAnimating];
    [self loadingMore];
}

- (void)endHeaderRefresh
{
    if (self.tableView.contentOffset.y <= 0) {
        CGPoint offset = self.tableView.contentOffset;
        offset.y = 0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3 animations:^{
                self.tableView.contentOffset = offset;
            } completion:^(BOOL finished) {
                [self removeIndicatorHeaderView];
            }];
        });
    }
}

- (void)endFooterRefresh
{
    [self removeIndicatorFooterView];
}

- (void)stopHeaderScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    offset.y = -75;
    [scrollView setContentOffset:offset animated:YES];
}

- (void)stopFooterScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat dealtaH = scrollView.contentSize.height - scrollView.bounds.size.height;
    offset.y = dealtaH + 75;
    if (scrollView.contentSize.height < scrollView.bounds.size.height - 75) {
        offset.y = 0;
    }
    [scrollView setContentOffset:offset animated:YES];
}

- (void)removeIndicatorHeaderView
{
    [self.indicatorHeaderView stopAnimating];
    [self.indicatorHeaderView removeFromSuperview];
    self.indicatorHeaderView = nil;
}

- (void)removeIndicatorFooterView
{
    [self.indicatorFooterView stopAnimating];
    [self.indicatorFooterView removeFromSuperview];
    self.indicatorFooterView = nil;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
        if (bottomY > 75) {
            [self morePullUpRefreshControl:scrollView];
            [self stopFooterScroll:scrollView];
            [self startFooterRefresh:scrollView];
        }
    }
}



@end
