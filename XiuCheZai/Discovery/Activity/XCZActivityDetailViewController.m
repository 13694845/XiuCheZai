//
//  XCZCircleDetailViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/9.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZActivityDetailViewController.h"
#import "XCZCircleDetailRemarkRow.h"
#import "DiscoveryConfig.h"
#import "XCZConfig.h"
#import "UIImageView+WebCache.h"
#import "XCZNewsUserListViewController.h"
#import "XCZCircleUserBrandsView.h"
#import "XCZCircleDetailGoodsView.h"
#import "XCZPersonInfoViewController.h"
#import "XCZCircleDetailALayerViewController.h"
#import "XCZCircleDetailWriteView.h"
#import "XCZPersonWebViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZTimeTools.h"
#import "XCZCircleUserListViewController.h"

@interface XCZActivityDetailViewController ()<UIWebViewDelegate, XCZCircleDetailRemarkRowDelegate, XCZCircleDetailWriteViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *remarkView;
@property (nonatomic, weak) UILabel *publishDateLabel;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat remarkHeight;
@property (nonatomic, weak) XCZCircleDetailRemarkRow *previousRemarkRow;
@property (nonatomic, strong) NSMutableArray *datas; // 主界面数据(处理前数据)
@property (nonatomic, strong) NSMutableArray *comments; // 评论数据(处理前数据)
@property (nonatomic, strong) NSDictionary *artDict; // 主界面主数据
@property (nonatomic, strong) NSDictionary *praiseNumDict; // 主界面点赞数
@property (nonatomic, strong) NSMutableArray *praiseAvatars; // 主界面头像
@property (assign, nonatomic) int zan; // 是否已经点过赞了
@property (assign, nonatomic) int currentPage;
@property (assign, nonatomic) int pagesize;

@property (nonatomic, copy) NSString *tieziUser_id;
@property (nonatomic, copy) NSString *reply_id;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) int goType; // 0:为主帖去点赞，1为主帖评论, 2为下拉加载更多, 3为回复评论, 4为根贴点赞, 5为上拉刷新 6收藏 7底部点赞 8删除本帖按钮被点击
@property (nonatomic, copy) NSString *postContentText; // 发出的内容
@property (assign, nonatomic) CGPoint contentOffsetrequestQ; // 请求数据前contentOffset
@property (assign, nonatomic) int collectionType; // 收藏类型:0:刚登录后, 1:去收藏, 2:取消收藏
@property (assign, nonatomic) int praiseType; // 回帖点赞类型:0:去点赞, 1:取消点赞
@property (assign, nonatomic) int bottomPraiseType; // 底部点赞类型:0:去点赞, 1:取消点赞
@property (nonatomic, weak) UIWebView *newsTitleView;
@property (nonatomic, strong) NSArray *share_images;
@property (nonatomic, strong) NSDictionary *likeViewSubViews;

@property (nonatomic, weak) UIImageView *oneImageView; // 第一张图片View

@property (nonatomic, weak) UIActivityIndicatorView *indicatorHeaderView;
@property (nonatomic, weak) UIActivityIndicatorView *indicatorFooterView;
@property (nonatomic, weak) XCZCircleDetailWriteView *writeView;
@property (nonatomic, copy) NSString *publisher_id;

@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *praiseBtn;

@end

@implementation XCZActivityDetailViewController

@synthesize datas = _datas;
@synthesize comments = _comments;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    if (self.goType == 0) {
    } else if (self.goType == 1) {
        NSDictionary *dict = @{
                               @"type" : @"1",
                               @"post_id" : self.artDict[@"post_id"],
                               @"forum_id" : self.artDict[@"forum_id"],
                               @"reply_content" : self.postContentText,
                               @"is_anony" : @"0",
                               };
       loginStatu ? [self goLogining] : [self requestReplyPost:dict];
    } else if (self.goType == 3) {
        NSDictionary *dict = @{
                               @"type" : @"2",
                               @"post_id" : self.artDict[@"post_id"],
                               @"forum_id" : self.artDict[@"forum_id"],
                               @"reply_content" : self.postContentText,
                               @"reply_id" : self.reply_id,
                               @"is_anony" : @"0",
                               };
       loginStatu ? [self goLogining] : [self requestReplyPost:dict];
    } else if (self.goType == 4) {
        NSDictionary *dict = @{
                               @"type" : @"0",
                               @"posts_clazz" : @"2",
                               @"post_id" : self.reply_id,
                               @"host" : self.publisher_id
                               };
       loginStatu ? [self goLogining] : [self requestPraise:dict];
    } else if (self.goType == 6) { // 收藏按钮被点击
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.collectionType],
                               @"post_id" : self.post_id,
                               @"fav_cate" : @"1",
                               };
        loginStatu ? [self goLogining] : [self requestCollection:dict];
    } else if (self.goType == 7) { // 底部点赞按钮被点击
        NSDictionary *dict = @{
                               @"type" : [NSString stringWithFormat:@"%d", self.bottomPraiseType],
                               @"posts_clazz" : @"1",
                               @"post_id" : self.post_id,
                               @"host" : self.tieziUser_id
                               };
        loginStatu ? [self goLogining] : [self requestBottomPraise:dict];
    } else if (self.goType == 8) { // 删除按钮被点击
        loginStatu ? [self goLogining] : [self alertShowIsDeleted];
    }
}

- (void)setTieziUser_id:(NSString *)tieziUser_id
{
    _tieziUser_id = [tieziUser_id copy];
    [self createCommentsView];
}

- (NSArray *)share_images
{
    if (!_share_images) {
        _share_images = [NSArray array];
    }
    return _share_images;
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

- (void)setZan:(int)zan
{
    _zan = zan;
}

- (void)setDatas:(NSMutableArray *)datas
{
    _datas = datas;
    
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
    
//    NSLog(@"commentscomments:%@", comments);
    NSDictionary *collectionDict = @{
                                     @"type" : [NSString stringWithFormat:@"%d", 0],
                                     @"post_id" : self.post_id,
                                     @"fav_cate" : @"1",
                                     };
    [self requestCollection:collectionDict];
//
//    NSDictionary *bottomPraiseDict = @{
//                                       @"type" : @"1",
//                                       @"gd_type" : @"1",
//                                       @"gd_clazz" : @"1",
//                                       @"publisher_id" : @"0",
//                                       @"artid": self.artid,
//                                       };
//    [self requestBottomPraise:bottomPraiseDict];
    
//    NSLog(@"setCommentssetCommentssetComments");
    
    [self creatDetailsView];
    self.currentPage ++;
    if (self.goType == 5) {
        self.pagesize = 10;
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
    
    [self loadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assistedSetup
{
    self.title = @"详情";
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.currentPage = 1;
    self.goType = 5;
    self.pagesize = 10;
    self.collectionType = 0;
    self.praiseType = 0;
    self.bottomPraiseType = 0;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
    if ([self.delegate respondsToSelector:@selector(detailViewController:bottomTextField:)]) {
        [self.delegate detailViewController:self bottomTextField:self.bottomTextField];
    }
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
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
    [self loadData];
}

- (void)requestDetailsNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0] , @"post_id":self.post_id};
    
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *datas = [responseObject objectForKey:@"data"];
        if ([datas isEqual:[NSNull null]]) {
            datas = nil;
        }
        for (NSDictionary *dict in datas) {
            int taskId = [[dict objectForKey:@"taskId"] intValue];
            if (taskId == 2644) {
                self.artDict = [[dict objectForKey:@"rows"] firstObject];
            }
            if (taskId == 2645) {
                self.praiseAvatars = [dict objectForKey:@"rows"];
            }
            if (taskId == 2646) {
                self.praiseNumDict = [[dict objectForKey:@"rows"] firstObject];
            }
            if (taskId == 2620) {
                self.zan = [[[[dict objectForKey:@"rows"] firstObject] objectForKey:@"zan"] intValue];
                if (self.zan) {
                    self.praiseBtn.selected = YES;
                    self.bottomPraiseType = 1;
                } else {
                    self.praiseBtn.selected = NO;
                    self.bottomPraiseType = 0;
                }
            }
        }
         self.datas = [datas mutableCopy];
        [self requestCommentNet]; // 评论接口
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

//
- (void)requestCommentNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{
                                 @"type":[NSString stringWithFormat:@"%d", 1] ,
                                 @"post_id":self.post_id,
                                 @"page": [NSString stringWithFormat:@"%d", self.currentPage],
                                 @"pagesize": [NSString stringWithFormat:@"%d", 10]
                                 };
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *comments = [responseObject objectForKey:@"data"];
        comments = ([comments isEqual:[NSNull null]] || !comments) ? @[] : [self numberOfFloors:comments];
        if (self.currentPage == 1) {
            self.comments = [NSMutableArray arrayWithArray:comments];
        } else {
            self.comments = [[self.comments arrayByAddingObjectsFromArray:comments] mutableCopy];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}
//@"host" : self.tieziUser_id
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
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestBottomPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/DianZanAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"error"] containsString:@"未登录"]) {
            self.goType = 4;
            [self goLogining];
        } else if ([responseObject[@"error"] intValue] == 201) {
            self.praiseBtn.selected = YES;
            [MBProgressHUD ZHMShowSuccess:@"操作成功!"];
            [self loadData];
        } else if ([responseObject[@"error"] intValue] == 333) {
            [MBProgressHUD ZHMShowError:@"您已经点过赞了"];
        }
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
        if ([dict[@"type"] intValue] == 0) {
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

- (void)alertShowIsDeleted
{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除本帖?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self requestDelegateSelf];
    }];
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)requestDelegateSelf
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/SendPostAction.do"];
    NSDictionary *parameters = @{@"type" : @"2", @"post_id": self.post_id, @"delete_reason":@"", @"forum_id": self.artDict[@"forum_id"]};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        [MBProgressHUD ZHMShowSuccess:@"删除成功"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"XCZCircleDetailViewControllerHasDelectedToXCZCircleViewControllerNot" object:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.navigationController popToRootViewControllerAnimated:YES];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestZZUser_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/NJsonDispatcher.do"];
    NSDictionary *parameters = @{
                                 @"post_id":self.post_id,
                                 @"taskId": @"2665"
                                 };
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *tieziUser_id = [[[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"] firstObject] objectForKey:@"user_id"];
        self.tieziUser_id = tieziUser_id;
        [self requestGetUID:tieziUser_id];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestGetUID:(NSString *)tieziUser_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSDictionary *parameters = @{@"type" : @"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *loginUser_id = [[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"user"] objectForKey:@"user_id"];
        if ([loginUser_id isEqualToString:tieziUser_id]) {
            [self createDelegate]; // 显示删除按钮
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)creatDetailsView
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, self.scrollView.bounds.size.height)];
    [self.scrollView addSubview:self.contentView];
    
        XCZCircleUserBrandsView *userBrandsView = [[XCZCircleUserBrandsView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, 58)];
        userBrandsView.artDict = self.artDict;
        userBrandsView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:userBrandsView];
        self.height = 58;
    [userBrandsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userBrandsViewDidClick)]];
    
    [self createTopicLabel];
    [self createDatePublishRow]; // 创建时间这行
    [self createTextContentView]; // 创建正文内容
    self.scrollView.contentSize = self.contentView.bounds.size;
}

- (void)createTopicLabel
{
//        NSLog(@"artDictartDict:%@", self.artDict[@"topic"]);
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.text = self.artDict[@"topic"];
    topicLabel.textColor = [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0];
    topicLabel.font = [UIFont systemFontOfSize:18];
    CGSize topicLabelSize = [topicLabel.text boundingRectWithSize:CGSizeMake(self.contentView.bounds.size.width - 16, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : topicLabel.font} context:nil].size;
    topicLabel.frame = CGRectMake(16, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 16, topicLabelSize.height);
    [self.contentView addSubview:topicLabel];
    self.height += topicLabel.bounds.size.height + XCZNewDetailRemarkRowMarginY;
}

- (void)createDatePublishRow
{
    UILabel *publishDateLabel = [[UILabel alloc] init];
    publishDateLabel.text = [XCZTimeTools formateDatePicture:[XCZTimeTools timeWithTimeIntervalString:self.artDict[@"create_time"]] withFormate:@"YYYY-MM-dd HH:mm:ss"];
    
    publishDateLabel.numberOfLines = 1;
    publishDateLabel.font = [UIFont systemFontOfSize:10];
    publishDateLabel.textColor = kXCTIMEANDAUXILIARYTEXTCOLOR;
    [self.contentView addSubview:publishDateLabel];
    CGSize publishDateLabelSize = [publishDateLabel.text boundingRectWithSize:CGSizeMake((self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX) * 0.5, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : publishDateLabel.font} context:nil].size;
    publishDateLabel.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, publishDateLabelSize.width, publishDateLabelSize.height);
    self.publishDateLabel = publishDateLabel;
    self.height += publishDateLabelSize.height + XCZNewDetailRemarkRowMarginY;
}

- (void)createDelegate
{
    UIButton *delectedselfBtn = [[UIButton alloc] init];
    delectedselfBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [delectedselfBtn setTitle:@"删除本帖" forState:UIControlStateNormal];
    [delectedselfBtn setTitleColor:[UIColor colorWithRed:53/255.0 green:82/255.0 blue:172/255.0 alpha:1.0] forState:UIControlStateNormal];
    CGSize delectedselfBtnSize = [delectedselfBtn.titleLabel.text boundingRectWithSize:CGSizeMake(self.view.bounds.size.width * 0.5, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : delectedselfBtn.titleLabel.font} context:nil].size;
    CGFloat delectedselfBtnX = self.view.bounds.size.width - XCZNewDetailRemarkRowMarginX - delectedselfBtnSize.width;
    CGFloat delectedselfBtnY = self.publishDateLabel.frame.origin.y;
    delectedselfBtn.frame = CGRectMake(delectedselfBtnX, delectedselfBtnY, delectedselfBtnSize.width, delectedselfBtnSize.height);
    [self.contentView addSubview:delectedselfBtn];
    
    [delectedselfBtn addTarget:self action:@selector(delectedselfBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createTextContentView
{
    UIWebView *newsTitleView = [[UIWebView alloc] init];
    newsTitleView.delegate = self;
    newsTitleView.scrollView.scrollEnabled = NO;
    [self.contentView addSubview:newsTitleView];
    self.newsTitleView = newsTitleView;
    
    UILabel *admiredView = [[UILabel alloc] init];
    admiredView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:admiredView];
    UILabel *newsRemarksView = [[UILabel alloc] init];
    [self.contentView addSubview:newsRemarksView];
    [newsTitleView loadHTMLString:[self escapeHTMLString:self.artDict[@"content"]] baseURL:nil];
    newsTitleView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 4 * XCZNewDetailRemarkRowMarginX, 1);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CGRect frame = webView.frame;
    frame.size.height =1;
    webView.frame = frame;
    
    CGSize fittingSize;
    if (!(((NSString *)(self.artDict[@"content"])).length)) {
        fittingSize.height = 0.0;
    } else {
        fittingSize = [webView sizeThatFits:CGSizeZero];
        self.height += fittingSize.height + XCZNewDetailRemarkRowMarginY;
    }
    frame.size.height = fittingSize.height;
    frame.size.width = self.view.bounds.size.width - 16;
    frame.origin.x = 8;
    webView.frame = frame;
    
    [self setupOutFrame];
    [self setupImagesView]; // webView加载完毕后再加载下面的组件
}

- (void)setupImagesView
{
    NSMutableArray *share_images = [NSMutableArray array];
    self.share_images = [self changeImage:self.artDict[@"share_image"] andImageArray:share_images];
    
    __block UIImageView *previousImageView;
    __block int i = 0;
    for (NSString *imageYStr in share_images) {
        NSString *imageStr;
        if ([imageYStr containsString:@"http://"]) {
            imageStr = imageYStr;
        } else {
            imageStr = [NSString stringWithFormat:@"%@/%@", [XCZConfig textImgBaseURL], imageYStr];
        }
        UIImageView *imageView = [[UIImageView alloc] init];
        if (i == 0) {
            self.oneImageView = imageView;
        }
        [imageView sd_setImageWithURL:[NSURL URLWithString:imageStr] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            CGFloat imageViewX = 16;
            CGFloat imageViewW = self.contentView.bounds.size.width - 2 * imageViewX;
            CGFloat imageViewH = 0.0;
            if (image.size.width > imageViewW) {
                imageViewH = imageViewW * (image.size.height / image.size.width);
            } else {
                imageViewW = image.size.width;
                imageViewH = image.size.height;
                imageViewX = (self.contentView.bounds.size.width - imageViewW) * 0.5;
            }
            CGFloat imageViewY = self.height + 8;
            imageView.frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
            [self.contentView addSubview:imageView];
            
            previousImageView = imageView;
            self.height += imageViewH + 8;
            i++;
            if (i == share_images.count) {
                [self setupSurplusView]; // 加载下面的控件
            }
        }];
    }
}

- (void)setupSurplusView
{
    [self setupAdmiredView]; // 点赞及后面的View
    [self requestZZUser_id]; // 先查询当前帖子作者的user_id，之后再加载评论
//    [self createCommentsView]; // 评论部分
}

- (void)setupGoodsView
{
    XCZCircleDetailGoodsView *goodsView = [[XCZCircleDetailGoodsView alloc] initWithFrame:CGRectMake(XCZNewDetailRemarkRowMarginY * 2, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 32, 91)];
    goodsView.backgroundColor = [UIColor whiteColor];
    NSDictionary *goods_remark = [NSJSONSerialization JSONObjectWithData:[[self.artDict objectForKey:@"goods_remark"] dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
    goodsView.goods_remark = goods_remark;
    [self.contentView addSubview:goodsView];
    self.height += goodsView.bounds.size.height + XCZNewDetailRemarkRowMarginY;
}

- (void)showDateAdmiredCommentsView
{
    
}

- (void)setupAdmiredView
{
    int admiredPersonsCount = [[self.praiseNumDict objectForKey:@"num"] intValue];
    if (admiredPersonsCount > 0) {
        UITableViewCell *admiredPersonsView = [[UITableViewCell alloc] init];
        admiredPersonsView.frame = CGRectMake(XCZNewDetailRemarkRowMarginX, self.height + XCZNewDetailRemarkRowMarginY, self.contentView.bounds.size.width - 2 * XCZNewDetailRemarkRowMarginX, 50);
        admiredPersonsView.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        admiredPersonsView.layer.cornerRadius = 5.0;
        admiredPersonsView.backgroundColor = [UIColor whiteColor];
        self.height += admiredPersonsView.bounds.size.height + XCZNewDetailRemarkRowMarginY;
        [self.contentView addSubview:admiredPersonsView];
        
        if (admiredPersonsCount > 6) {
            admiredPersonsCount = 6;
        }
        CGFloat admiredPersonsIconViewW = 33;
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
        numberLabel.text = [NSString stringWithFormat:@"%@人点赞", [self.praiseNumDict objectForKey:@"num"]];
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
        XCZCircleDetailRemarkRow *remarkRow = [[XCZCircleDetailRemarkRow alloc] init];
        remarkRow.fatherWidth = self.remarkView.bounds.size.width;
        remarkRow.louzhuId = @"";
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

/**
 *  处理html
 */
- (NSString *)escapeHTMLString:(NSString *)html {
    // !!!!!!!!!!!!!!!!!!!!!!!
    html = [html stringByReplacingOccurrencesOfString:@"＜" withString:@"<"];
    html = [html stringByReplacingOccurrencesOfString:@"＞" withString:@">"];
    
    html = [html stringByReplacingOccurrencesOfString:@"#3D;" withString:@"="];
    html = [html stringByReplacingOccurrencesOfString:@"#quot;" withString:@"\""];
    html = [html stringByReplacingOccurrencesOfString:@"#0A;" withString:@"<br/>"];
    html = [html stringByReplacingOccurrencesOfString:@"#apos;" withString:@"'"];
    
    // NSLog(@"escapeHTMLString : %@", html);
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
    XCZCircleUserListViewController *circleUserListVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleUserListViewController"];
    circleUserListVC.post_id = self.post_id;
    [self.navigationController pushViewController:circleUserListVC animated:YES];
}

#pragma mark - 监听事件
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

- (void)delectedselfBtnDidClick:(UIButton *)delectedselfBtn
{
    self.goType = 8;
    [self requestLoginDetection]; // 监测登录
}

- (IBAction)shareBtnDidClick:(UIButton *)sender {
    
    NSString *title = self.artDict[@"topic"];
    NSString *content = self.artDict[@"content"];
    UIImage *thumbImage = [UIImage imageNamed:@"bbs_pro_pic.jpg"];
    if (title.length > 30) {
        title = [title substringToIndex:30];
    }
    if (content.length > 100) {
        content = [content substringToIndex:100];
    }
    
    NSString *pageStr = [NSString stringWithFormat:@"/bbs/detail/index.html?post_id=%@", self.post_id];
    NSString *webpageUrl = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL],pageStr];
    [self shareMessage:@{@"title": title, @"description": content, @"thumbImage": thumbImage, @"webpageUrl": webpageUrl}];
}

- (void)userBrandsViewDidClick
{
    if (self.tieziUser_id) {
        XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
            personInfoVC.bbs_user_id = self.tieziUser_id;
        [self.navigationController pushViewController:personInfoVC animated:YES];
    }
}

#pragma mark - 跳转控制器
/**
 *  跳转到XCZPersonInfoViewController
 */
- (void)jumpToPersonInfoVC:(NSString *)bbs_user_id
{
    XCZPersonInfoViewController *personInfoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonInfoViewController"];
    personInfoVC.bbs_user_id = bbs_user_id;
    [self.navigationController pushViewController:personInfoVC animated:YES];
}

#pragma mark - XCZCircleDetailRemarkRowDelegate
- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow detailsRemarkRowDidClick:(UIButton *)moreBtn
{
    NSString *reply_id = detailRemarkRow.remark[@"reply_id"];
    XCZCircleDetailALayerViewController *circleDetailALayerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailALayerViewController"];
    circleDetailALayerVC.post_id = self.post_id;
    circleDetailALayerVC.floor = detailRemarkRow.remark[@"floor"];
    circleDetailALayerVC.reply_id = reply_id;
    [self.navigationController pushViewController:circleDetailALayerVC animated:YES];
}

- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow iconPartViewDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailRemarkRowReplyView:(XCZCircleDetailRemarkRowReplyView *)detailRemarkRowReplyView nameDidClickWithUserId:(NSString *)bbs_user_id
{
    [self jumpToPersonInfoVC:bbs_user_id];
}

- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow likeViewDidClick:(NSDictionary *)likeViewSubViews
{
    self.reply_id = detailRemarkRow.remark[@"reply_id"];
    self.publisher_id = detailRemarkRow.remark[@"user_id"];
    self.likeViewSubViews = likeViewSubViews;
    self.goType = 4;
    [self requestLoginDetection];
}

- (void)detailRemarkRow:(XCZCircleDetailRemarkRow *)detailRemarkRow replyViewDidClick:(UIView *)replyView
{
    self.reply_id = detailRemarkRow.remark[@"reply_id"];
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
        if (!self.reply_id) {
            self.goType = 1;
        } else {
            self.goType = 3;
        }
        [self requestLoginDetection];
    } else {
        [MBProgressHUD ZHMShowError:@"说点再发送吧"];
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

#pragma mark - 通知方法
- (void)keyboardWillShowNot:(NSNotification *)notification
{
    XCZCircleDetailWriteView *writeView = [[XCZCircleDetailWriteView alloc] init];
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
        
        NSLog(@"下拉刷新");
        
        [self stopHeaderScroll:scrollView];
        [self startHeaderRefresh:scrollView];
    }
    
    if (scrollView.contentOffset.y > 0) { // 上拉加载更多
        CGFloat bottomY = (scrollView.contentOffset.y) - (scrollView.contentSize.height - scrollView.bounds.size.height);
        if (bottomY > 75) {
            NSLog(@"上拉加载更多");
            [self morePullUpRefreshControl:scrollView];
            [self stopFooterScroll:scrollView];
            [self startFooterRefresh:scrollView];
        }
    }
}



@end
