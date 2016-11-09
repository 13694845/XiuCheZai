//
//  XCZMessageReplyViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZMessageReplyViewController.h"
#import "XCZMessageReplyViewCell.h"
#import "XCZMessageTopicDetailsViewController.h"
#import "XCZMessageCommentDetailsViewController.h"
#import "XCZConfig.h"
#import "XCZPersonInfoViewController.h"
#import "XCZCircleDetailViewController.h"
#import "XCZCircleDetailALayerViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZNewDetailWriteView.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZMessageReplyViewController () <UITableViewDataSource, UITableViewDelegate, XCZMessageReplyViewCellDelegate, XCZNewDetailWriteViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *rows;
@property (assign, nonatomic) NSDictionary *artDict;
@property (assign, nonatomic) int clazz;
@property (nonatomic, copy) NSString *reply_id;
@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, copy) NSString *forum_id;
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property(nonatomic, weak)XCZNewDetailWriteView *writeView;
@property (assign, nonatomic) int goType; // 1:为点击回复，2为点击发送
@property (nonatomic, copy) NSString *postContentText; // 发出的内容

@end

@implementation XCZMessageReplyViewController

@synthesize rows = _rows;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    if (self.goType == 1) {
        loginStatu ? [self goLogining] : [self createWriteView];
    } else if (self.goType == 2) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"post_id" : self.post_id,
                               @"forum_id" : self.forum_id,
                               @"reply_content" : self.postContentText,
                               @"reply_id" : self.reply_id,
                               @"is_anony" : @"0",
                               };
        
//        NSLog(@"dictdictdict:%@", dict);
//        
        loginStatu ? [self goLogining] : [self requestReplyPost:dict];
    }
}

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    
//    NSLog(@"_clazz_clazz:%d", _clazz);
    self.clazz == 1 ? [self jumpToDetailsVC] : [self jumpToDetailALayerVC];
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
    
    self.title = @"回复我的";
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    [self loadData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createWriteView
{
    XCZNewDetailWriteView *writeView = [[XCZNewDetailWriteView alloc] init];
    writeView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [writeView.commentTextView becomeFirstResponder];
    writeView.delegate = self;
    [self.view addSubview:writeView];
    self.writeView = writeView;
}

- (void)removeWriteView
{
    [self.writeView removeFromSuperview];
    self.writeView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.tabBarController.tabBar setHidden:YES];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsMessageAction.do"];
    NSDictionary *parameters = @{@"type":@"3"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.rows = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)requestCircleDetailVCNet:(NSString *)post_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0] , @"post_id":post_id};
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *datas = [responseObject objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]]) {
            datas = nil;
        }
        for (NSDictionary *dict in datas) {
            int taskId = [[dict objectForKey:@"taskId"] intValue];
            if (taskId == 2644) {
                if ([[dict objectForKey:@"rows"] firstObject])
                self.artDict = [[dict objectForKey:@"rows"] firstObject];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestReplyPost:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ReplyPostAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"error"] intValue] == 201) {
            [MBProgressHUD ZHMShowSuccess:@"评论成功"];
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

- (void)updateTableView {
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.rows.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 147;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XCZMessageReplyViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CellA" forIndexPath:indexPath];
    cell.tag = indexPath.row; // 暂时
    cell.row = self.rows[indexPath.row];
    cell.delegate = self;
    return cell;
}

#pragma mark - XCZMessagePraiseViewCellDelegate
- (void)replyViewCell:(XCZMessageReplyViewCell *)replyViewCell brandsViewDidClick:(NSString *)user_id
{
    XCZPersonInfoViewController *personInfoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoViewController.bbs_user_id = user_id;
    [self.navigationController pushViewController:personInfoViewController animated:YES];
}

- (void)replyViewCell:(XCZMessageReplyViewCell *)replyViewCell replyViewDidClick:(NSDictionary *)row
{
    self.clazz = [row[@"clazz"] intValue];
    self.reply_id = row[@"reply_id"];
    self.post_id = row[@"post_id"];
    [self requestCircleDetailVCNet:self.post_id];
}

- (void)replyViewCell:(XCZMessageReplyViewCell *)replyViewCell brandsHuifuBtnDidClick:(NSDictionary *)row
{
    self.goType = 1;
    self.reply_id = row[@"reply_id"];
    self.post_id = row[@"post_id"];
    self.forum_id = row[@"forum_id"];
    [self requestLoginDetection];
}

#pragma mark - XCZNewDetailWriteViewDelegate
- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
{
    [self.view endEditing:YES];
}

- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (text.length) {
        [self.view endEditing:YES];
        self.goType = 2;
        self.postContentText = text;
        [self requestLoginDetection];
    } else {
        [MBProgressHUD ZHMShowError:@"说点再发送吧"];
    }
}

#pragma mark - 通知方法
- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        CGRect keyboardFrame = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
        CGRect viewRect = self.view.frame;
        viewRect.origin.y = -keyboardFrame.size.height + 64;
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = viewRect;
        } completion:^(BOOL finished) {}];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [self removeWriteView];
    CGRect viewRect = self.view.frame;
    viewRect.origin.y = 64;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewRect;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 跳转控制器
- (void)jumpToDetailsVC
{
    int post_clazz = [_artDict[@"post_clazz"] intValue];
    NSString *share_image = _artDict[@"share_image"];
    NSString *identifier;
    if (post_clazz == 1) {
        identifier = @"CellWZ";
    } else if (post_clazz == 2) { // 投票贴，暂时没有
        identifier = @"CellWZ";
    } else if (post_clazz == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:share_image andImageArray:imageArray];
        if (imageArray.count == 1) {
            identifier = @"CellB";
        } else if (imageArray.count <= 3) {
            identifier = @"CellA1";
        } else if (imageArray.count <= 6) {
            identifier = @"CellA";
        } else {
            identifier = @"CellA2";
        }
    } else if (post_clazz == 4) {
        NSMutableArray *imageArray = [NSMutableArray array];
        if (!((NSString *)share_image).length) {
            identifier = @"CellC1";
        } else {
            imageArray = [self changeImage:share_image andImageArray:imageArray];
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
    
    XCZCircleDetailViewController *topicDetailsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    topicDetailsVC.reuseIdentifier = identifier;
    topicDetailsVC.post_id = self.post_id;
    [self.navigationController pushViewController:topicDetailsVC animated:YES];
}

- (void)jumpToDetailALayerVC
{
    XCZCircleDetailALayerViewController *circleDetailALayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailALayerViewController"];
    circleDetailALayerVC.post_id = self.post_id;
    circleDetailALayerVC.reply_id = self.reply_id;
    [self.navigationController pushViewController:circleDetailALayerVC animated:YES];
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

@end
