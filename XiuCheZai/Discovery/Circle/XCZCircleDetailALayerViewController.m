//
//  XCZCircleDetailALayerViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/20.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZCircleDetailALayerViewController.h"
#import "XCZConfig.h"
#import "XCZCircleDetailALayerRow.h"
#import "XCZCircleDetailALayerRowReplyView.h"
#import "DiscoveryConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZPersonInfoViewController.h"
#import "XCZCircleDetailWriteView.h"
#import "XCZPersonWebViewController.h"
#import "MBProgressHUD+ZHM.h"

@interface XCZCircleDetailALayerViewController ()<XCZCircleDetailALayerRowDelegate, XCZCircleDetailWriteViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, strong) NSDictionary *artDict; // 主界面主数据
@property (assign, nonatomic) int currentPage;

@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) int goType; // 0:为主帖去点赞，1为主帖评论, 2为下拉加载更多, 3为回复评论, 4为根贴点赞, 5为上拉刷新 6收藏 7底部点赞 8.bottomTextField上遮盖被点击
@property (nonatomic, copy) NSString *publisher_id;
@property (nonatomic, copy) NSString *postContentText; // 发出的内容
@property (assign, nonatomic) CGPoint contentOffsetrequestQ; // 请求数据前contentOffset
@property (nonatomic, strong) NSDictionary *likeViewSubViews;

@property (nonatomic, weak) XCZCircleDetailWriteView *writeView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;
@property (weak, nonatomic) UIView *textFieldZheGaiView;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;


@property (assign, nonatomic) int collectionType; // 收藏类型:0:刚登录后, 1:去收藏, 2:取消收藏
@property (assign, nonatomic) int praiseType; // 回帖点赞类型:0:去点赞, 1:取消点赞
@property (assign, nonatomic) int bottomPraiseType; // 底部点赞类型:0:去点赞, 1:取消点赞

@property (assign, nonatomic) int gongJinru; // 回帖点赞类型:0:去点赞, 1:取消点赞



@end

@implementation XCZCircleDetailALayerViewController

@synthesize artDict = _artDict;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    if (self.goType == 3) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"post_id" : self.post_id,
                               @"forum_id" : self.artDict[@"forum_id"],
                               @"reply_content" : self.postContentText,
                               @"reply_id" : self.reply_id,
                               @"is_anony" : @"0",
                               };
        [self requestReplyPost:dict];
    } else if (self.goType == 4) {
        NSDictionary *dict = @{
                               @"type" : @"0",
                               @"posts_clazz" : @"2",
                               @"post_id" : self.publisher_id,
                               @"host" : self.post_id
                               };
        [self requestPraise:dict];
    } else if (self.goType == 6) {
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.collectionType],
                               @"post_id" : self.post_id,
                               @"fav_cate" : @"1",
                               };
        [self requestCollection:dict];
    } else if (self.goType == 7) {
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.bottomPraiseType],
                               @"posts_clazz" : @"1",
                               @"post_id" : self.post_id,
                               @"host" : self.publisher_id
                               };
        [self requestBottomPraise:dict];
    } else if (self.goType == 8) { // bottomTextField上遮盖被点击
        if (loginStatu) {
            [self goLogining];
        } else {
            [self.textFieldZheGaiView removeFromSuperview];
            self.textFieldZheGaiView = nil;
            [self.bottomTextField becomeFirstResponder];
        }
    }
}

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    
    self.bottomTextField.text = nil;
    self.publisher_id = artDict[@"user_id"];
    if (!self.gongJinru) {
        NSDictionary *collectionDict = @{
                                         @"type" : [NSString stringWithFormat:@"%d", self.collectionType],
                                         @"post_id" : self.post_id,
                                         @"fav_cate" : @"1",
                                         };
        [self requestCollection:collectionDict];
        
        NSDictionary *bottomPraiseDict = @{
                                           @"type" : [NSString stringWithFormat:@"%d", self.bottomPraiseType],
                                           @"posts_clazz" : @"1",
                                           @"post_id" : self.post_id,
                                           @"host" : self.publisher_id
                                           };
        [self requestBottomPraise:bottomPraiseDict];
        self.gongJinru++;
    }
    [self creatSubview];
}

- (NSDictionary *)artDict
{
    if (!_artDict) {
        _artDict = [NSDictionary dictionary];
    }
    return _artDict;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self assistedSetup]; // 辅助设置
    [self loadData];
    [self changeNot]; // 通知处理
    
    [self.collectionBtn addTarget:self action:@selector(collectionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.praiseBtn addTarget:self action:@selector(praiseBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assistedSetup
{
    self.title = @"评论详情";
    self.scrollView.alwaysBounceVertical = YES;
    
    self.collectionType = 0;
    self.bottomPraiseType = 1;
    self.gongJinru = 0;
    
    [self createTextFieldZheGaiView];
    if ([self.delegate respondsToSelector:@selector(detailViewController:bottomTextField:)]) {
        [self.delegate detailViewController:self bottomTextField:self.bottomTextField];
    }
}

- (void)createTextFieldZheGaiView
{
    UIView *textFieldZheGaiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomTextField.bounds.size.width, self.bottomTextField.bounds.size.height)];
    [self.bottomTextField addSubview:textFieldZheGaiView];
    self.textFieldZheGaiView = textFieldZheGaiView;
    [self.textFieldZheGaiView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldZheGaiViewDidClick:)]];
}

- (void)changeNot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNot:) name:@"discoveryPageViewControllerKeyboardWillShowToSubClassVCNot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNot:) name:@"discoveryPageViewControllerKeyboardWillHideToSubClassVCNot" object:nil];
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
    [self requestNet];
}

- (void)clearDataNeedsRefresh {
    self.contentOffsetrequestQ = self.scrollView.contentOffset;
    [self.contentView removeFromSuperview];
    self.contentView = nil;
}

- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1], @"post_id":self.post_id, @"reply_id": self.reply_id, @"pagesize":[NSString stringWithFormat:@"%d", 10], @"page": [NSString stringWithFormat:@"%d", self.currentPage]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        self.artDict = [[responseObject objectForKey:@"data"] firstObject];
        [self endHeaderRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        [self endHeaderRefresh];
    }];
}

- (void)requestReplyPost:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ReplyPostAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"error"] intValue] == 201) {
            [MBProgressHUD ZHMShowSuccess:@"评论成功"];
            [self loadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/DianZanAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"error"] containsString:@"未登录"]) {
            self.goType = 4;
            [self goLogining];
        } else if ([responseObject[@"error"] intValue] == 201) {
            UILabel *likeLabel = [self.likeViewSubViews objectForKey:@"likeLabel"];
            likeLabel.text = nil;
            likeLabel.text = [NSString stringWithFormat:@"%d", [likeLabel.text intValue] + 1];
        } else if ([responseObject[@"error"] intValue] == 333) {
            [MBProgressHUD ZHMShowError:@"您已经点过赞了"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"errorssss:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestCollection:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsfavoritesAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([dict[@"type"] intValue] == 0) {
            //            NSLog(@"获取收藏数据:%@", responseObject);
            int num = [[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"num"] intValue];
            if (num) {
                self.collectionBtn.selected = YES;
                self.collectionType = 2; // 之前已经被收藏，之后要去取消收藏
            } else {
                self.collectionBtn.selected = NO;
                self.collectionType = 1; // 之前没收藏，之后要去收藏
            }
        } else if ([dict[@"type"] intValue] == 1) {
            [MBProgressHUD ZHMShowSuccess:@"收藏成功"];
            self.collectionBtn.selected = YES;
            self.collectionType = 2; // 之前已经被收藏，之后要去取消收藏
        } else {
            [MBProgressHUD ZHMShowSuccess:@"取消收藏成功"];
            self.collectionBtn.selected = NO;
            self.collectionType = 1; // 之前没收藏，之后要去收藏
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
    }];
}

- (void)requestBottomPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsArtgdAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([dict[@"type"] intValue] == 1) {
            int num = [[[[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"] firstObject] objectForKey:@"zan"] intValue];
            if (num) {
                self.praiseBtn.selected = YES;
                self.bottomPraiseType = 3; // 之前已经被点赞，之后要去取消点赞
            } else {
                self.praiseBtn.selected = NO;
                self.bottomPraiseType = 2; // 之前没点赞，之后要去点赞
            }
        } else if ([dict[@"type"] intValue] == 2) {
            [MBProgressHUD ZHMShowSuccess:@"点赞成功"];
            self.praiseBtn.selected = YES;
            self.bottomPraiseType = 3; // 之前已经被点赞，之后要去取消点赞
        } else {
            [MBProgressHUD ZHMShowSuccess:@"取消点赞成功"];
            self.praiseBtn.selected = NO;
            self.bottomPraiseType = 2; // 之前没点赞，之后要去点赞
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

/**
 *  监测登录
 */
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

- (void)creatSubview
{
    self.height = 0.0;
    self.remarkHeight = 0.0;
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 700)];
    [self.scrollView addSubview:self.contentView];
    UIView *remarkView = [[UIView alloc] init];
    remarkView.userInteractionEnabled = YES;
    remarkView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, 500);
    [self.contentView addSubview:remarkView];
    self.remarkView = remarkView;
    
    XCZCircleDetailALayerRow *remarkRow = [[XCZCircleDetailALayerRow alloc] init];
    remarkRow.delegate = self;
    remarkRow.type = 1; // 1代表资讯回复楼层 某一层详细传入
    remarkRow.fatherWidth = remarkView.bounds.size.width;
    remarkRow.floor = self.floor;
    if (self.louzhuId) {
        remarkRow.louzhuId = self.louzhuId;
    } else {
        remarkRow.louzhuId = @"";
    }
    
    remarkRow.remark = self.artDict;
    CGFloat remarkRowY = self.remarkHeight;
    remarkRow.frame = CGRectMake(0, remarkRowY, remarkView.bounds.size.width, remarkRow.height);
    self.remarkHeight += remarkRow.height;
    [remarkView addSubview:remarkRow];
    
    CGRect remarkViewRect = self.remarkView.frame;
    remarkViewRect.size.height = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    self.remarkView.frame = remarkViewRect;
    self.height += self.remarkHeight + XCZNewDetailRemarkRowMarginY;
    [self setupOutFrame];
}

- (void)setupOutFrame
{
    CGRect contentViewRect = self.contentView.frame;
    contentViewRect.size.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.contentView.frame = contentViewRect;
    
    CGSize contentViewSize = self.scrollView.contentSize;
    contentViewSize.height = self.height + XCZNewDetailRemarkRowMarginY;
    self.scrollView.contentSize = contentViewSize;
}

#pragma mark - 通知方法
- (void)keyboardWillShowNot:(NSNotification *)notification
{
    XCZCircleDetailWriteView *writeView = [[XCZCircleDetailWriteView alloc] init];
    writeView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    writeView.delegate = self;
    [self.view addSubview:writeView];
    self.writeView = writeView;
}

- (void)keyboardWillHideNot:(NSNotification *)notification
{
    [self.writeView removeFromSuperview];
    self.writeView = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 代理方法
- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailALayerRowReplyView:(XCZCircleDetailALayerRowReplyView *)detailALayerRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews
{
    self.reply_id = detailALayerRow.remark[@"reply_id"];
    self.publisher_id = detailALayerRow.remark[@"user_id"];
    self.likeViewSubViews = likeViewSubViews;
    self.goType = 4;
    [self requestLoginDetection];
}

- (void)detailALayerRow:(XCZCircleDetailALayerRow *)detailALayerRow replyViewDidClick:(UIView *)replyView
{
    self.reply_id = detailALayerRow.remark[@"reply_id"];
    [self.bottomTextField becomeFirstResponder];
}

#pragma mark - XCZCircleDetailWriteViewDelegate
- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
{
    [self.view endEditing:YES];
}

- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (text.length) {
        [self.view endEditing:YES];
        self.postContentText = text;
        self.goType = 3;
        [self requestLoginDetection];
    } else {
        [MBProgressHUD ZHMShowError:@"说点再发送吧"];
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

#pragma mark - 监听事件
/**
 *  收藏按钮被点击
 */
- (void)collectionBtnDidClick:(UIButton *)collectionBtn
{
    self.goType = 6;
    [self requestLoginDetection]; // 监测登录
}

- (void)praiseBtnDidClick:(UIButton *)praiseBtn
{
    self.goType = 7;
    [self requestLoginDetection]; // 监测登录
}

- (void)textFieldZheGaiViewDidClick:(UIGestureRecognizer *)grz
{
    self.goType = 8;
    [self requestLoginDetection]; // 监测登录
}

- (IBAction)shareBtnDidClick:(UIButton *)sender {
    [self shareMessage:@{@"title": @"", @"description": self.artDict[@"reply_content"], @"thumbImage": [UIImage imageNamed:@"bbs_pro_pic.jpg"], @"webpageUrl": @"http://m.8673h.com/"}];
}

#pragma mark - 踢啊转控制器方法
/**
 *  跳转到XCZPersonInfoViewController
 */
- (void)jumpToPersonInfoVC:(NSString *)bbs_user_id
{
    NSLog(@"bbs_user_id:%@", bbs_user_id);
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
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

//- (void)morePullUpRefreshControl:(UIScrollView *)scrollView
//{
//    [self removeIndicatorHeaderView];
//    if (!self.indicatorFooterView) {
//        CGFloat indicatorFooterViewW = 40;
//        CGFloat indicatorFooterViewH = indicatorFooterViewW;
//        CGFloat indicatorFooterViewX = (scrollView.bounds.size.width - indicatorFooterViewW) * 0.5;
//        CGFloat indicatorFooterViewY = scrollView.contentSize.height;
//        UIActivityIndicatorView *indicatorFooterView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(indicatorFooterViewX, indicatorFooterViewY, indicatorFooterViewW, indicatorFooterViewH)];
//        indicatorFooterView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
//        indicatorFooterView.hidden = NO;
//        [scrollView addSubview:indicatorFooterView];
//        self.indicatorFooterView = indicatorFooterView;
//    }
//}

- (void)startHeaderRefresh:(UIScrollView *)scrollView
{
    [self.indicatorHeaderView startAnimating];
    [self refreshData];
}

//- (void)startFooterRefresh:(UIScrollView *)scrollView
//{
//    [self.indicatorFooterView startAnimating];
//    //    [self refreshData];
//}

- (void)endHeaderRefresh
{
    CGPoint offset = self.scrollView.contentOffset;
    offset.y = 0;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentOffset = offset;
        } completion:^(BOOL finished) {
            [self removeIndicatorHeaderView];
        }];
    });
}

//- (void)endFooterRefresh
//{
//    CGPoint offset = self.scrollView.contentOffset;
//    offset.y = 0;
//    [UIView animateWithDuration:0.5 animations:^{
//        self.scrollView.contentOffset = offset;
//    } completion:^(BOOL finished) {
//        [self removeIndicatorFooterView];
//    }];
//}

- (void)stopHeaderScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    //    (scrollView.contentOffset.y < -75) ? offset.y = -75 : ((scrollView.contentOffset.y > 0) ? offset.y-- : offset.y++);
    ((scrollView.contentOffset.y < -75) ? (offset.y = -75) : (offset.y = 0));
    [scrollView setContentOffset:offset animated:YES];
}

//- (void)stopFooterScroll:(UIScrollView *)scrollView
//{
//    CGPoint offset = scrollView.contentOffset;
//    (scrollView.contentOffset.y < 75) ? (offset.y = 0) : (offset.y = 75);
//    scrollView.contentOffset = offset;
//    //    [scrollView setContentOffset:offset animated:];
//
//    [UIView animateWithDuration:1.0 animations:^{
//        if (offset.y >= 75) {
//            [self startFooterRefresh:scrollView];
//        } else {
//            [self removeIndicatorFooterView];
//        }
//    }];
//}

- (void)removeIndicatorHeaderView
{
    [self.indicatorHeaderView stopAnimating];
    [self.indicatorHeaderView removeFromSuperview];
    self.indicatorHeaderView = nil;
}

//- (void)removeIndicatorFooterView
//{
//    [self.indicatorFooterView stopAnimating];
//    [self.indicatorFooterView removeFromSuperview];
//    self.indicatorFooterView = nil;
//}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self loadPullDownRefreshControl:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y < -75) { // 下拉刷新
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    //    if (scrollView.contentOffset.y > 75) { // 上拉加载更多
    //        [self morePullUpRefreshControl:scrollView];
    //        [self stopFooterScroll:scrollView];
    //    }
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
