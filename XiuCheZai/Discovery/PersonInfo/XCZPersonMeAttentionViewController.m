//
//  XCZMeAttentionViewController.m
//  XiuCheZai
//
//  Created by zhenghaimin on 2016/9/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonMeAttentionViewController.h"
#import "XCZConfig.h"
#import "XCZNewsUserListViewCell.h"
#import "XCZPersonMeAttentionViewCell.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZPersonMeAttentionViewController () <UITableViewDataSource, UITableViewDelegate, XCZPersonMeAttentionViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@property(nonatomic, strong)NSArray *zeroArray; // 伪造的共同关注数据
@property (nonatomic, strong) NSString *loginUser_id;


@end

@implementation XCZPersonMeAttentionViewController

@synthesize rows = _rows;

- (void)setLoginUser_id:(NSString *)loginUser_id
{
    _loginUser_id = loginUser_id;
    [self requestTableViewNet];
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;

    [self updateTableView];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"TA关注的";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"一键关注" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonItemDidClick)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
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
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)loadData {
    [self refreshData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)loadDataNeedsRefresh {
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
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSString *bbs_user_id;
    if (!self.bbs_user_id) {
        if (self.loginUser_id) {
            bbs_user_id = self.loginUser_id;
        } else {
            [self requestUserIdNet];
            return;
        }
    } else {
        bbs_user_id = self.bbs_user_id;
    }
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 3],
                                 @"bbs_user_id": self.bbs_user_id,
                               };
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rows = [responseObject objectForKey:@"data"];
        self.rows = [NSMutableArray arrayWithArray:[self organizationRows:rows]];
        [self endHeaderRefresh];
        [self endFooterRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        NSLog(@"error:%@", error);
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
        //        NSLog(@"responseObject:%@", responseObject);
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"成功"]) {
            NSString *show = (attion == 1) ? @"添加关注成功": @"取消关注成功";
            [MBProgressHUD ZHMShowSuccess:show];
            [self refreshData];
        } else {
            [MBProgressHUD ZHMShowSuccess:@"失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        [self endHeaderRefresh];
    }];
}

/**
 *  获取当前登录用户id
 */
- (void)requestUserIdNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/GetUID.do"];
    [self.manager POST:URLString parameters:nil progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"error"] intValue] == 201) {
            if ([responseObject[@"data"] isKindOfClass:[NSDictionary class]]) {
                NSString *user_id = ((NSDictionary *)responseObject[@"data"])[@"user_id"];
                self.loginUser_id = user_id;
            }
        } else {
            [MBProgressHUD ZHMShowError:@"您还未登录呢!"];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSDictionary *dict = self.rows[section];
    NSArray *attentions = [dict objectForKey:@"attentions"];
    return attentions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // CellA.height = 134
    // CellB.height = 92
    return 58;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZPersonMeAttentionViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    NSDictionary *dict = self.rows[indexPath.section];
    NSArray *attentions = dict[@"attentions"];
    if (!indexPath.section) {
        cell.isNoShowGuanzhu = YES; // YES为不显示关注按钮
    } else {
        cell.isNoShowGuanzhu = NO; // NO为显示关注按钮
    }
    cell.row = attentions[indexPath.row];
    cell.delegate = self;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = self.rows[section];
    NSArray *attentions = dict[@"attentions"];
    if (!attentions.count) {
        return @"";
    } else {
        NSDictionary *dict = self.rows[section];
        return dict[@"title"];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSDictionary *dict = self.rows[section];
    NSArray *attentions = dict[@"attentions"];
    if (!attentions.count) {
        return 0.01;
    } else {
        return 30;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

#pragma mark - XCZPersonAttentionMeViewCellDelegate
- (void)personMeAttentionViewCell:(XCZPersonMeAttentionViewCell *)personMeAttentionViewCell siteCircleLabelDidClick:(int)clazz
{
    if (!clazz) {
        [self requestAttionServlet:1 andUser_id:personMeAttentionViewCell.row[@"user_id"]]; // 去关注
    } else {
        [self requestAttionServlet:0 andUser_id:personMeAttentionViewCell.row[@"user_id"]]; // 去取消关注
    }
}


#pragma mark - 监听按钮被点击
- (void)rightBarButtonItemDidClick
{
//    NSLog(@"rows:%@", self.rows);
    NSArray *rows = [[self.rows lastObject] objectForKey:@"attentions"];
    NSMutableString *user_id;
    NSMutableArray *clazzs = [NSMutableArray array]; // 未关注的cell
    for (NSDictionary *row in rows) {
        if (![row[@"clazz"] intValue]) {
            [clazzs addObject:row[@"clazz"]];
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

#pragma mark - 私有方法
/**
 *  处理数组并倒序
 */
- (NSArray *)organizationRows:(NSArray *)rowY
{
    
    NSMutableArray *rows = [NSMutableArray array];
    for (NSDictionary *dataDict in rowY) {
        if ([dataDict[@"taskId"] intValue] == 4599) { // TA关注的
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSDictionary *attentionsDict = @{@"attentions": dataDict[@"rows"]};
            NSDictionary *titleDict = @{@"title": @"TA关注的"};
            [dict addEntriesFromDictionary:attentionsDict];
            [dict addEntriesFromDictionary:titleDict];
            [rows addObject:dict];
        }
        if ([dataDict[@"taskId"] intValue] == 4600) { // 共同关注的
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            NSDictionary *attentionsDict = @{@"attentions": dataDict[@"rows"]};
            NSDictionary *titleDict = @{@"title": @"共同关注的"};
            [dict addEntriesFromDictionary:attentionsDict];
            [dict addEntriesFromDictionary:titleDict];
            [rows addObject:dict];
        }
    }
    NSArray *rowchuans = [[rows reverseObjectEnumerator] allObjects];
//    NSLog(@"处理前的假数据:%@", rowchuans);
    
    return rowchuans;
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
//        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
//        if (bottomY > 75) {
//            [self morePullUpRefreshControl:scrollView];
//            [self stopFooterScroll:scrollView];
//            [self startFooterRefresh:scrollView];
//        }
    }
}


@end
