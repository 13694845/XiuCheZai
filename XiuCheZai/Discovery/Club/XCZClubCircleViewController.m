//
//  XCZClubCircleViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/9.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleViewController.h"
#import "XCZClubCircleViewCell.h"
#import "XCZClubCircleUnsubscribeViewController.h"
#import "XCZCircleDetailViewController.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZClubCircleHeaderView.h"
#import "DiscoveryConfig.h"
#import "XCZPersonInfoViewController.h"
#import "XCZClubCircleViewMemberCell.h"
#import "XCZClubCircleViewMemberCellTwoView.h"
#import "XCZClubCircleViewMemberCellUserView.h"
#import "XCZCircleTableViewWenZiCell.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZCircleTableViewLeafletsImageCell.h"
#import "XCZClubCircleViewMemberCellUserAddView.h"
#import "XCZClubCircleBrandsViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZMessageViewController.h"
#import "XCZPublishWritingViewController.h"
#import "XCZPublishPhoneViewController.h"
#import "XCZPublishOrdersTableViewController.h"

typedef NS_OPTIONS(NSUInteger, ClubCircleLoginOverJumpType) {
    ClubCircleLoginOverAddBtn          = 1 << 1,
    ClubCircleLoginOverJumpTypeCamera          = 1 << 1,
    ClubCircleLoginOverJumpTypePhotoLibrary    = 1 << 2
};

typedef NS_OPTIONS(NSUInteger, DiscoveryLoginOverJumpType) {
    DiscoveryLoginOverJumpTypePosting          = 1 << 0,
    DiscoveryLoginOverJumpTypeDryingSingle     = 1 << 1
};

@interface XCZClubCircleViewController ()<UITableViewDataSource, UITableViewDelegate, XCZClubCircleViewCellDelegate, XCZClubCircleHeaderViewDelegate, XCZClubCircleViewMemberCellDelegate, XCZCircleTableViewWenZiCellDelegate, XCZCircleTableViewLeafletsImageCellDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) XCZClubCircleHeaderView *headerView;
@property (assign, nonatomic) int best;
@property (strong, nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) NSMutableArray *huizhangRows;

@property (strong, nonatomic) NSMutableArray *banners;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) CGFloat cellWZHeight;
@property (assign, nonatomic) CGFloat cellBHeight;
@property (nonatomic, weak) UIButton *selectedBtn; // 之前点击的按钮
@property (strong, nonatomic) NSMutableArray *topRows; // 置顶
@property (nonatomic, assign) CGFloat cellTwoViewHeight;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@property (nonatomic, weak) UILabel *noCellLabel;
@property (nonatomic, weak) UIButton *addBtn;
@property (assign, nonatomic) ClubCircleLoginOverJumpType jumpType;
@property (assign, nonatomic) int addType; // 2.为添加按钮 3.为删除按钮

@property (nonatomic, strong) UIImage *publishImage;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZClubCircleViewController

@synthesize rows = _rows;
@synthesize banners = _banners;


- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;

    if (self.jumpType == ClubCircleLoginOverAddBtn) {
                loginStatu ? [self goLogining] : [self requestFormumNet:self.addBtn andType:self.addType];
    } else if (self.jumpType == DiscoveryLoginOverJumpTypePosting) {
        loginStatu ? [self goLogining] : [self jumpToPublishPhoneViewController]; // 跳转到发帖控制器
    } else if (self.jumpType == DiscoveryLoginOverJumpTypeDryingSingle) {
        loginStatu ? [self goLogining] : [self jumpToPublishOrdersTableViewController]; // 跳到晒单
    }
}

- (void)setPublishImage:(UIImage *)publishImage
{
    _publishImage = publishImage;
    [self jumpToPublishPhoneViewController]; // 跳转到XCZPublishPhoneViewController
}

- (NSMutableArray *)topRows
{
    if (!_topRows) {
        _topRows = [NSMutableArray array];
    }
    return _topRows;
}

- (void)setBanners:(NSMutableArray *)banners {
    _banners = banners;
    [self updateBannerView];
}

- (NSMutableArray *)banners {
    return _banners;
}

- (void)setRows:(NSMutableArray *)rows {
    _rows = rows;
    
    [self endHeaderRefresh];
    [self endFooterRefresh];
    if (rows.count) {
        [self.noCellLabel removeFromSuperview];
        self.noCellLabel = nil;
        [self updateTableView];
        [self endHeaderRefresh];
        [self endFooterRefresh];
        
    } else {
        [self.noCellLabel removeFromSuperview];
        self.noCellLabel = nil;
        [self updateTableView];
        UILabel *noCellLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 110, self.view.bounds.size.width, 50)];
        noCellLabel.text = @"报告! 这里没有找到帖子的足迹 ~ ~ ~ ~";
        noCellLabel.textAlignment = NSTextAlignmentCenter;
        noCellLabel.font = [UIFont systemFontOfSize:12];
        [self.tableView addSubview:noCellLabel];
        self.noCellLabel = noCellLabel;
    }
}

- (void)setHuizhangRows:(NSMutableArray *)huizhangRows
{
    _huizhangRows = huizhangRows;
    [self.tableView reloadData];
}

- (NSMutableArray *)rows {
    if (!_rows) _rows = [NSMutableArray array];
    return _rows;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self assistedSetup]; // 辅助设置
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)assistedSetup
{
    self.tableView.alwaysBounceVertical = YES;
    self.title = @"";
    self.tableView.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    XCZClubCircleHeaderView *headerView = [[XCZClubCircleHeaderView alloc] init];
    headerView.frame =  CGRectMake(0, 0, self.tableView.bounds.size.width, 123);
    headerView.delegate = self;
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    [self loadHeadData];
    
    UIBarButtonItem *navMassageBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_myfinding_mine"] style:UIBarButtonItemStylePlain target:self action:@selector(navMassageBtnItemDidClick)];
    UIBarButtonItem *navAddBtnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_add"] style:UIBarButtonItemStylePlain target:self action:@selector(navAddBtnItemDidClick)];
    [self.navigationItem setRightBarButtonItems:@[navMassageBtnItem, navAddBtnItem]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshLoadHeadData:) name:@"XCZClubCircleUnsubscribeViewControllerToXCZClubCircleViewControllerRefreshNot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setupHeight:) name:@"clubCircleViewMemberCellHeightToVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellMZHeightNot:) name:@"XCZCircleTableViewWenZiCellWZHeightToVC" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellBHeightNot:) name:@"XCZCircleTableViewLeafletsImageCellBHeightToVC" object:nil];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshLoadHeadData:(NSNotification *)notification
{
   self.hasJoin = [[notification.userInfo objectForKey:@"hasJoin"] boolValue];
    [self loadHeadData];
}

- (void)loadHeadData
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"forum_id":self.forum_id, @"type": @"6"};
     [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//         NSLog(@"responseObject:%@", responseObject);
              self.banners = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
     } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)refreshOneData {
    self.currentPage = 1;
    [self refreshData];
}

- (void)loadingCellData {
    [self refreshData];
}

- (void)loadingMemberCellData {
    [self refreshMemberData];
}

- (void)refreshData {
    [self clearDataNeedsRefresh];
    [self loadDataNeedsRefresh];
}

- (void)refreshMemberData {
    [self clearDataNeedsRefresh];
    [self loadDataMemberNeedsRefresh];
}

- (void)clearDataNeedsRefresh {
    
}

- (void)loadDataNeedsRefresh {
    [self requestTableViewNet];
}

- (void)loadDataMemberNeedsRefresh
{
//    self.currentPage = 1;
    [self requestTableViewMemberNet];
}

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)updateBannerView {
    self.headerView.hasJoin = self.hasJoin;
    self.headerView.banner = [self.banners firstObject];
    self.title = [[self.banners firstObject] objectForKey:@"forum_name"];
}

- (void)loadingMore
{
    self.currentPage++;
    if (self.best == 0) {
        [self loadingCellData];
    } else if (self.best == 1) {
        [self loadingCellData];
    } else if (self.best == 2) {
        [self loadingMemberCellData];
    }
}

- (void)requestTableViewNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/QueryPostListAction.do"];
    NSDictionary *parameters = @{
                                 @"type": @"4",
                                 @"forum_id": self.forum_id,
                                 @"page": [NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": @"10",
                                 @"best": [NSString stringWithFormat:@"%d", self.best],
                                 };
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        NSMutableArray *rowMutables = [NSMutableArray array];
        if (self.currentPage == 1) {
            self.topRows = nil;
            for (NSMutableDictionary *dict in rows) {
                if ([[dict objectForKey:@"is_top"] intValue] == 1) {
//                    NSLog(@"dictdictdict:%@", dict);
                    [self.topRows addObject:dict];
                }
            }
            rowMutables = [NSMutableArray arrayWithArray:rows];
        } else {
            for (NSMutableDictionary *dict in rows) {
                if ([[dict objectForKey:@"is_top"] intValue] == 1) {
                    [self.topRows addObject:dict];
                }
            }
            rowMutables = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
        }

        if (self.best == 0) {
            // 将is_top的帖子加入置顶
            NSMutableArray *topRows = [NSMutableArray array];
            for (NSMutableDictionary *dict in rowMutables) {
                if ([[dict objectForKey:@"is_top"] intValue] == 1) {
                    [topRows addObject:dict];
                }
            }
            NSMutableArray *rowZJs = [NSMutableArray array];
//            [rowZJs addObjectsFromArray:self.topRows];
            [rowZJs addObjectsFromArray:rowMutables];
            self.rows = rowZJs;
        } else {
            self.rows = rowMutables;
        }
        
//        NSLog(@"rows2:%ld, currentPage:%d", self.rows.count, self.currentPage);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)requestTableViewMemberNet
{
        NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
        NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0], @"forum_id": self.forum_id, @"page":[NSString stringWithFormat:@"%d", self.currentPage], @"pagesize":[NSString stringWithFormat:@"%d", 10]};
        [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            NSArray *rowsArray = [NSArray array];
            NSArray *huizhangArray = [NSArray array];
    for (NSDictionary *dict in [responseObject objectForKey:@"data"]) {
        if ([dict[@"taskId"] integerValue] == 4582) { // 会长数据
            huizhangArray = dict[@"rows"];
            self.huizhangRows = [huizhangArray mutableCopy];
            [self endHeaderRefresh];
            [self endFooterRefresh];
        }
        
        if ([dict[@"taskId"] integerValue] == 4579) { // 全部成员数据
            rowsArray = dict[@"rows"];
            if (rowsArray.count) {
                if (self.currentPage == 1) {
                    self.rows = [rowsArray mutableCopy];
                } else {
                    self.rows = [[self.rows arrayByAddingObjectsFromArray:rowsArray] mutableCopy];
                }
            } else {
                [self endHeaderRefresh];
                [self endFooterRefresh];
            }
        }
    }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            NSLog(@"error:%@", error);
            [self endHeaderRefresh];
            [self endFooterRefresh];
        }];
}

- (void)requestFormumNet:(UIButton *)addBtn andType:(int)type
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", type], @"forum_id": self.forum_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"成功"]) {
            if (!self.hasJoin) {
                [MBProgressHUD ZHMShowSuccess:@"加入成功"];
                self.hasJoin = YES;
            } else {
                [MBProgressHUD ZHMShowSuccess:@"退出此板块成功"];
                self.hasJoin = NO;
            }
            [self updateBannerView];
        } else {
            [MBProgressHUD ZHMShowSuccess:msg];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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

#pragma mark - tableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.best == 0 || self.best == 1) ? self.rows.count : (self.huizhangRows.count ? 2 : 1);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    CGFloat height;
    if (self.best == 0) { // 普通
        NSDictionary *row = [self.rows objectAtIndex:indexPath.row];
        NSString *post_clazz = [[self.rows objectAtIndex:indexPath.row] objectForKey:@"post_clazz"];
        height = (indexPath.row < self.topRows.count) ? 39 : [self computeHeight:post_clazz andRow:row andIndexPath:indexPath];
    } else if (self.best == 1) { // 精华
        NSDictionary *row = [self.rows objectAtIndex:indexPath.row];
        NSString *post_clazz = [[self.rows objectAtIndex:indexPath.row] objectForKey:@"post_clazz"];
        height = [self computeHeight:post_clazz andRow:row andIndexPath:indexPath];
    } else if (self.best == 2) { // 成员
        if (self.huizhangRows.count) {
            if (indexPath.row == 0) {
                height = 98;
            } else { // 暂时
                height = self.cellTwoViewHeight;
            }
        } else {
            height = self.cellTwoViewHeight;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *identifier;
    if (self.best == 0) { // 普通
        NSDictionary *row = self.rows[indexPath.row];
        NSString *post_clazz = row[@"post_clazz"];
        identifier = (indexPath.row < self.topRows.count) ? @"CellG" : [self identifier:post_clazz andRow:row];
        return [self creatClubCircleViewCell:identifier andRow:row andIndexPath:indexPath];
    } else if (self.best == 1) { // 精华
        NSDictionary *row = self.rows[indexPath.row];
        NSString *post_clazz = row[@"post_clazz"];
        identifier = [self identifier:post_clazz andRow:row];
        return [self creatClubCircleViewCell:identifier andRow:row andIndexPath:indexPath];
    } else { // 成员
        if (self.huizhangRows.count) {
            if (indexPath.row == 0) { // 会长
                identifier = @"CellE";
                return  [self creatClubCircleViewMemberCell:identifier andRow:self.huizhangRows[indexPath.row]];
            } else if (indexPath.row == 1) { // 全部成员
                identifier = @"CellF";
                return  [self creatClubCircleViewMemberCell:identifier andRows:[NSArray arrayWithArray:self.rows]];
            } else {
                UITableViewCell *cell;
                return cell;
            }
        } else {
            identifier = @"CellF"; // 暂时
            return  [self creatClubCircleViewMemberCell:identifier andRows:[NSArray arrayWithArray:self.rows]];
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XCZClubCircleViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell.reuseIdentifier isEqualToString:@"CellG"]) { // CellE CellF为成员中的Cell
        // 跳到话题详情
        XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
        NSString *post_clazz = self.rows[indexPath.row][@"post_clazz"];
        circleDetailVC.reuseIdentifier = [self identifier:post_clazz andRow:self.rows[indexPath.row]];
        circleDetailVC.post_id = cell.row[@"post_id"];
        [self.navigationController pushViewController:circleDetailVC animated:YES];
    }
}

#pragma mark - headerDelegate
- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView clubTwoViewSubBtnDidClick:(UIButton *)btn
{
    self.currentPage = 1;
    if (!btn.tag) {
        self.best = 0;
        [self loadingCellData];
    } else if (btn.tag == 1) {
        self.best = 1;
        [self loadingCellData];
    } else {
        self.best = 2;
        [self loadingMemberCellData];
    }
}

- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView clubOneViewDidClick:(UIView *)clubOneView
{
    XCZClubCircleUnsubscribeViewController *unsubscribeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleUnsubscribeViewController"];
    unsubscribeVC.hasJoin = self.hasJoin;
    unsubscribeVC.forum_id = clubCircleHeaderView.banner[@"forum_id"];
    [self.navigationController pushViewController:unsubscribeVC animated:YES];
}

- (void)clubCircleHeaderView:(XCZClubCircleHeaderView *)clubCircleHeaderView addBtnDidClick:(UIButton *)addBtn
{
    self.addBtn = addBtn;
    self.jumpType = ClubCircleLoginOverAddBtn;
    self.addType = self.hasJoin ? 3 : 2;
    [self requestLoginDetection]; // 监测登录
}

#pragma mark - CellDelegate
- (void)circleTableViewCell:(XCZClubCircleViewCell *)circleTableViewCell cellHeaderViewDidClick:(UIView *)cellHeaderView
{
    [self jumpToPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewCell:(XCZClubCircleViewCell *)circleTableViewCell cellContentViewDidClick:(UIView *)cellContentView
{
    // 跳到话题详情
    XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    circleDetailVC.reuseIdentifier = circleTableViewCell.reuseIdentifier;
    circleDetailVC.post_id = circleTableViewCell.row[@"post_id"];
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell cellOneViewDidClick:(UIView *)cellOneView
{
//    NSLog(@"点击了哈哈哈:%@", memberCell.hzRow);
    [self jumpToPersonInfoViewController:memberCell.hzRow[@"user_id"]];
}

- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView userViewDidClick:(XCZClubCircleViewMemberCellUserView *)userView
{
    [self jumpToPersonInfoViewController:userView.row[@"user_id"]];
}

- (void)clubCircleViewMemberCell:(XCZClubCircleViewMemberCell *)memberCell clubCircleViewMemberCellTwoView:(XCZClubCircleViewMemberCellTwoView *)memberCellTwoView addViewDidClick:(XCZClubCircleViewMemberCellUserAddView *)addView
{
    [self jumpToClubCircleBrandViewController];
}

- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewWenZiCell:(XCZCircleTableViewWenZiCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZCircleDetailViewController:row[@"post_id"] andReuseIdentifier:circleTableViewCell.reuseIdentifier];
}

- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellHeaderViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZPersonInfoViewController:circleTableViewCell.row[@"user_id"]];
}

- (void)circleTableViewLeafletsImageCell:(XCZCircleTableViewLeafletsImageCell *)circleTableViewCell cellContentViewDidClick:(NSDictionary *)row
{
    [self jumpToXCZCircleDetailViewController:row[@"post_id"] andReuseIdentifier:circleTableViewCell.reuseIdentifier];
}

#pragma mark - 按钮被点击
- (void)navMassageBtnItemDidClick
{
    XCZMessageViewController *messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageViewController"];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (void)navAddBtnItemDidClick
{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"发帖" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.jumpType = DiscoveryLoginOverJumpTypePosting;
        [self requestLoginDetection];
    }];
    UIAlertAction *twoAction = [UIAlertAction actionWithTitle:@"晒单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.jumpType = DiscoveryLoginOverJumpTypeDryingSingle;
        [self requestLoginDetection];
    }];
    
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [alertCtr addAction:twoAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - 通知处理
- (void)setupHeight:(NSNotification *)not
{
   NSDictionary *userInfo = not.userInfo;
   self.cellTwoViewHeight = [userInfo[@"cellTwoViewHeight"] floatValue];
}

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

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 跳转控制器
- (void)jumpToPersonInfoViewController:(NSString *)user_id
{
    XCZPersonInfoViewController *pInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    pInfoVC.bbs_user_id = user_id;
    [self.navigationController pushViewController:pInfoVC animated:YES];
}

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
- (void)jumpToXCZCircleDetailViewController:(NSString *)post_id andReuseIdentifier:(NSString *)reuseIdentifier
{
    XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    circleDetailVC.reuseIdentifier = reuseIdentifier;
    circleDetailVC.post_id = post_id;
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

- (void)jumpToClubCircleBrandViewController
{
    XCZClubCircleBrandsViewController *circleBrandsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleBrandsViewController"];
    [self presentViewController:circleBrandsVC animated:YES completion:^{
        
    }];
}

- (void)jumpToPublishPhoneViewController
{
    XCZPublishPhoneViewController *phoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishPhoneViewController"];
    phoneVC.image = self.publishImage;
    [self.navigationController pushViewController:phoneVC animated:YES];
}

- (void)jumpToPublishOrdersTableViewController
{
    XCZPublishOrdersTableViewController *orderTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishOrdersTableViewController"];
    [self.navigationController pushViewController:orderTableVC animated:YES];
}

#pragma mark - 拍照处理
- (void)photograph:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    imagePickController.delegate = self;
    imagePickController.sourceType = sourceType;
    //    imagePickController.showsCameraControls = NO;
    [self presentViewController:imagePickController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *oImage = info[@"UIImagePickerControllerOriginalImage"];
    self.publishImage = oImage;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 私有方法
- (CGFloat)computeHeight:(NSString *)post_clazz andRow:(NSDictionary *)row andIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if ([post_clazz intValue] == 1) {
        height = self.cellWZHeight;
    } else if ([post_clazz intValue] == 2) { // 假设投票贴子和文字一样
        height = 174;
    } else if ([post_clazz intValue] == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
        if (imageArray.count == 1) {
                CGFloat oneImageCellHeight;
                CGFloat topicH = 0.0;
                if (row[@"topic"] && ((NSString *)row[@"topic"]).length) {
                    topicH = [row[@"topic"] boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 50) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size.height;
                    topicH = topicH + 8;
                }else {
                    topicH = 0.0;
                }
                
                CGFloat summaryH = [row[@"summary"] boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 64 - 8, 120) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:18]} context:nil].size.height;
                oneImageCellHeight = 56 + topicH + summaryH + 16;
            
                UIImageView *imageView = [[UIImageView alloc] init];
            NSString *share_image = row[@"share_image"];
            if (![share_image containsString:@"http"]) {
                share_image = [NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], row[@"share_image"]];
            }
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:share_image] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    CGFloat imageViewW = 120;
                    CGFloat imageViewH = 0.0;
                    if (image.size.width < 120) {
                        imageViewW = image.size.width;
                        imageViewH = image.size.height;
                    } else {
                        imageViewH = imageViewW * (image.size.height / image.size.width);
                    }
                    self.cellBHeight = oneImageCellHeight + imageViewH + 8 + 17 + 12;
                }];
            if (!self.cellBHeight) {
                self.cellBHeight = oneImageCellHeight + 160 + 8 + 17 + 12;
            }
            height = self.cellBHeight;
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
    } else if ([post_clazz intValue] == 2) {
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
 *  创建XCZClubCircleViewCell
 */
- (UITableViewCell *)creatClubCircleViewCell:(NSString *)identifier andRow:(NSDictionary *)row andIndexPath:(NSIndexPath *)indexPath
{
    if ([identifier isEqualToString:@"CellWZ"]) {
        XCZCircleTableViewWenZiCell *wzCell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!wzCell) {
            wzCell = [[XCZCircleTableViewWenZiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        wzCell.selfW = self.tableView.bounds.size.width;
        wzCell.sourceType = 1;
        wzCell.row = row;
        wzCell.delegate = self;
        return wzCell;
    } else if ([identifier isEqualToString:@"CellB"]) {
        XCZCircleTableViewLeafletsImageCell *cellB = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cellB) {
            cellB = [[XCZCircleTableViewLeafletsImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cellB.selfW = self.tableView.bounds.size.width;
        cellB.sourceType = 1;
        cellB.row = row;
        cellB.delegate = self;
        return cellB;
    } else  {
        XCZClubCircleViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
        cell.row = row;
        cell.delegate = self;
        return cell;
    }
}

/**
 *  创建XCZClubCircleViewMemberCell
 */
- (UITableViewCell *)creatClubCircleViewMemberCell:(NSString *)identifier andRow:(NSDictionary *)row
{
    XCZClubCircleViewMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XCZClubCircleViewMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.cellW = self.tableView.bounds.size.width;
    cell.hzRow = row;
    cell.delegate = self;
    return cell;
}

/**
 *  创建XCZClubCircleViewMemberCell
 */
- (UITableViewCell *)creatClubCircleViewMemberCell:(NSString *)identifier andRows:(NSArray *)rows
{
    XCZClubCircleViewMemberCell *cell = [self.tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[XCZClubCircleViewMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.cellW = self.tableView.bounds.size.width;
    cell.rows = rows;
    cell.delegate = self;
    return cell;
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
    [self refreshOneData];
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















