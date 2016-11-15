//
//  XCZMessageViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageViewController.h"
#import "XCZMessageRecommendedViewController.h"
#import "XCZMessageSystemViewController.h"
#import "XCZMessagePraiseViewController.h"
#import "XCZMessageReplyViewController.h"
#import "XCZConfig.h"
#import "XCZPersonWebViewController.h"
#import "XCZMessageHeaderView.h"
#import "XCZCircleUserListViewController.h"
#import "XCZMessageViewCell.h"
#import "XCZMessageSignAlterView.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZPersonInfoHeaderOtherBtn.h"
#import "XCZPersonAttentionMeViewController.h"
#import "XCZPersonMeAttentionViewController.h"
#import "XCZPersonAttentionClubViewController.h"
#import "XCZMessageMyTopicViewController.h"
#import "XCZMessageChatTabulationViewController.h"
#import "XCZMessageSearchViewController.h"

@interface XCZMessageViewController ()<XCZMessageHeaderViewDelegate, UITableViewDelegate, UITableViewDataSource, XCZMessageSignAlterViewDelegate>

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) XCZMessageHeaderView *headerView;
@property (strong, nonatomic) NSDictionary *userDict;
@property (strong, nonatomic) NSDictionary *content;
@property (strong, nonatomic) NSArray *chatDatas;
@property (strong, nonatomic) NSArray *replys;
@property (strong, nonatomic) NSArray *chats;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@end

@implementation XCZMessageViewController

@synthesize userDict = _userDict;
@synthesize replys = _replys;
@synthesize chats = _chats;
@synthesize chatDatas = _chatDatas;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    loginStatu ? [self goLogining] : [self loadData];
}

- (void)setChats:(NSArray *)chats
{
    _chats = chats;
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    [self.tableView reloadData];
}

- (void)setUserDict:(NSDictionary *)userDict
{
    _userDict = userDict;
    
    if (userDict.count) {
        self.content = @{@"num": userDict[@"bgz"], @"content":@""};
        self.headerView.userDict = userDict;
        [self reloadRow:2];
    }
}

- (void)setReplys:(NSArray *)replys
{
    _replys = replys;
    
    if (replys.count) {
        self.content = @{@"num": @(replys.count), @"content": [[replys firstObject] objectForKey:@"content"]};
        [self reloadRow:3];
    }
}

- (void)setChatDatas:(NSArray *)chatDatas
{
    _chatDatas = chatDatas;
    
    if (chatDatas && (chatDatas.count - 1)) {
        self.content = @{@"num": @(chatDatas.count - 1), @"content": [[chatDatas firstObject] objectForKey:@"user_name"]};
        [self reloadRow:1];
    }
}

- (NSDictionary *)userDict
{
    if (!_userDict) {
        _userDict = [NSDictionary dictionary];
    }
    return _userDict;
}

- (NSArray *)replys
{
    if (!_replys) {
        _replys = [NSArray array];
    }
    return _replys;
}

- (NSArray *)chats
{
    if (!_chats) {
        _chats = [NSArray array];
    }
    return _chats;
}

- (NSArray *)chatDatas
{
    if (!_chatDatas) {
        _chatDatas = [NSArray array];
    }
    return _chatDatas;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的发现";
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, -20, self.view.bounds.size.width, self.view.bounds.size.height + 20)];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    XCZMessageHeaderView *headerView = [[XCZMessageHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 263)];
    headerView.delegate = self;
    headerView.backgroundColor = [UIColor colorWithRed:229/255.0 green:21/255.0 blue:45/255.0 alpha:1.0];
    tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    self.chats = @[
                   @{
                       @"name": @"我的话题",
                       @"icon": @"bbs_myfinding_topic",
                       @"content": @"最新发表内容"
                       },
                   @{
                       @"name": @"聊天",
                       @"icon": @"bbs_myfinding_chat",
                       @"content": @"最近用户"
                       },
                   @{
                       @"name": @"赞我的",
                       @"icon": @"bbs_like_white",
                       @"content": @""
                       },
                   @{
                       @"name": @"回复我的",
                       @"icon": @"bbs_message_white",
                       @"content": @""
                       }
                   ];
    
    UIButton *backBtn = [[UIButton alloc] init];
    backBtn.frame = CGRectMake(16, 20 + 16, 23, 23);
    [self.view addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *backBtnImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2.5, 10, 18)];
    backBtnImageView.image = [UIImage imageNamed:@"bbs_arrow"];
    [backBtn addSubview:backBtnImageView];
    
    CGFloat titleLabelW = 150;
    CGFloat titleLabelH = 23;
    CGFloat titleLabelX = (self.tableView.bounds.size.width - titleLabelW) * 0.5;
    CGFloat titleLabelY = 20 + 16;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH)];
    titleLabel.text = @"我的发现";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLabel];
    
    CGFloat rightBtnWH = 18;
    CGFloat rightBtnX = self.tableView.bounds.size.width - rightBtnWH - 18;
    CGFloat rightBtnY = titleLabelY;
    UIButton *rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(rightBtnX, rightBtnY, rightBtnWH, rightBtnWH)];
    [rightBtn setBackgroundImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    [self.view addSubview:rightBtn];
    
    [rightBtn addTarget:self action:@selector(rightBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)backBtnDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)rightBtnDidClick
{
    XCZMessageSearchViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageSearchViewController"];
    [self.navigationController pushViewController:searchVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
     self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = YES;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    [self requestLoginDetection];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSDictionary *parameters = @{@"type":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.userDict = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"user"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
     URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsMessageAction.do"];
     parameters = @{@"type":@"3"};
     [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
     self.replys = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
     } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ContactServlet.do"];
    parameters = nil;
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//         NSLog(@"responseOloadDatddda:%@", responseObject);
        
        self.chatDatas = [responseObject objectForKey:@"data"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)requestUpDataRemarkAction:(NSString *)remark
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/UpDataRemarkAction.do"];
    NSDictionary *parameters = @{@"remark": remark};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
       int result = [[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"result"] intValue];
        if (result == 1) {
            NSMutableDictionary *userDict = [self.userDict mutableCopy];
            [userDict setValue:remark forKey:@"remark"];
            self.headerView.userDict = userDict;
            [MBProgressHUD ZHMShowSuccess:@"修改签名成功"];
        } else {
            [MBProgressHUD ZHMShowError:@"修改签名失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightBarButtonItemDidClick
{
    XCZCircleUserListViewController *circleUserListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleUserListViewController"];
    circleUserListVC.post_id = self.userDict[@"user_id"];
    [self.navigationController pushViewController:circleUserListVC animated:YES];
}

/**
 *  刷新第几个cell
 */
- (void)reloadRow:(NSInteger)row
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - XCZMessageHeaderViewDelegate
- (void)messageHeaderView:(XCZMessageHeaderView *)headerView signDidClick:(UILabel *)signLabel
{
    XCZMessageSignAlterView *signAlterView = [[XCZMessageSignAlterView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    signAlterView.delegate = self;
    signAlterView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:signAlterView];
}

- (void)messageHeaderView:(XCZMessageHeaderView *)headerView otherBtnDidClick:(XCZPersonInfoHeaderOtherBtn *)otherBtn
{
    NSString *user_id = headerView.userDict[@"user_id"];
    if (otherBtn.tag == 1) { // 关注TA的按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonAttentionMeViewController *attentionMeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonAttentionMeViewController"];
            attentionMeVC.bbs_user_id = user_id;
            [self.navigationController pushViewController:attentionMeVC animated:YES];
        }
    } else if (otherBtn.tag == 2) { // 已点赞按钮被点击 (已点赞)
    } else if (otherBtn.tag == 3) { // TA关注的按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonMeAttentionViewController *meAttentionVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonMeAttentionViewController"];
            meAttentionVC.bbs_user_id = user_id;
            [self.navigationController pushViewController:meAttentionVC animated:YES];
        }
    } else if (otherBtn.tag == 4) { // 车友会按钮被点击
        if ([otherBtn.valueLabel.text integerValue]) {
            XCZPersonAttentionClubViewController *attentionClubVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonAttentionClubViewController"];
            attentionClubVC.bbs_user_id = user_id;
            [self.navigationController pushViewController:attentionClubVC animated:YES];
        }
    }
}

#pragma mark - XCZMessageSignAlterViewDelegate
- (void)messageSignAlterViewBackDidClick:(XCZMessageSignAlterView *)alterView
{
    [alterView removeFromSuperview];
    alterView = nil;
}

- (void)messageSignAlterView:(XCZMessageSignAlterView *)alterView determineBtnDidClick:(UITextField *)textField
{
    [self requestUpDataRemarkAction:textField.text];
    [alterView removeFromSuperview];
    alterView = nil;
}

#pragma mark - uitableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chats.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifer = @"cell";
    XCZMessageViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifer];
    if (!cell) {
        cell = [[XCZMessageViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifer];
    }
    cell.selfW = self.tableView.bounds.size.width;
    cell.chat = self.chats[indexPath.row];
    cell.content = self.content;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) { // 我的话题
        XCZMessageMyTopicViewController *myTopicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageMyTopicViewController"];
        myTopicVC.bbs_user_id = self.userDict[@"user_id"];
        [self.navigationController pushViewController:myTopicVC animated:YES];
    } else if (indexPath.row == 1) { // 聊天
        XCZMessageChatTabulationViewController *chatTabulationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageChatTabulationViewController"];
        [self.navigationController pushViewController:chatTabulationVC animated:YES];
    } else if (indexPath.row == 2) { // 赞我的
        XCZMessagePraiseViewController *praiseVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessagePraiseViewController"];
        [self.navigationController pushViewController:praiseVC animated:YES];
    } else if (indexPath.row == 3) { // 回复我的
        XCZMessageReplyViewController *replyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageReplyViewController"];
        [self.navigationController pushViewController:replyVC animated:YES];
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
    webViewController.type = 1;
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
