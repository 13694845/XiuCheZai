//
//  XCZPersonAttentionClubViewController.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonAttentionClubViewController.h"
#import "XCZConfig.h"
#import "XCZPersonAttentionClubViewCell.h"
#import "XCZPersonWebViewController.h"
#import "XCZClubCircleViewController.h"

@interface XCZPersonAttentionClubViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@property (strong,nonatomic) NSArray *oneRows;

@end

@implementation XCZPersonAttentionClubViewController

@synthesize rows = _rows;

- (NSArray *)oneRows
{
    if (!_oneRows) {
        _oneRows = @[
                     @{
                         @"area_id" : @"331002",
                         @"avatar" : @"group2/M00/01/BA/wKgCcFTYQbOAELXIAA1rIuRd3Es121.jpg",
                         @"brand_name" : @"5",
                         @"city_id" : @"331000",
                         @"forum_name" : @"zbk啊摔到",
                         @"nick" : @"时代风格",
                         @"province_id" : @"330000",
                         @"user_id" : @"3190",
                         },
                     
                     @{
                         @"area_id" : @"331002",
                         @"avatar" : @"group2/M00/01/BA/wKgCcFTYQbOAELXIAA1rIuRd3Es121.jpg",
                         @"brand_name" : @"5",
                         @"city_id" : @"331001",
                         @"forum_name" : @"是否",
                         @"nick" : @"时代风格",
                         @"province_id" : @"330000",
                         @"user_id" : @"3190",
                         },
                     
                     @{
                         @"area_id" : @"331002",
                         @"avatar" : @"group2/M00/01/BA/wKgCcFTYQbOAELXIAA1rIuRd3Es121.jpg",
                         @"brand_name" : @"5",
                         @"city_id" : @"331002",
                         @"forum_name" : @"舒服的更",
                         @"nick" : @"时代风格",
                         @"province_id" : @"330000",
                         @"user_id" : @"3190",
                         },
                     
                     @{
                         @"area_id" : @"331002",
                         @"avatar" : @"group2/M00/01/BA/wKgCcFTYQbOAELXIAA1rIuRd3Es121.jpg",
                         @"brand_name" : @"5",
                         @"city_id" : @"331003",
                         @"forum_name" : @"z的撒风",
                         @"nick" : @"时代风格",
                         @"province_id" : @"330000",
                         @"user_id" : @"3190",
                         },
                     
                     @{
                         @"area_id" : @"331002",
                         @"avatar" : @"group2/M00/01/BA/wKgCcFTYQbOAELXIAA1rIuRd3Es121.jpg",
                         @"brand_name" : @"5",
                         @"city_id" : @"331004",
                         @"forum_name" : @"saiugd",
                         @"nick" : @"时代风格",
                         @"province_id" : @"330000",
                         @"user_id" : @"3190",
                         },
                     ];
    }
    return _oneRows;
}


- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
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
    
    self.title = @"关注的车友会";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键关注" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemDidClick)];
    
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self loadData];
    // Do any additional setup after loading the view.
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

- (void)loadingMore
{
    [self requestTableViewNet];
}

#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
    //         // 测试用
    //        if (self.currentPage == 1) {
    //    //        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                self.rows = [NSMutableArray arrayWithArray:self.oneRows];
    //    //        });
    //
    //        } else {
    //            self.oneRows = nil;
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                self.rows = [[self.rows arrayByAddingObjectsFromArray:self.oneRows] mutableCopy];
    //            });
    //        }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 5],
                                 @"bbs_user_id": self.bbs_user_id,
                                 @"page":[NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": @"10"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"推荐的车友会:%@", responseObject);
        NSArray *rows = [responseObject objectForKey:@"data"];
        if (self.currentPage == 1) {
            self.rows = [NSMutableArray arrayWithArray:rows];
        } else {
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
//                 NSLog(@"rows:%@", self.rows);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
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
    // CellA.height = 134
    // CellB.height = 92
    return 56;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZPersonAttentionClubViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.row = self.rows[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    XCZClubCircleViewController *clubCircleViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleViewController"];
    // newsId
    clubCircleViewController.hasJoin = YES;
    NSDictionary *row = self.rows[indexPath.row];
    clubCircleViewController.forum_id = row[@"forum_id"];
    [self.navigationController pushViewController:clubCircleViewController animated:YES];
}

#pragma mark - 监听按钮被点击
- (void)rightBarButtonItemDidClick
{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)loading
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/bbs/userInfo/index.html?uid=%@", @""];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [XCZConfig baseURL], @"/Login/login/login.html?url=", overUrlStr]];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    XCZPersonWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}


#pragma mark - 上下拉刷新处理
- (void)loadPullDownRefreshControl:(UIScrollView *)scrollView
{
    [self removeIndicatorHeaderView];
    [self removeIndicatorFooterView];
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
    //    [self removeIndicatorHeaderView];
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
    [scrollView setContentOffset:offset animated:NO];
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
    
    //    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
    //        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
    //        if (bottomY > 75) {
    ////            NSLog(@"bottomY:%f, scrollViewY:%f", bottomY, scrollView.contentOffset.y);
    //            [self morePullUpRefreshControl:scrollView];
    //            [self stopFooterScroll:scrollView];
    //            [self startFooterRefresh:scrollView];
    //        }
    //    }
}


@end
