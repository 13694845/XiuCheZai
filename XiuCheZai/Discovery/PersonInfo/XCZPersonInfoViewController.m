//
//  XCZPersonInfoViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/16.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoViewController.h"
#import "XCZPersonInfoViewCell.h"
#import "XCZPersonInfoHeaderView.h"
#import "XCZPersonInfoHeaderOtherBtn.h"
#import "XCZPersonAttentionMeViewController.h"
#import "XCZPersonHasPraiseViewController.h"
#import "XCZPersonMeAttentionViewController.h"
#import "XCZPersonAttentionClubViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZCircleDetailViewController.h"
#import "XCZPersonInfoLookImageViewController.h"
#import "XCZConfig.h"
#import "DiscoveryConfig.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZPersonInfoViewController () <UITableViewDataSource, UITableViewDelegate, XCZPersonInfoHeaderViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomBar;
@property (weak, nonatomic) IBOutlet UIView *bottomAttentView;
@property (weak, nonatomic) IBOutlet UIView *bottomChatView;


@property (weak, nonatomic) IBOutlet UIImageView *guanzhuImageView;
@property (weak, nonatomic) IBOutlet UILabel *guanzhuLabel;

@property (strong, nonatomic) NSMutableArray *rows;
@property (strong, nonatomic) XCZPersonInfoHeaderView *headerView;
@property (strong, nonatomic) NSDictionary *banner;
@property (assign, nonatomic) int currentPage;
@property (nonatomic, strong) NSString *loginUser_id;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (nonatomic, strong) NSDictionary *selectRow;

@property (assign, nonatomic) BOOL headerViewResh;

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;

@end

@implementation XCZPersonInfoViewController

@synthesize rows = _rows;
@synthesize banner = _banner;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    _loginStatu ? [self loading] : [self selectRowJumpToVC];
}

- (void)setLoginUser_id:(NSString *)loginUser_id
{
    _loginUser_id = loginUser_id;
    if (!self.bbs_user_id) {
        [self requestHeaderData:loginUser_id];
        [self requestTableViewNet];
    }
}

- (void)setBanner:(NSDictionary *)banner {
    _banner = banner;
    
    if (self.headerViewResh) {
        [self updateBannerView];
    }
    [self updateBottomView];
}

- (NSDictionary *)banner {
    return _banner;
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
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.headerView = [[XCZPersonInfoHeaderView alloc] init];
    self.headerView.selfW = self.view.bounds.size.width;
    self.headerView.backgroundColor = [UIColor whiteColor];
    self.headerView.delegate = self;
   
    CGFloat headerViewH = self.view.bounds.size.width + 93 + 49 + 16;
    self.headerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, headerViewH);
    self.tableView.tableHeaderView = self.headerView;
    
    UIButton *backBtn = [[UIButton alloc] init];
    [backBtn setBackgroundImage:[UIImage imageNamed:@"bbs_back"] forState:UIControlStateNormal];
    backBtn.frame = CGRectMake(16, 20 + 16, 23, 23);
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadData) name:@"XCZCircleDetailViewControllerHasDelectedToXCZCircleViewControllerNot" object:nil]; // 详情页帖子被删除的通知
    
    [self.bottomAttentView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomAttentViewDidClick)]];
    [self.bottomChatView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomChatViewDidClick)]];
}

- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.tabBarController.tabBar setHidden:YES];
    [self.tabBarController setHidesBottomBarWhenPushed:YES];
    self.headerViewResh = YES;
    [self requestUserIdNet];
}

- (void)loadData {
    [self refreshHeaderData];
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

- (void)refreshHeaderData
{
    NSString *bbs_user_id;
    if (!self.bbs_user_id) {
        [self requestUserIdNet];
    } else {
        bbs_user_id = self.bbs_user_id;
        [self requestHeaderData:bbs_user_id];
    }
}

- (void)requestHeaderData:(NSString *)bbs_user_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1] , @"bbs_user_id": bbs_user_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.banner = [[responseObject objectForKey:@"data"] firstObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        [self endHeaderRefresh];
    }];
}

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
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 2],
                                 @"page":[NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize":[NSString stringWithFormat:@"%d", 10],
                                 @"bbs_user_id": bbs_user_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *msg = responseObject[@"msg"];
        
        if ([msg containsString:@"未登录"]) {
            [self loading]; // 调用登录页面
        }
        if ([responseObject objectForKey:@"data"] && ![[responseObject objectForKey:@"data"] isEqual:[NSNull null]]) {
            NSArray *rows = [responseObject objectForKey:@"data"];
            if (self.currentPage == 1) {
                self.rows = [rows mutableCopy];
            } else {
                self.rows = [[self.rows arrayByAddingObjectsFromArray:rows] mutableCopy];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //        [self endHeaderRefresh];
    }];
}

/**
 *  是否关注接口
 */
- (void)requestAttionServlet:(int)attion
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/AttionServlet.do"];
    NSDictionary *user = [self.banner objectForKey:@"user"];
//    NSLog(@"user:%@", user);
    NSDictionary *parameters = @{@"attion":[NSString stringWithFormat:@"%d", attion], @"receiver_id": user[@"user_id"]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSMutableDictionary *newUser = [[self.banner objectForKey:@"user"] mutableCopy];
        NSMutableDictionary *newBanner = [NSMutableDictionary dictionary];
        if (attion == 1) { // 关注成功后
            self.headerViewResh = NO;
            [newUser setValue:@"1" forKey:@"clazz"];
            [MBProgressHUD ZHMShowSuccess:@"关注成功"];
        } else { // 取消关注成功后
            self.headerViewResh = NO;
            [newUser setValue:@"2" forKey:@"clazz"];
            [MBProgressHUD ZHMShowSuccess:@"取消成功"];
        }
        
        NSDictionary *user = @{@"user": newUser};
        [newBanner addEntriesFromDictionary:user];
        self.banner = newBanner;
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
                if ([user_id isEqualToString:self.bbs_user_id]) {
                    NSLayoutConstraint *layout = self.view.constraints[7];
                    layout.constant = -49;
                } else {
                    NSLayoutConstraint *layout = self.view.constraints[7];
                    layout.constant = 0;
                }
            }
        } else {
            NSLayoutConstraint *layout = self.view.constraints[7];
            layout.constant = -49;
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
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

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)updateBannerView {
    
    self.headerView.banner = self.banner;
}

- (void)updateBottomView
{
    NSDictionary *user = [self.banner objectForKey:@"user"];
    if ([user[@"clazz"] intValue] != 1) { // 如果之前没关注
        self.guanzhuImageView.image = [UIImage imageNamed:@"bbs_addfollow.png"];
        self.guanzhuLabel.text = @"关注";
    } else {
        self.guanzhuImageView.image = [UIImage imageNamed:@"bbs_hasfollow.png"];
        self.guanzhuLabel.text = @"已关注";
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.rows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *list = [self.rows[section] objectForKey:@"list"];
    return list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat height = 97;
    NSMutableArray *imageArray = [NSMutableArray array];
    NSArray *list = [self.rows[indexPath.section] objectForKey:@"list"];
    NSDictionary *row = list[indexPath.row];
    imageArray = [self changeImage:row[@"share_image"] andImageArray:imageArray];
    NSString *post_clazz = row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        height = 52;
    } else if ([post_clazz intValue] == 3) {
        height = 97;
    } else if ([post_clazz intValue] == 4) {
        NSString *content = row[@"content"];
        if (!content.length) {
            height = 102;
        } else {
            height = 141;
        }
    }
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier;
    NSArray *list = [self.rows[indexPath.section] objectForKey:@"list"];
    NSDictionary *rowY = list[indexPath.row];
    NSArray *imageArray = [rowY[@"share_image"] componentsSeparatedByString:@","];
    imageArray = [self changeImageFullPath:imageArray];
    NSMutableDictionary *row = [NSMutableDictionary dictionaryWithDictionary:rowY];
    [row addEntriesFromDictionary:@{@"images": imageArray}];
    [row addEntriesFromDictionary:[self changeTime:row[@"create_time"]]];
   
    NSString *post_clazz = row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        identifier = @"CellF";
    } else if ([post_clazz intValue] == 3) {
        identifier = @"CellI";
    } else if ([post_clazz intValue] == 4) {
       NSString *content = row[@"content"];
        if (!content.length) {
            identifier = @"CellG";
        } else {
            identifier = @"CellH";
        }
    }

    XCZPersonInfoViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@", identifier]];
    cell.indexPath = indexPath;
    cell.row = row;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *list = [self.rows[indexPath.section] objectForKey:@"list"];
    self.selectRow = list[indexPath.row];
    [self selectRowJumpToVC];
//    [self requestLoginDetection];
}

- (void)selectRowJumpToVC
{
    NSString *post_clazz = self.selectRow[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        XCZCircleDetailViewController *newsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
        newsDetailViewController.reuseIdentifier = @"CellWZ";
        newsDetailViewController.post_id = [self.selectRow objectForKey:@"post_id"];
        [self.navigationController pushViewController:newsDetailViewController animated:YES];
    } else if ([post_clazz intValue] == 3) {
        XCZPersonInfoLookImageViewController *personInfoImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoLookImageViewController"];
        personInfoImageVC.row = self.selectRow;
        [self.navigationController pushViewController:personInfoImageVC animated:YES];
    } else if ([post_clazz intValue] == 4) {
        XCZCircleDetailViewController *newsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
        newsDetailViewController.reuseIdentifier = @"CellC";
        newsDetailViewController.post_id = [self.selectRow objectForKey:@"post_id"];
        [self.navigationController pushViewController:newsDetailViewController animated:YES];
    }
}

#pragma mark - 监听按钮被点击
- (void)bottomAttentViewDidClick
{
    [self addAttention]; // 加关注
}

- (void)bottomChatViewDidClick
{
    
}

- (void)addAttention
{
    NSDictionary *user = [self.banner objectForKey:@"user"];
    if ([user[@"clazz"] intValue] != 1) { // 如果之前没关注
//         NSLog(@"加关注按钮被点击");
        [self requestAttionServlet:1]; // 去关注
    } else {
        [self requestAttionServlet:0]; // 取消关注
    }
}

#pragma mark - XCZPersonInfoHeaderViewDelegate
- (void)personInfoHeaderView:(XCZPersonInfoHeaderView *)headerView otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)otherBtn
{
    if (otherBtn.tag == 1) { // 关注TA的按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonAttentionMeViewController *attentionMeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonAttentionMeViewController"];
            attentionMeVC.bbs_user_id = self.bbs_user_id;
            [self.navigationController pushViewController:attentionMeVC animated:YES];
        }
    } else if (otherBtn.tag == 2) { // 已点赞按钮被点击 (已点赞)
#warning 点赞后台说暂时做不了
//        XCZPersonHasPraiseViewController *hasPraiseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonHasPraiseViewController"];
//        [self.navigationController pushViewController:hasPraiseVC animated:YES];
    } else if (otherBtn.tag == 3) { // TA关注的按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonMeAttentionViewController *meAttentionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonMeAttentionViewController"];
            meAttentionVC.bbs_user_id = self.bbs_user_id;
            [self.navigationController pushViewController:meAttentionVC animated:YES];
        }
    } else if (otherBtn.tag == 4) { // 车友会按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonAttentionClubViewController *attentionClubVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonAttentionClubViewController"];
            attentionClubVC.bbs_user_id = self.bbs_user_id;
            [self.navigationController pushViewController:attentionClubVC animated:YES];
        }
    }
}

#pragma mark - 登录部分
- (void)loading
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

#pragma mark - 私有方法
- (NSArray *)rerowArray:(NSArray *)rows
{
    NSMutableArray *newRows = [NSMutableArray array];
    NSString *yxCreate_timeQ;
    
    for (int i = 0; i<rows.count; i++) {
        NSDictionary *row = rows[i];
        NSString *create_time = [[row objectForKey:@"create_time"] substringToIndex:10];
        NSMutableDictionary *newRow = [row mutableCopy];
        if ([create_time isEqualToString:yxCreate_timeQ]) {
            [newRow setValue:@"000000000000000000000" forKey:@"create_time"];
        }
        [newRows addObject:newRow];
        yxCreate_timeQ = create_time;
    }
    return newRows;
}

- (NSString *)stringToDateWG:(NSString *)create_timeQ
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-mm-dd"];
    NSDate *create_timeZ = [formatter dateFromString:create_timeQ];
    return [NSString stringWithFormat:@"%@", create_timeZ];
}


/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSMutableArray *tempArray = [NSMutableArray array];
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [tempArray addObject:[imageStrs substringToIndex:range.location]];
        NSString *imageStr = [imageStrs substringFromIndex:(range.location + 1)];
        if (imageStr && ![imageStr isEqualToString:@""]) {
            if (tempArray.count < 4) {
                [self changeImage:imageStr andImageArray:tempArray];
            }
            
        }
    } else {
        if (imageStrs && ![imageStrs isEqualToString:@""]) {
            if (tempArray.count < 4) {
               [tempArray addObject:imageStrs];
            }
        }
    }
    return tempArray;
}

/**
 *  添加全路径
 */
- (NSMutableArray *)changeImageFullPath:(NSArray *)imageArray
{
    NSMutableArray *shuchuArray = [NSMutableArray array];
    for (NSString *imageDStr in imageArray) {
       [shuchuArray addObject:[NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], imageDStr]];
    }
    return shuchuArray;
}

/**
 *  处理时间
 */
- (NSDictionary *)changeTime:(NSString *)time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate * needFormatDate = [dateFormatter dateFromString:time];
    NSDate * nowDate = [NSDate date];
    NSTimeInterval detaTime = [nowDate timeIntervalSinceDate:needFormatDate];
    NSString *dateStr = @"";
    NSString *month = @"";
    NSString *day = @"";
    if (detaTime <= 60*60*24) {
        [dateFormatter setDateFormat:@"YYYY-MM-dd"];
        NSString * need_yMd = [dateFormatter stringFromDate:needFormatDate];
        NSString *now_yMd = [dateFormatter stringFromDate:nowDate];
        
        [dateFormatter setDateFormat:@"HH:mm"];
        if ([need_yMd isEqualToString:now_yMd]) {
            //// 在同一天
            dateStr = [NSString stringWithFormat:@"今天"];
        }else{
            ////  昨天
            dateStr = [NSString stringWithFormat:@"昨天"];
        }
    } else {
        month = [[time substringFromIndex:5] substringToIndex:2];
        day = [[time substringFromIndex:8] substringToIndex:2];
    }
    
    if ([month isEqualToString:@"01"]) {
        month = @"一月";
    } else if ([month isEqualToString:@"02"]) {
        month = @"二月";
    } else if ([month isEqualToString:@"03"]) {
        month = @"三月";
    } else if ([month isEqualToString:@"04"]) {
        month = @"四月";
    } else if ([month isEqualToString:@"05"]) {
        month = @"五月";
    } else if ([month isEqualToString:@"06"]) {
        month = @"六月";
    } else if ([month isEqualToString:@"07"]) {
        month = @"七月";
    } else if ([month isEqualToString:@"08"]) {
        month = @"八月";
    } else if ([month isEqualToString:@"09"]) {
        month = @"九月";
    } else if ([month isEqualToString:@"10"]) {
        month = @"十月";
    } else if ([month isEqualToString:@"11"]) {
        month = @"十一月";
    } else if ([month isEqualToString:@"12"]) {
        month = @"十二月";
    }
    return @{@"month": month, @"day": day, @"dateStr": dateStr};
}

@end
