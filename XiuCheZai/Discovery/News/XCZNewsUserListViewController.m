//
//  XCZNewsUserListViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/8.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsUserListViewController.h"
#import "XCZConfig.h"
#import "XCZNewsUserListViewCell.h"
#import "XCZPersonInfoViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZPersonWebViewController.h"

@interface XCZNewsUserListViewController () <UITableViewDataSource, UITableViewDelegate, XCZNewsUserListViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) int goType; // 1:加关注按钮点击时
@property (assign, nonatomic) int clazz; // 0:去关注  其他:去取消关注
@property (nonatomic, copy) NSString *cellUser_id;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;
@property (assign, nonatomic) BOOL hasNoFooterData;

@end

@implementation XCZNewsUserListViewController

@synthesize rows = _rows;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    if (self.goType == 1) {
        loginStatu ? [self goLogining] : (_clazz ? [self requestAttionServlet:0 andUser_id:_cellUser_id] : [self requestAttionServlet:1 andUser_id:_cellUser_id]);
    }
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    if (_rows.count) {
        self.currentPage++;
        [self updateTableView];
    }
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键关注" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemDidClick)];
    
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.currentPage = 1;
    
     self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [self loadData];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/InformationAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 2],
                                 @"artid": self.artid,
                                 @"page":[NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": [NSString stringWithFormat:@"%d", 10]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rows = [responseObject objectForKey:@"data"];
        if (self.currentPage == 1) {
            self.hasNoFooterData = NO;
            [self endHeaderRefresh];
            self.rows = [NSMutableArray arrayWithArray:rows];
        } else {
            
            self.hasNoFooterData = rows.count ? NO : YES;
//            NSLog(@"来到了这里的回复:%@", rows);
            [self endFooterRefresh];
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

/**
 *  是否关注接口
 */
- (void)requestAttionServlet:(int)attion andUser_id:(NSString *)user_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/AttionServlet.do"];
    NSDictionary *parameters = @{@"attion":[NSString stringWithFormat:@"%d", attion], @"receiver_id": user_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD ZHMHideHUD];
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"成功"]) {
            NSString *show = (attion == 1) ? @"添加关注成功": @"取消关注成功";
            [MBProgressHUD ZHMShowSuccess:show];
            [self refreshData];
        } else {
            [MBProgressHUD ZHMShowSuccess:@"失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD ZHMHideHUD];
        [MBProgressHUD ZHMShowSuccess:@"失败"];
    }];
}

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 59;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZNewsUserListViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.row = self.rows[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    NSString *bbs_user_id = [self.rows[indexPath.row] objectForKey:@"user_id"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
}

#pragma mark - XCZNewsUserListViewCellDelegate
- (void)newsUserListViewCell:(XCZNewsUserListViewCell *)newsUserListViewCell siteCircleLabelDidClick:(int)clazz
{
    self.goType = 1;
    self.clazz = clazz;
    self.cellUser_id = newsUserListViewCell.row[@"user_id"];
    [self requestLoginDetection]; // 监测登录
}

#pragma mark - 监听按钮被点击
- (void)rightBarButtonItemDidClick
{
    NSMutableString *user_id;
    NSMutableArray *clazzs = [NSMutableArray array]; // 未关注的cell
    for (NSDictionary *row in self.rows) {
        if (!row[@"is_guan"]) {
            [clazzs addObject:@"is_guanzhu"];
            if (user_id) {
                user_id = [NSMutableString stringWithFormat:@"%@,%@",  user_id, row[@"user_id"]];
            } else {
                user_id = [NSMutableString stringWithFormat:@"%@", row[@"user_id"]];
            }
        }
    }
    if (clazzs.count) {
        [self requestAttionServlet:1 andUser_id:user_id];
    }
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
