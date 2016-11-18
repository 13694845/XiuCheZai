//
//  XCZCircleViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/22.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleViewController.h"
#import "XCZCircleTableViewCell.h"
#import "XCZCircleDetailViewController.h"
#import "XCZPersonInfoViewController.h"
#import "XCZConfig.h"
#import "XCZCircleTableViewWenZiCell.h"
#import "XCZCircleDetailWriteView.h"
#import "XCZCircleTableViewLeafletsImageCell.h"
#import "UIImageView+WebCache.h"

@interface XCZCircleViewController () <UITableViewDataSource, UITableViewDelegate, XCZCircleTableViewCellDelegate, XCZCircleTableViewWenZiCellDelegate, XCZCircleTableViewLeafletsImageCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) CGFloat cellWZHeight;
@property (assign, nonatomic) CGFloat cellBHeight;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@property (nonatomic, strong) NSArray *oneArray;

@end

// 点

@implementation XCZCircleViewController

@synthesize rows = _rows;

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;

    self.currentPage++;
    [self endHeaderRefresh];
    [self endFooterRefresh];
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
    
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellMZHeightNot:) name:@"XCZCircleTableViewWenZiCellWZHeightToVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellBHeightNot:) name:@"XCZCircleTableViewLeafletsImageCellBHeightToVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"XCZCircleDetailViewControllerHasDelectedToXCZCircleViewControllerNot" object:nil]; // 详情页帖子被删除的通知

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)loadingMore
{
    [self requestTableViewNet];
}

#pragma mark - 通知方法
- (void)cellMZHeightNot:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    self.cellWZHeight = [dict[@"cellWZHeight"] floatValue];
}

- (void)cellBHeightNot:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    self.cellBHeight = [dict[@"cellBHeight"] floatValue];
}

#pragma mark - 网络请求部分
- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/QueryPostListAction.do"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = [NSString stringWithFormat:@"%d", 5];
    params[@"page"] = [NSString stringWithFormat:@"%d", self.currentPage];
    params[@"pagesize"] = [NSString stringWithFormat:@"%d", 20];
    
    [self.manager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
       NSArray *rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        if (self.currentPage == 1) {
            self.rows = [NSMutableArray arrayWithArray:rows];
//            NSLog(@"rowsrows:%@", self.rows);
        } else {
            self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }
        [self endHeaderRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self endHeaderRefresh];
    }];
}

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *row = self.rows[indexPath.row];
    NSString *post_clazz = row[@"post_clazz"];
    return [self computeHeight:post_clazz andRow:row];;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary *row = self.rows[indexPath.row];
    NSString *post_clazz = row[@"post_clazz"];
    NSString *identifier;
    identifier = [self identifier:post_clazz andRow:row];
    
    if ([identifier isEqualToString:@"CellWZ"]) {
        XCZCircleTableViewWenZiCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
          cell = [[XCZCircleTableViewWenZiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selfW = self.tableView.bounds.size.width;
        cell.row = row;
        cell.delegate = self;
        return cell;
    } else  if ([identifier isEqualToString:@"CellB"]) {
        XCZCircleTableViewLeafletsImageCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[XCZCircleTableViewLeafletsImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.selfW = self.tableView.bounds.size.width;
        cell.row = row;
        cell.delegate = self;
        return cell;
    } else {
        XCZCircleTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        cell.row = row;
        cell.delegate = self;
        return cell;
    }
}

#pragma mark - CellDelegate
- (void)circleTableViewCell:(XCZCircleTableViewCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)data
{
    [self jumpToXCZPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewCell:(XCZCircleTableViewCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZCircleDetailViewController:row[@"post_id"] andReuseIdentifier:circleTableViewCell.reuseIdentifier andUserId:row[@"user_id"]];
}

- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row
{
      [self jumpToXCZCircleDetailViewController:row[@"post_id"] andReuseIdentifier:circleTableViewCell.reuseIdentifier andUserId:row[@"user_id"]];
}

- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZCircleDetailViewController:row[@"post_id"] andReuseIdentifier:circleTableViewCell.reuseIdentifier andUserId:row[@"user_id"]];
}

#pragma mark - 跳转控制器
/**
 *  跳到个人信息
 */
- (void)jumpToXCZPersonInfoViewController:(NSString *)bbs_user_id
{
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
}

/**
 *  跳到话题详情
 */
- (void)jumpToXCZCircleDetailViewController:(NSString *)post_id andReuseIdentifier:(NSString *)reuseIdentifier andUserId:(NSString *)user_id
{
    XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    circleDetailVC.reuseIdentifier = reuseIdentifier;
    circleDetailVC.post_id = post_id;
    circleDetailVC.user_id = user_id;
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 私有方法
- (CGFloat)computeHeight:(NSString *)post_clazz andRow:(NSDictionary *)row
{
    CGFloat height = 0.0;
    if ([post_clazz intValue] == 1) {
        NSString *topic = [self stringByReplacing:row[@"topic"]];
        NSString *summary = [self stringByReplacing:row[@"summary"]];
        CGSize contentTitleLabelSize = [topic boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size;
        height += topic && [topic length] ? 56 + contentTitleLabelSize.height + 16 : 56 + contentTitleLabelSize.height - 8;
        CGSize contentLabelSize = [summary boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 120) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size;
        height += contentLabelSize.height + 8 + 28;
    } else if ([post_clazz intValue] == 2) { // 假设投票贴子和文字一样
        height = 174;
    } else if ([post_clazz intValue] == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
            if (imageArray.count == 1) {
                CGFloat oneImageCellHeight;
                CGFloat topicH = 0.0;
                NSString *topic = [self stringByReplacing:row[@"topic"]];
                NSString *summary = [self stringByReplacing:row[@"summary"]];
                if (topic && [topic length]) {
                    topicH = [topic boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size.height;
                    topicH = topicH + 8;
                }else {
                    topicH = 0.0;
                }
                
                CGFloat summaryH = [summary boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 120) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size.height;
                oneImageCellHeight = 56 + topicH + summaryH + 16;
            height = oneImageCellHeight + XCZCircleTableViewLeafletsImageCellImageHeight + 4 + 17 + 12;
        } else if (imageArray.count <= 3) {
            height = 214;
        } else if (imageArray.count <= 6) {
            height = 299;
        } else {
            height = 382;
        }
    } else if ([post_clazz intValue] == 4) {
        NSMutableArray *imageArray = [NSMutableArray array];
        if (!((NSString *)row[@"share_image"]).length) {
            height = 216;
        } else {
            imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
            if (imageArray.count == 0) {
                height = 216;
            } else if (imageArray.count <= 3) {
                height = 297;
            } else if (imageArray.count <= 6) {
                height = 380;
            } else {
                height = 463;
            }
        }
    }
    return height;
}

- (NSString *)identifier:(NSString *)post_clazz andRow:(NSDictionary *)row
{
    NSString *identifier;
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
        NSMutableArray *imageArray = [NSMutableArray array];
        if (!((NSString *)row[@"share_image"]).length) {
            identifier = @"CellC1";
        } else {
            imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
            if (imageArray.count == 0) {
                identifier = @"CellC1";
            } else if (imageArray.count <= 3) {
                identifier = @"CellC";
            } else if (imageArray.count <= 6) {
                identifier = @"CellC2";
            } else {
                identifier = @"CellC3";
            }
        }
    }
    return identifier;
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

- (NSString *)stringByReplacing:(NSString *)string
{
    NSString *summaryShow = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    summaryShow = [summaryShow stringByReplacingOccurrencesOfString:@" " withString:@""];
    return summaryShow;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
