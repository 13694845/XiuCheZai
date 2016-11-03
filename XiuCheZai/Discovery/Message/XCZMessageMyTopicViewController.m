//
//  XCZMessageMyTopicViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/30.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageMyTopicViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZConfig.h"
#import "XCZPersonInfoViewCell.h"
#import "XCZCircleDetailViewController.h"
#import "XCZPersonInfoLookImageViewController.h"

@interface XCZMessageMyTopicViewController()<UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (nonatomic, strong) NSString *loginUser_id;
@property (nonatomic, strong) NSDictionary *selectRow;

@end

@implementation XCZMessageMyTopicViewController

@synthesize rows = _rows;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    _loginStatu ? [self loading] : [self selectRowJumpToVC];
}

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

- (void)updateTableView {
    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"我的话题";
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.translucent = NO;
    [self requestUserIdNet];
}

#pragma mark - 网络请求部分
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
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
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

#pragma mark - 代理
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
    NSMutableArray *imageArray = [NSMutableArray array];
    imageArray = [self changeImage:rowY[@"share_image"] andImageArray:imageArray];
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
    
    XCZPersonInfoViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[NSString stringWithFormat:@"%@", identifier] forIndexPath:indexPath];
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
    [self requestLoginDetection];
}

#pragma mark - 跳转控制器
- (void)selectRowJumpToVC
{
    NSString *post_clazz = self.selectRow[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        XCZCircleDetailViewController *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
        detailViewController.reuseIdentifier = @"CellWZ";
        detailViewController.post_id = [self.selectRow objectForKey:@"post_id"];
        [self.navigationController pushViewController:detailViewController animated:YES];
    } else if ([post_clazz intValue] == 3) {
        XCZPersonInfoLookImageViewController *personInfoImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoLookImageViewController"];
        personInfoImageVC.row = self.selectRow;
        [self.navigationController pushViewController:personInfoImageVC animated:YES];
    } else if ([post_clazz intValue] == 4) {
        
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
/**
 *  将images字符串装入image数组
 */
- (NSMutableArray *)changeImage:(NSString *)imageStrs andImageArray:(NSMutableArray *)imageArray
{
    NSRange range = [imageStrs rangeOfString:@","];
    if (range.length) {
        [imageArray addObject:[imageStrs substringToIndex:range.location]];
        NSString *imageStr = [imageStrs substringFromIndex:(range.location + 1)];
        if (imageStr && ![imageStr isEqualToString:@""]) {
            if (imageArray.count < 4) {
                [self changeImage:imageStr andImageArray:imageArray];
            }
            
        }
    } else {
        if (imageStrs && ![imageStrs isEqualToString:@""]) {
            if (imageArray.count < 4) {
                [imageArray addObject:imageStrs];
            }
        }
    }
    return imageArray;
}

/**
 *  添加全路径
 */
- (NSMutableArray *)changeImageFullPath:(NSArray *)imageArray
{
    NSMutableArray *shuchuArray = [NSMutableArray array];
    for (NSString *imageDStr in imageArray) {
        [shuchuArray addObject:[NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], imageDStr]];
    }
    return shuchuArray;
}

/**
 *  处理时间
 */
- (NSDictionary *)changeTime:(NSString *)time
{
    NSString *month = [[time substringFromIndex:5] substringToIndex:2];
    NSString *day = [[time substringFromIndex:8] substringToIndex:2];
    return @{@"month": month, @"day": day};
}


@end
