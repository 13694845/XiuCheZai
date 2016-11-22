//
//  XCZActivityViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZActivityViewController.h"
#import "XCZActivityTableViewCell.h"
#import "XCZActivityDetailViewController.h"
#import "XCZConfig.h"

@interface XCZActivityViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;
@property (assign, nonatomic) CGFloat cellHeight;
@property (assign, nonatomic) BOOL hasNoFooterData;

@end

@implementation XCZActivityViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
    self.currentPage++;
    [self updateTableView];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellHeight:) name:@"XCZActivityTableViewCellToVCSetupCellHeightNot" object:nil];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//    [self.tabBarController.tabBar setHidden:NO];
     self.navigationController.navigationBar.translucent = NO;
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
    [self requestTableViewNet];
}

- (void)clearDataNeedsRefresh {
    
}

- (void)loadingMore
{
    [self requestTableViewNet];
}

- (void)cellHeight:(NSNotification *)notification
{
    self.cellHeight = [[notification.userInfo objectForKey:@"cellHeight"] floatValue];
}

#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/QueryPostListAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"6"], @"page":[NSString stringWithFormat:@"%d", self.currentPage], @"pagesize": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        if (self.currentPage == 1) {
            self.hasNoFooterData = NO;
            [self endHeaderRefresh];
            self.rows = [rows mutableCopy];
        } else {
            self.hasNoFooterData = rows.count ? NO : YES;
            [self endFooterRefresh];
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (!self.cellHeight) {
        self.cellHeight = 77.5;
    }
    return self.cellHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    XCZActivityTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[XCZActivityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.cellW = self.tableView.bounds.size.width;
    cell.row = self.rows[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // 跳到话题详情
    XCZActivityDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZActivityDetailViewController"];
    NSDictionary *row = self.rows[indexPath.row];
    
    NSString *identifier;
    NSString *post_clazz = row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 2) { // 投票贴，暂时没有
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
        if (imageArray.count == 1) {
            identifier = @"CellB";
        } else if (imageArray.count <= 3) {
            identifier = @"CellA1";
        } else if (imageArray.count <= 6) {
            identifier = @"CellA";
        } else {
            identifier = @"CellA2";
        }
    } else if ([post_clazz intValue] == 4) {
            identifier = @"CellC1";
    }
    circleDetailVC.post_id = row[@"post_id"];
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [imageArray addObject:[imageStrs substringToIndex:range.location]];
        [self changeImage:[imageStrs substringFromIndex:(range.location + 1)] andImageArray:imageArray];
    } else {
        [imageArray addObject:imageStrs];
    }
    return imageArray;
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
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView setContentOffset:offset animated:NO];
    }];
}

- (void)stopFooterScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    CGFloat dealtaH = scrollView.contentSize.height - scrollView.bounds.size.height;
    offset.y = dealtaH + 75;
    if (scrollView.contentSize.height < scrollView.bounds.size.height - 75) {
        offset.y = 0;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        [scrollView setContentOffset:offset animated:NO];
    } completion:^(BOOL finished) {
    }];
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
    
    if (self.hasNoFooterData) {
        UITableView *scrollView;
        for (UIView *view in self.view.subviews) {
            if ([view isKindOfClass:[UITableView class]]) {
                scrollView = (UITableView *)view;
                
                //                NSLog(@"", scrollView.tableFooterView);
            }
        }
        UILabel *noMoreShowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, scrollView.contentSize.height, scrollView.bounds.size.width, 20)];
        noMoreShowLabel.text = @"没有更多了~~";
        noMoreShowLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
        noMoreShowLabel.font = [UIFont systemFontOfSize:12];
        noMoreShowLabel.textAlignment = NSTextAlignmentCenter;
        scrollView.tableFooterView = noMoreShowLabel;
        //        [scrollView.tableFooterView addSubview:noMoreShowLabel];
        scrollView.contentSize = CGSizeMake(scrollView.bounds.size.width, scrollView.contentSize.height + 75);
    }
}

- (void)removeNoMoreShowLabel:(UIScrollView *)scrollView
{
    for (UIView *subView in scrollView.subviews) {
        if ([subView isKindOfClass:[UILabel class]]) {
            UILabel *noMorelabel = (UILabel *)subView;
            [noMorelabel removeFromSuperview];
            noMorelabel = nil;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self removeNoMoreShowLabel:scrollView];
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
        if (bottomY > 75) {
            [self removeNoMoreShowLabel:scrollView];
            [self morePullUpRefreshControl:scrollView];
            [self stopFooterScroll:scrollView];
            [self startFooterRefresh:scrollView];
        }
    }
}


@end
