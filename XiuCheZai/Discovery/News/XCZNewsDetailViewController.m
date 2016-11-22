//
//  XCZNewsDetailViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsDetailViewController.h"
#import "XCZNewDetailRemarkRow.h"
#import "DiscoveryConfig.h"
#import "XCZNewsUserListViewController.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZNewDetailALayerViewController.h"
#import "XCZPersonInfoViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZDiscoveryPageViewController.h"
#import "XCZNewDetailWriteView.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZTimeTools.h"

@interface XCZNewsDetailViewController ()<UIScrollViewDelegate, UIWebViewDelegate, XCZNewDetailRemarkRowDelegate, UITextFieldDelegate, XCZNewDetailWriteViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, strong) NSMutableArray *datas; // 主界面数据(处理前数据)
@property (nonatomic, strong) NSMutableArray *comments; // 评论数据(处理前数据)
@property (nonatomic, strong) NSDictionary *artDict; // 主界面主数据
@property (nonatomic, strong) NSDictionary *praiseNumDict; // 主界面点赞数
@property (nonatomic, strong) NSMutableArray *praiseAvatars; // 主界面头像
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int pagesize;

@property(nonatomic, copy)NSString *reply_id;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) int goType; // 0:为主帖去点赞，1为主帖评论, 2为下拉加载更多, 3为回复评论, 4为根贴点赞, 5为上拉刷新 6收藏 7底部点赞 8.bottomTextField上遮盖被点击
@property (nonatomic, copy) NSString *postContentText; // 发出的内容
@property (assign, nonatomic) CGPoint contentOffsetrequestQ; // 请求数据前contentOffset
@property (assign, nonatomic) int collectionType; // 收藏类型:0:刚登录后, 1:去收藏, 2:取消收藏
@property (assign, nonatomic) int bottomPraiseType; // 底部点赞类型:1:刚登录后获取是否已经点赞, 2:去点赞, 3:取消点赞
@property (nonatomic, weak) UIWebView *newsTitleView;

@property (nonatomic, strong) NSDictionary *likeViewSubViews;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;
@property(nonatomic, weak)XCZNewDetailWriteView *writeView;

@property (nonatomic, copy) NSString *publisher_id;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;
@property (weak, nonatomic) UIView *textFieldZheGaiView;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;
@property (assign, nonatomic) BOOL isNewRemark; // 是否有新评论
@property (assign, nonatomic) BOOL noRefresh; // 是否不需要刷新
@property (assign, nonatomic) CGPoint typeThreeOffset; // 保存点击回复评论时的offset

@end

@implementation XCZNewsDetailViewController

@synthesize datas = _datas;
@synthesize comments = _comments;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    if (self.goType == 0) {
    } else if (self.goType == 1) {
        NSDictionary *dict = @{
                                  @"type" : @"1",
                                  @"artid" : self.artid,
                                  @"art_cateid" : self.artDict[@"art_cateid"],
                                  @"reply_content" : self.postContentText,
                                  @"is_anony" : @"0",
                               };
      
        loginStatu ? [self goLogining] : [self requestReplyPost:dict];
    } else if (self.goType == 3) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"artid" : self.artid,
                               @"art_cateid" : self.artDict[@"art_cateid"],
                               @"reply_content" : self.postContentText,
                               @"reply_id" : self.reply_id,
                               @"is_anony" : @"0",
                               };
        loginStatu ? [self goLogining] : [self requestReplyPost:dict];
    } else if (self.goType == 4) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"artid" : self.reply_id,
                               @"gd_type" : @"1",
                               @"gd_clazz" : @"2",
                               @"publisher_id" : self.publisher_id,
                               };
        loginStatu ? [self goLogining] : [self requestPraise:dict];
    } else if (self.goType == 6) { // 收藏按钮被点击
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.collectionType],
                               @"post_id" : self.artid,
                               @"fav_cate" : @"2",
                               };
        loginStatu ? [self goLogining] : [self requestCollection:dict];
    } else if (self.goType == 7) { // 底部点赞按钮被点击
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.bottomPraiseType],
                               @"gd_type" : @"1",
                               @"gd_clazz" : @"1",
                               @"publisher_id" : @"0",
                               @"artid": self.artid,
                               };
        loginStatu ? [self goLogining] : [self requestBottomPraise:dict];
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

- (NSDictionary *)artDict
{
    if (!_artDict) {
        _artDict = [NSDictionary dictionary];
    }
    return _artDict;
}

- (NSDictionary *)praiseNumDict
{
    if (!_praiseNumDict) {
        _praiseNumDict = [NSDictionary dictionary];
    }
    return _praiseNumDict;
}

- (NSMutableArray *)praiseAvatars
{
    if (!_praiseAvatars) {
        _praiseAvatars = [NSMutableArray array];
    }
    return _praiseAvatars;
}

- (void)setDatas:(NSMutableArray *)datas
{
    _datas = datas;
    
    self.bottomTextField.text = nil;
    if (self.goType == 5) {
    }
}
- (NSMutableArray *)datas
{
    if (!_datas) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

- (void)setComments:(NSMutableArray *)comments
{
    _comments = comments;
    
    NSDictionary *collectionDict = @{
                                     @"type" : [NSString stringWithFormat:@"%d", 0],
                                     @"post_id" : self.artid,
                                     @"fav_cate" : @"2",
                                     };
    [self requestCollection:collectionDict];
    NSDictionary *bottomPraiseDict = @{
                                       @"type" : @"1",
                                       @"gd_type" : @"1",
                                       @"gd_clazz" : @"1",
                                       @"publisher_id" : @"0",
                                       @"artid": self.artid,
                                       };
    [self requestBottomPraise:bottomPraiseDict];
    
    if (self.isNewRemark) {
        [self clearDataNeedsRefresh];
        [self creatDetailsView];
        self.currentPage ++;
    } else {
        if (self.goType != 2) {
            [self clearDataNeedsRefresh];
            [self creatDetailsView];
            self.currentPage ++;
        }
    }
    if (self.goType == 5) {
        self.pagesize = 100;
        self.currentPage = 1;
    }
}

- (NSMutableArray *)comments
{
    if (!_comments) {
        _comments = [NSMutableArray array];
    }
    return _comments;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self assistedSetup]; // 辅助设置
    [self changeNot]; // 通知处理
    
    [self.collectionBtn addTarget:self action:@selector(collectionBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.praiseBtn addTarget:self action:@selector(praiseBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.tabBarController.tabBar setHidden:YES];
    if (!self.noRefresh) {
        [self loadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)assistedSetup
{
    self.title = @"详情";
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.delegate = self;
    self.currentPage = 1;
    self.goType = 5;
    self.pagesize = 100;
    self.collectionType = 0;
    self.bottomPraiseType = 1;
    
    [self createTextFieldZheGaiView];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    if ([self.delegate respondsToSelector:@selector(detailViewController:bottomTextField:)]) {
        [self.delegate detailViewController:self bottomTextField:self.bottomTextField];
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self loadDataNeedsRefresh];
}

- (void)loadDataNeedsRefresh {
    if (self.goType == 1) {
        self.currentPage = 1;
        self.pagesize++;
    }
    if (self.goType == 3) {
        self.currentPage = 1;
    }
    [self requestDetailsNet];
}

- (void)clearDataNeedsRefresh {
    self.contentOffsetrequestQ = self.scrollView.contentOffset;
    self.height = 0.0;
    [self.contentView removeFromSuperview];
    self.contentView = nil;
    if (self.reply_id) {
        self.reply_id = nil;
    }
}

- (void)loadingMore
{
    self.goType = 2;
    if (self.currentPage == 1) {
        self.currentPage ++;
    }
    [self requestDetailsNet];
}

- (void)requestDetailsNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/InformationAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0] , @"artid":self.artid};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *datas = [responseObject objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]] || !datas) {
            datas = @[];
        }
        for (NSDictionary *dict in datas) {
            int taskId = [[dict objectForKey:@"taskId"] intValue];
            if (taskId == 2656) {
                self.artDict = [[dict objectForKey:@"rows"] firstObject];
            }
            if (taskId == 2657) {
                self.praiseAvatars = [dict objectForKey:@"rows"];
            }
            if (taskId == 2658) {
                self.praiseNumDict = [[dict objectForKey:@"rows"] firstObject];
            }
        }
        self.datas = [datas mutableCopy];
        [self requestCommentNet];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (void)requestCommentNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/InformationAction.do"];
    NSDictionary *parameters = @{
                                 @"type":[NSString stringWithFormat:@"%d", 1],
                                 @"artid":self.artid,
                                 @"page": [NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": [NSString stringWithFormat:@"%d", self.pagesize]
                                };
//    NSLog(@"currentPagecurrentPage:%d", self.currentPage);
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *comments = [responseObject objectForKey:@"data"];
        if ([comments isEqual:[NSNull null]] || !comments.count) { // 为空时
            self.isNewRemark = NO;
            comments = @[];
        } else {
            self.isNewRemark = YES;
            comments = [self numberOfFloors:comments]; // 添加楼层显示数
        }
        
        if (self.currentPage == 1) {
            self.comments = [NSMutableArray arrayWithArray:comments];
        } else {
            self.comments = [[self.comments arrayByAddingObjectsFromArray:comments] mutableCopy];
        }

        [self endHeaderRefresh];
        [self endFooterRefresh];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self endHeaderRefresh];
        [self endFooterRefresh];
    }];
}

- (void)requestReplyPost:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsArtReplyAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *msg = responseObject[@"msg"];
        if ([msg containsString:@"未登录"]) {
            if (!self.reply_id) {
                self.goType = 1;
            } else {
                self.goType = 3;
            }
            [self goLogining];
        } else {
            [MBProgressHUD ZHMShowSuccess:@"评论成功"];
            [self loadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
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

//BbsArtgdAction.do
- (void)requestPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsArtgdAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"error"] containsString:@"未登录"]) {
            self.goType = 4;
            [self goLogining];
        } else if ([responseObject[@"error"] intValue] == 201) { // 去刷新重新请求
            UILabel *likeLabel = [self.likeViewSubViews objectForKey:@"likeLabel"];
            likeLabel.text = [NSString stringWithFormat:@"%d", [likeLabel.text intValue] + 1];
            UIImageView *likeImgView = [self.likeViewSubViews objectForKey:@"likeImgView"];
            likeImgView.image = [UIImage imageNamed:@"bbs_like_red"];
        } else if ([responseObject[@"error"] intValue] == 333) {
            UIImageView *likeImgView = [self.likeViewSubViews objectForKey:@"likeImgView"];
            likeImgView.image = [UIImage imageNamed:@"bbs_like_red"];
            [MBProgressHUD ZHMShowError:@"您已经点过赞了"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestBottomPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsArtgdAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSString *msg = responseObject[@"msg"];
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
            [self loadData];
        } else {
            [MBProgressHUD ZHMShowSuccess:@"取消点赞成功"];
            self.praiseBtn.selected = NO;
            self.bottomPraiseType = 2; // 之前没点赞，之后要去点赞
            [self loadData];
        }
//        [self bottomPraiseBtnSetup];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestCollection:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsfavoritesAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSString *msg = responseObject[@"msg"];
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
        //        [self endHeaderRefresh];
    }];
}

- (void)creatDetailsView
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 700)];
    
    UILabel *newsTitleLabel = [[UILabel alloc] init];
    newsTitleLabel.numberOfLines = 0;
    newsTitleLabel.font = [UIFont systemFontOfSize:18];
    newsTitleLabel.textColor = kXCTITLECOLOR;
    [self.contentView addSubview:newsTitleLabel];
  
    UILabel *publishDateLabel = [[UILabel alloc] init];
    publishDateLabel.numberOfLines = 1;
    publishDateLabel.font = [UIFont systemFontOfSize:10];
    publishDateLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    [self.contentView addSubview:publishDateLabel];
    
    UILabel *reprintFromLabel = [[UILabel alloc] init];
    reprintFromLabel.numberOfLines = 1;
    reprintFromLabel.font = [UIFont systemFontOfSize:10];
    reprintFromLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    [self.contentView addSubview:reprintFromLabel];
    
    UIWebView *newsTitleView = [[UIWebView alloc] init];
    newsTitleView.dataDetectorTypes = UIDataDetectorTypeNone;
    newsTitleView.delegate = self;
    newsTitleView.scrollView.scrollEnabled = NO;
    [self.contentView addSubview:newsTitleView];
    self.newsTitleView = newsTitleView;
    
    UILabel *admiredView = [[UILabel alloc] init];
    admiredView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:admiredView];
    UILabel *newsRemarksView = [[UILabel alloc] init];
    [self.contentView addSubview:newsRemarksView];
    
    NSString *yart_title = self.artDict[@"art_title"];
    NSString *art_title = [yart_title stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    NSString *ySubtitle = self.artDict[@"subtitle"];
     NSString *subtitle = [ySubtitle stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    newsTitleLabel.text = art_title.length ?  art_title : subtitle;
    publishDateLabel.text = [XCZTimeTools formateDatePicture:self.artDict[@"create_time"] withFormate:@"YYYY-MM-dd HH:mm:ss"];
    reprintFromLabel.text = self.artDict[@"art_origin"];

    CGSize newsTitleLabelSize = [newsTitleLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : newsTitleLabel.font} context:nil].size;
    newsTitleLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, XCZNewDetailRemarkRowMarginY, newsTitleLabelSize.width, newsTitleLabelSize.height);
    self.height += newsTitleLabel.bounds.size.height + XCZNewDetailRemarkRowMarginY;

    CGSize publishDateLabelSize = [publishDateLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX) * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : publishDateLabel.font} context:nil].size;
    publishDateLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, publishDateLabelSize.width, publishDateLabelSize.height);

    CGSize reprintFromLabelSize = [reprintFromLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX) * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : reprintFromLabel.font} context:nil].size;
    reprintFromLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2 + CGRectGetMaxX(publishDateLabel.frame), self.height + XCZNewDetailRemarkRowMarginY, reprintFromLabelSize.width, reprintFromLabelSize.height);
    self.height += publishDateLabelSize.height + XCZNewDetailRemarkRowMarginY;
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
    
    NSString *content = [self escapeHTMLString:self.artDict[@"art_content"]];
    NSString *repWidthStr = [NSString stringWithFormat:@"<img width=%f left=%f ", self.contentView.bounds.size.width - 32, 16.0];
    content = [content stringByReplacingOccurrencesOfString:@"<img " withString: repWidthStr];
    
    [newsTitleView loadHTMLString:content baseURL:nil];
    newsTitleView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, 1);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    CGSize fittingSize;
    if (![self.artDict[@"art_content"] length]) {
        fittingSize.height = 0.0;
    } else {
        fittingSize = [webView sizeThatFits:CGSizeZero];
        self.height += fittingSize.height + XCZNewDetailRemarkRowMarginY;
    }

    frame.size.height = fittingSize.height;
    frame.size.width = self.view.bounds.size.width - 16;
    frame.origin.x = 8;
    webView.frame = frame;
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.background='#EEEEEE'"]; //页面背景色
    
    [self setupOutFrame];
    [self setupSurplusView]; // webView加载完毕之后再加载下面的控件
}

/**
 *  webView加载完毕之后再加载下面的控件
 */
- (void)setupSurplusView
{
    UILabel *newsTitleRemarkLabel = [[UILabel alloc] init];
    newsTitleRemarkLabel.text = @"本文来自互联网, 不代表修车仔观点。";
    newsTitleRemarkLabel.font = [UIFont systemFontOfSize:10];
    newsTitleRemarkLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    CGSize newsTitleRemarkLabelSize = [newsTitleRemarkLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : newsTitleRemarkLabel.font} context:nil].size;
    newsTitleRemarkLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, newsTitleRemarkLabelSize.height);
    self.height += newsTitleRemarkLabelSize.height + XCZNewDetailRemarkRowMarginY;
    [self.contentView addSubview:newsTitleRemarkLabel];
    [self setupOutFrame];
    
    // 点赞部分
    int admiredPersonsCount = [[self.praiseNumDict objectForKey:@"num"] intValue];
    if (admiredPersonsCount > 0) {
        CGFloat admiredPersonsIconViewW = (self.contentView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX) * 0.08;
        UITableViewCell *admiredPersonsView = [[UITableViewCell alloc] init];
        admiredPersonsView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, admiredPersonsIconViewW + XCZNewDetailRemarkRowMarginX * 2);
        admiredPersonsView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        admiredPersonsView.layer.cornerRadius = 5.0;
        admiredPersonsView.backgroundColor = [UIColor whiteColor];
        self.height += admiredPersonsView.bounds.size.height + XCZNewDetailRemarkRowMarginY;
        [self.contentView addSubview:admiredPersonsView];
        
        if (admiredPersonsCount > 6) {
            admiredPersonsCount = 6;
        }
        
        CGFloat admiredPersonsIconViewH = admiredPersonsIconViewW;
        CGFloat admiredPersonsIconViewY = (admiredPersonsView.bounds.size.height - admiredPersonsIconViewW) * 0.5;
        for (int i = 0; i<admiredPersonsCount; i++) {
            UIImageView *admiredPersonsIconView = [[UIImageView alloc] init];
            CGFloat admiredPersonsIconViewX = XCZNewDetailRemarkRowMarginX + (admiredPersonsIconViewW + XCZNewDetailRemarkRowMarginX) * i;
            admiredPersonsIconView.frame = CGRectMake(admiredPersonsIconViewX, admiredPersonsIconViewY, admiredPersonsIconViewW, admiredPersonsIconViewH);
            admiredPersonsIconView.layer.cornerRadius = admiredPersonsIconViewH * 0.5;
            admiredPersonsIconView.layer.masksToBounds = YES;
            NSDictionary *dict = self.praiseAvatars[i];
            NSString *urlStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig imgBaseURL], dict[@"avatar"]];
            [admiredPersonsIconView sd_setImageWithURL:[NSURL URLWithString:urlStr] placeholderImage:[UIImage imageNamed:@"bbs_xiuchezhaiIcon"]];
            [admiredPersonsView addSubview:admiredPersonsIconView];
        }
        
        UILabel *numberLabel = [[UILabel alloc] init];
        numberLabel.text = [NSString stringWithFormat:@"%@人点赞", self.praiseNumDict[@"num"]];
        numberLabel.font = [UIFont systemFontOfSize:10];
        numberLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
        numberLabel.textAlignment = NSTextAlignmentRight;
        CGFloat numberLabelX = XCZNewDetailRemarkRowMarginX + (admiredPersonsIconViewW + XCZNewDetailRemarkRowMarginX) * admiredPersonsCount;
        CGFloat numberLabelW = admiredPersonsView.bounds.size.width - 23 - numberLabelX;
        CGSize numberLabelSize = [numberLabel.text boundingRectWithSize:CGSizeMake(numberLabelW, 33) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : numberLabel.font} context:nil].size;
        CGFloat numberLabelH = numberLabelSize.height;
        CGFloat numberLabelY = (admiredPersonsView.bounds.size.height - numberLabelH) * 0.5;
        numberLabel.frame = CGRectMake(numberLabelX, numberLabelY, numberLabelW, numberLabelH);
        [admiredPersonsView addSubview:numberLabel];
        [admiredPersonsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(admiredPersonsViewDidClick)]];
    }
    [self setupOutFrame];
    [self createCommentsView];
    [self setupScrollViewContentOffset];
}

- (void)createCommentsView
{
    // 评论部分
    if (self.comments.count) {
        UIView *remarkView = [[UIView alloc] init];
        remarkView.userInteractionEnabled = YES;
        remarkView.frame = CGRectMake(0, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width, 500);
        [self.contentView addSubview:remarkView];
        self.remarkView = remarkView;
        
        UILabel *commentsLabel = [[UILabel alloc] init];
        commentsLabel.text = @"评论";
        commentsLabel.font = [UIFont systemFontOfSize:16];
        commentsLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
        CGSize commentsLabelSize = [commentsLabel.text boundingRectWithSize:CGSizeMake(remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 30) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : commentsLabel.font} context:nil].size;
        commentsLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, 0, remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, commentsLabelSize.height);
        self.remarkHeight = commentsLabelSize.height;
        [remarkView addSubview:commentsLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginX, commentsLabelSize.height + XCZNewDetailRemarkRowMarginY, remarkView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 1.0)];
        lineView.backgroundColor = [UIColor colorWithRed:211/255.0 green:211/255.0 blue:211/255.0 alpha:1.0];
        self.remarkHeight += lineView.bounds.size.height;
        [remarkView addSubview:lineView];
        [self creatMoreCommentView];
    }
}

- (void)creatMoreCommentView
{
    for (NSDictionary *remark in self.comments) {
        XCZNewDetailRemarkRow *remarkRow = [[XCZNewDetailRemarkRow alloc] init];
        remarkRow.fatherWidth = self.remarkView.bounds.size.width;
        remarkRow.remark = remark;
        CGFloat remarkRowY = self.remarkHeight + XCZNewDetailRemarkRowMarginY;
        remarkRow.frame = CGRectMake(0, remarkRowY, self.remarkView.bounds.size.width, remarkRow.height);
        self.remarkHeight += remarkRow.height;
        remarkRow.delegate = self;
        [self.remarkView addSubview:remarkRow];
    }
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

- (void)setupScrollViewContentOffset
{
    if (self.goType == 1) {
        CGFloat offsetH = self.scrollView.contentSize.height - self.scrollView.bounds.size.height + 35;
        if (offsetH > 0)
        {
            [self.scrollView setContentOffset:CGPointMake(0, offsetH) animated:YES];
        }
    } else if (self.goType == 2) {
        CGFloat offsetH = self.scrollView.contentSize.height - self.scrollView.bounds.size.height + 35;
        if (offsetH > 0)
        {
            [self.scrollView setContentOffset:CGPointMake(0, offsetH) animated:NO];
        }
        
    } else if (self.goType == 3) {
        CGFloat offsetH = self.typeThreeOffset.y;
        [self.scrollView setContentOffset:CGPointMake(0, offsetH)  animated:YES];
    } else if (self.goType == 5) {
        
    } else {
        [self.scrollView setContentOffset:self.contentOffsetrequestQ animated:YES];
    }
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
        [self changeImage:[imageStrs substringFromIndex:(range.location + 1)] andImageArray:imageArray];
    } else {
        [imageArray addObject:imageStrs];
    }
    return imageArray;
}

/**
 *  处理html
 */
- (NSString *)escapeHTMLString:(NSString *)html {
    // !!!!!!!!!!!!!!!!!!!!!!!
    html = [html stringByReplacingOccurrencesOfString:@"＜" withString:@"<"];
    html = [html stringByReplacingOccurrencesOfString:@"＞" withString:@">"];
    html = [html stringByReplacingOccurrencesOfString:@"#3D;" withString:@"="];
    html = [html stringByReplacingOccurrencesOfString:@"#quot;" withString:@"\""];
    html = [html stringByReplacingOccurrencesOfString:@"<br/>" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"href=" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"#apos;" withString:@"'"];

    return html;
}

- (NSArray *)numberOfFloors:(NSArray *)comments
{
    NSMutableArray *newComment = [NSMutableArray array];
    for (NSDictionary *comment in comments) {
        NSMutableDictionary *commentMutableDict = [comment mutableCopy];
        long long floor = [[commentMutableDict objectForKey:@"floor"] longLongValue];
    
        NSString *title;
        if (floor == 1) {
            title = @"沙发";
            [commentMutableDict setObject:title forKey:@"floor"];
        } else if (floor == 2) {
            title = @"板凳";
            [commentMutableDict setObject:title forKey:@"floor"];
        } else if (floor == 3) {
            title = @"地板";
            [commentMutableDict setObject:title forKey:@"floor"];
        }
        [newComment addObject:commentMutableDict];
    }
    return newComment;
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

- (void)goNewUserListVC
{
    XCZNewsUserListViewController *newsUserListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsUserListViewController"];
    newsUserListVC.artid = self.artid;
    [self.navigationController pushViewController:newsUserListVC animated:YES];
}

#pragma mark - 监听事件
- (void)textFieldZheGaiViewDidClick:(UIGestureRecognizer *)grz
{
    self.goType = 8;
    [self requestLoginDetection];
}

- (void)admiredPersonsViewDidClick
{
    [self goNewUserListVC];
}

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

/**
 *  查看更多评论按钮被点击代理方法
 */
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow detailsRemarkRowDidClick:(UIButton *)moreBtn
{
    self.noRefresh = YES;
    NSString *reply_id = detailRemarkRow.remark[@"reply_id"];
    XCZNewDetailALayerViewController *newDetailALayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewDetailALayerViewController"];
    newDetailALayerVC.artid = self.artid;
    newDetailALayerVC.art_cateid = self.artDict[@"art_cateid"];
    newDetailALayerVC.floor = detailRemarkRow.remark[@"floor"];
    newDetailALayerVC.reply_id = reply_id;
    [self.navigationController pushViewController:newDetailALayerVC animated:YES];
}

/**
 *  评论的用户部分被点击代理方法
 */
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id
{
    self.noRefresh = YES;
    [self jumpToPersonInfoVC:bbs_user_id];
}

/**
 *  评论的被评论用户被点击代理方法
 */
- (void)detailRemarkRowReplyView:(XCZNewDetailRemarkRowReplyView *)detailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id
{
    self.noRefresh = YES;
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailALayerRow likeViewDidClick:(NSDictionary *)likeViewSubViews{
    self.reply_id = detailALayerRow.remark[@"reply_id"];
    self.publisher_id = detailALayerRow.remark[@"user_id"];
    self.likeViewSubViews = likeViewSubViews;
    self.goType = 4;
    [self requestLoginDetection];
}

/**
 *  评论回复被点击
 */
- (void)detailRemarkRow:(XCZNewDetailRemarkRow *)detailRemarkRow replyViewDidClick:(UIView *)replyView
{
    self.reply_id = detailRemarkRow.remark[@"reply_id"];
    [self.bottomTextField becomeFirstResponder];
}

- (IBAction)shareBtnDidClick:(UIButton *)sender {
    
    NSString *art_title = self.artDict[@"art_title"];
    if (art_title.length > 30) {
        art_title = [art_title substringToIndex:30];
    }
    NSString *subtitle = self.artDict[@"subtitle"];
    if (subtitle.length > 100) {
        subtitle = [subtitle substringToIndex:100];
    }
    art_title = [art_title stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    subtitle = [subtitle stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    NSString *pageStr = [NSString stringWithFormat:@"/bbs/detail/index.html?type=info&&post_id=%@", self.artid];
    NSString *webpageUrl = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL],pageStr];
    [self shareMessage:@{@"title": art_title, @"description": subtitle, @"thumbImage": [UIImage imageNamed:@"bbs_pro_pic.jpg"], @"webpageUrl":webpageUrl}];
}

/**
 *  跳转到XCZPersonInfoViewController
 */
- (void)jumpToPersonInfoVC:(NSString *)bbs_user_id
{
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
}

#pragma mark - XCZNewDetailWriteViewDelegate
- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
{
    self.noRefresh = YES;
    [self.view endEditing:YES];
}

- (void)newDetailWriteView:(XCZNewDetailWriteView *)XCZNewDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (text.length) {
        [self.view endEditing:YES];
        self.postContentText = text;
        if (!self.reply_id) {
            self.goType = 1;
        } else {
            self.goType = 3;
            self.typeThreeOffset =  self.scrollView.contentOffset;
        }
        [self requestLoginDetection];
    } else {
        [MBProgressHUD ZHMShowError:@"说点再发送吧"];
    }
}

#pragma mark - 通知方法
- (void)keyboardWillShowNot:(NSNotification *)notification
{
    XCZNewDetailWriteView *writeView = [[XCZNewDetailWriteView alloc] init];
    writeView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    [writeView.commentTextView becomeFirstResponder];
    writeView.delegate = self;
    [self.view addSubview:writeView];
    self.writeView = writeView;
}

- (void)keyboardWillHideNot:(NSNotification *)notification
{
    [self.writeView removeFromSuperview];
    self.writeView = nil;
    [self createTextFieldZheGaiView];
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
        indicatorHeaderView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
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
        indicatorFooterView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        indicatorFooterView.hidden = NO;
        [scrollView addSubview:indicatorFooterView];
        self.indicatorFooterView = indicatorFooterView;
    }
}

- (void)startHeaderRefresh:(UIScrollView *)scrollView
{
    self.goType = 5;
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
    if (self.scrollView.contentOffset.y <= 0) {
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
}

- (void)endFooterRefresh
{
    [self removeIndicatorFooterView];
}

- (void)stopHeaderScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    offset.y = -64;
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
    
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
        if (bottomY > 75) {
//            NSLog(@"上拉加载更多");
            [self morePullUpRefreshControl:scrollView];
            [self stopFooterScroll:scrollView];
            [self startFooterRefresh:scrollView];
        }
    }
}




@end















