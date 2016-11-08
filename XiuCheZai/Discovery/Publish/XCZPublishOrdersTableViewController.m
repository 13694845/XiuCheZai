//
//  XCZPublishOrdersTableViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishOrdersTableViewController.h"
#import "XCZPublishOrdersTableViewCell.h"
#import "XCZPublishOrderViewController.h"
#import "XCZConfig.h"
#import "XCZPublishNoOrdersView.h"
#import "DiscoveryConfig.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZPersonWebViewController.h"
#import "XCZPublishOrdersViewCellBottomView.h"

@interface XCZPublishOrdersTableViewController () <UITableViewDataSource, UITableViewDelegate, XCZPublishNoOrdersViewDelegate, XCZPublishOrdersViewCellBottomViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, strong) XCZPublishNoOrdersView *noOrderView;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZPublishOrdersTableViewController

@synthesize rows = _rows;


- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    loginStatu ? [self goLogining] : [self requestTableViewNet];
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;

    if (rows.count) {
        [self.noOrderView removeFromSuperview];
        self.noOrderView = nil;
        self.currentPage++;
        [self updateTableView];
    } else { // 加载另外View
        [self.noOrderView removeFromSuperview];
        self.noOrderView = nil;
        XCZPublishNoOrdersView *noOrderView = [[XCZPublishNoOrdersView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        noOrderView.delegate = self;
        noOrderView.backgroundColor = [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1.0];
        [self.view addSubview:noOrderView];
//        self.self.navigationItem.rightBarButtonItem.
        self.noOrderView = noOrderView;
    }
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"订单列表";
    self.currentPage = 1;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    [self requestLoginDetection];
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

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)loadingMore
{
    [self requestTableViewNet];
}

#pragma mark - 网络请求部分
- (void)requestLoginDetection
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.loginStatu = [responseObject[@"statu"] intValue];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsOrderListAction.do"];
    NSDictionary *parameters = @{@"type": @"2", @"page":[NSString stringWithFormat:@"%d", self.currentPage], @"size": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableArray *rows = [[responseObject objectForKey:@"data"] mutableCopy];
        NSMutableArray *newRows = [NSMutableArray array];
        for (NSDictionary *row in rows) {
            NSMutableDictionary *order = [NSMutableDictionary dictionary];
            NSMutableArray *orderValue = [NSMutableArray array];
            NSMutableDictionary *dict = [[row[@"order"] firstObject] mutableCopy];
            NSString *isHasEntre = (((NSArray *)row[@"order_goods"]).count > 1) ? @"2" : @"1"; // 2为包含多款不同产品一个单 1为只有一款产品
            [dict setValue:dict[@"order_amount"] forKey:@"amounts"];
            [dict setValue:dict[@"num"] forKey:@"goods_num"];
            [dict setValue:isHasEntre forKey:@"isHasEntre"];
            if ([isHasEntre isEqualToString:@"1"]) {
                [dict setValue:@"2" forKey:@"status"];
            } else {
                [dict setValue:@"1" forKey:@"status"];
            }
            
            [orderValue addObject:dict];
            [order addEntriesFromDictionary:@{@"order": orderValue}];
            [order addEntriesFromDictionary:@{@"order_goods": row[@"order_goods"]}];
            [newRows addObject:order];
        }
        if (self.currentPage == 1) {
            self.rows = [NSMutableArray arrayWithArray:newRows];
        } else {
            self.rows = [[self.rows arrayByAddingObjectsFromArray:newRows] mutableCopy];
        }
        [self endHeaderRefresh];
        [self endFooterRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     NSArray *order = [self.rows[section] objectForKey:@"order"];
     int status = [[[order firstObject] objectForKey:@"status"] intValue];
    if (status == 1) {
        return ((NSArray *)[self.rows[section] objectForKey:@"order"]).count;
    } else {
        return ((NSArray *)[self.rows[section] objectForKey:@"order_goods"]).count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
     return 92;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZPublishOrdersTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    NSArray *order = [self.rows[indexPath.section] objectForKey:@"order"];
    int status = [[[order firstObject] objectForKey:@"status"] intValue];
    if (status == 1) {
        cell.order_good = [self.rows[indexPath.section] objectForKey:@"order"][indexPath.row];
    } else {
        cell.order_good = [self.rows[indexPath.section] objectForKey:@"order_goods"][indexPath.row];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 34)];
    headerView.backgroundColor = [UIColor whiteColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, tableView.bounds.size.width - 2 * 16, 34)];
    titleLabel.font = [UIFont systemFontOfSize:12];
    titleLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    NSDictionary *dict = [[self.rows[section] objectForKey:@"order"] firstObject];
    titleLabel.text = [NSString stringWithFormat:@"订单编号: %@", dict[@"order_id"]];
    [headerView addSubview:titleLabel];
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSArray *order = [self.rows[section] objectForKey:@"order"];
    NSString *isHasEntre = [[order firstObject] objectForKey:@"isHasEntre"];
    CGFloat footerViewH = 15;
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, footerViewH)];
    if ([isHasEntre isEqualToString:@"2"]) {
        XCZPublishOrdersViewCellBottomView *cellBottomView = [[XCZPublishOrdersViewCellBottomView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
        cellBottomView.delegate = self;
        cellBottomView.section = section;
        NSArray *order = [self.rows[section] objectForKey:@"order"];
        int status = [[[order firstObject] objectForKey:@"status"] intValue];
        if (status == 1) {
            cellBottomView.showTitle = @"查看全部";
            cellBottomView.image = [UIImage imageNamed:@""];
        } else {
            cellBottomView.showTitle = @"收起订单";
            cellBottomView.image = [UIImage imageNamed:@""];
        }
        [footerView addSubview:cellBottomView];
    }
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSArray *order = [self.rows[section] objectForKey:@"order"];
    NSString *isHasEntre = [[order firstObject] objectForKey:@"isHasEntre"];
    if ([isHasEntre isEqualToString:@"2"]) {
        return 34 + 15;
    } else {
        return 15;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZPublishOrderViewController *orderVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishOrderViewController"];
    int status = [[[[self.rows[indexPath.section] objectForKey:@"order"] firstObject] objectForKey:@"status"] intValue];
    if (status == 1) { // 整单
        orderVC.status = status;
        orderVC.order_good = [[self.rows[indexPath.section] objectForKey:@"order"] firstObject];
    } else { // 非整单
        orderVC.status = status;
        orderVC.order_good = [self.rows[indexPath.section] objectForKey:@"order_goods"][indexPath.row];
    }
    [self.navigationController pushViewController:orderVC animated:YES];
}

/**
 *  右边完成按钮被点击
 */
- (void)rightBarButtonItemDidClick
{
    if (self.noOrderView) {
        [MBProgressHUD ZHMShowError:@"您还没有订单呢..."];
        return;
    }
    XCZPublishOrderViewController *orderTopicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishOrderViewController"];
    [self.navigationController pushViewController:orderTopicVC animated:YES];
}

#pragma mark - XCZPublishNoOrdersViewDelegate
- (void)publishNoOrdersView:(XCZPublishNoOrdersView *)publishNoOrdersView goBtnDidClick:(UIButton *)goBtn
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - XCZPublishOrdersViewCellBottomViewDelegate
- (void)cellBottomViewDidClick:(XCZPublishOrdersViewCellBottomView *)cellBottomView
{
    NSMutableArray *newRows = [NSMutableArray array];
    for (int i = 0; i<self.rows.count; i++) {
        NSDictionary *row = self.rows[i];
        NSMutableDictionary *order = [NSMutableDictionary dictionary];
        NSMutableArray *orderValue = [NSMutableArray array];
        NSMutableDictionary *dict = [[row[@"order"] firstObject] mutableCopy];
        if (i == cellBottomView.section) {
            if ([dict[@"status"] intValue] == 1) {
                [dict setValue:@"2" forKey:@"status"];
            } else {
                [dict setValue:@"1" forKey:@"status"];
            }
        }
        [orderValue addObject:dict];
        [order addEntriesFromDictionary:@{@"order": orderValue}];
        [order addEntriesFromDictionary:@{@"order_goods": row[@"order_goods"]}];
        [newRows addObject:order];
    }
    self.rows = newRows;
    [self.tableView reloadData];
}

#pragma mark - 去登录等方法
- (void)goLogining
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/bbs/car-club/index.html"];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [XCZConfig baseURL], @"/Login/login/login.html?url=", overUrlStr]];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    XCZPersonWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonWebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
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
