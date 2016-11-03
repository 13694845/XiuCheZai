//
//  XCZClubCircleUnsubscribeViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZClubCircleUnsubscribeViewController.h"
#import "XCZClubCircleBrandsViewController.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZDiscoveryFrameViewController.h"
#import "XCZPersonWebViewController.h"

@interface XCZClubCircleUnsubscribeViewController ()

@property (weak, nonatomic) IBOutlet UIView *inviteFriendsJoinView;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topicLabel;
@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;
@property (weak, nonatomic) IBOutlet UIButton *lessBtn;
@property (weak, nonatomic) IBOutlet UIView *addDelectedView;

@property (assign, nonatomic) int addType; // 2.为添加按钮 3.为删除按钮
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) UIView *introductionView;
@property (weak, nonatomic) UILabel *introductionNameLabel;
@property (weak, nonatomic) UILabel *introductionNameRemarkLabel;

@property (nonatomic, strong) NSDictionary *row;

@end

@implementation XCZClubCircleUnsubscribeViewController

@synthesize row = _row;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    loginStatu ? [self goLogining] : [self requestFormumNet:self.lessBtn andType:self.addType];
}

- (void)setRow:(NSDictionary *)row
{
    _row = row;
    [self updateView];
}

- (NSDictionary *)row
{
    if (!_row) {
        _row = [NSDictionary dictionary];
    }
    return _row;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    UIView *introductionView = [[UIView alloc] initWithFrame:CGRectMake(0, 75 + 16, self.view.bounds.size.width, 50)];
    introductionView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:introductionView];
    self.introductionView = introductionView;
    
    UILabel *introductionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 8, 70, 16)];
    introductionNameLabel.text = @"本会简介";
    introductionNameLabel.textColor = [UIColor colorWithRed:68/255.0 green:68/255.0 blue:68/255.0 alpha:1.0];
    introductionNameLabel.font = [UIFont systemFontOfSize:14];
    [introductionView addSubview:introductionNameLabel];
    self.introductionNameLabel = introductionNameLabel;
    
    UILabel *introductionNameRemarkLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(introductionNameLabel.frame) + 8, self.view.bounds.size.width - 16, 34)];
    introductionNameRemarkLabel.numberOfLines = 0;
    introductionNameRemarkLabel.text = @"";
    introductionNameRemarkLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    introductionNameRemarkLabel.font = [UIFont systemFontOfSize:10];
    [introductionView addSubview:introductionNameRemarkLabel];
    self.introductionNameRemarkLabel = introductionNameRemarkLabel;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemDidClick)];
    [self.inviteFriendsJoinView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(inviteFriendsJoinCellDidClick)]];
    
    [self.addDelectedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addDelectedViewDidClick)]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    self.hasJoin ? [self showLessBtn] : [self hideLessBtn];
    [self requestNet];
    
}

- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CateAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 6], @"forum_id": self.forum_id};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.row = [[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"] firstObject];
//        NSLog(@"rows:%@", self.row);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
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
            self.hasJoin ? [self showLessBtn] : [self hideLessBtn];
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

//clicks = 0;
//"forum_id" = 111;
//"forum_name" = "\U4eba\U751f\U5dc5\U5cf0\U5565\U5730";
//"forum_remark" = "\U8fd9\U8fb9\U52a0\U4e86\U4e0a\U8fb9\U52a0\U4e0d\U52a0\Uff1f";
//"forum_style" = "\U600e\U4e48\U641e";
//members = 0;
//num = 0;
//"parent_id" = 109;
//totals = 17;
//"user_id" = "";

- (void)updateView
{
    self.title = self.row[@"forum_name"];
#warning  后台没有提供字段
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:@""] placeholderImage:[UIImage imageNamed:@"bbs_pro_pic"]];
    self.nameLabel.text = self.row[@"forum_name"];
    self.topicLabel.text = self.row[@"num"];
    self.attentionLabel.text = self.row[@"members"];
    self.introductionNameRemarkLabel.text = self.row[@"forum_remark"];
    
    CGRect introductionNameRemarkLabelRect = self.introductionNameRemarkLabel.frame;
    CGSize introductionNameRemarkLabelSize = [self.introductionNameRemarkLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 32, self.view.bounds.size.height - 58 - 64 - 35) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.introductionNameRemarkLabel.font} context:nil].size;
    introductionNameRemarkLabelRect.size.height = introductionNameRemarkLabelSize.height;
    introductionNameRemarkLabelRect.size.width = introductionNameRemarkLabelSize.width;
    self.introductionNameRemarkLabel.frame = introductionNameRemarkLabelRect;
    
    CGRect introductionViewRect = self.introductionView.frame;
    introductionViewRect.size.height = CGRectGetMaxY(self.introductionNameRemarkLabel.frame) + 16;
    self.introductionView.frame = introductionViewRect;
}

- (void)addDelectedViewDidClick
{
    self.addType = self.hasJoin ? 3 : 2;
    [self requestLoginDetection]; // 监测登录
}

- (void)inviteFriendsJoinCellDidClick
{
    XCZClubCircleBrandsViewController *brandsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubCircleBrandsViewController"];;
    [self.navigationController presentViewController:brandsVC animated:YES completion:nil];
}

- (void)leftBarButtonItemDidClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZClubCircleUnsubscribeViewControllerToXCZClubCircleViewControllerRefreshNot" object:nil userInfo:@{@"hasJoin": @(self.hasJoin)}];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 私有方法
- (void)showLessBtn
{
    NSLog(@"showLessBtn:%@", self.lessBtn);
    [self.lessBtn setImage:[UIImage imageNamed:@"bbs_circleminus"] forState:UIControlStateNormal];
}

- (void)hideLessBtn
{
    NSLog(@"hideLessBtn:%@", self.lessBtn);
    [self.lessBtn setImage:[UIImage imageNamed:@"bbs_circleAdd_green"] forState:UIControlStateNormal];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
