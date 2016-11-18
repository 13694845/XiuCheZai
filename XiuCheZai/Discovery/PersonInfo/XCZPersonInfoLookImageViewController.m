//
//  XCZPersonInfoLookImageViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/10/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonInfoLookImageViewController.h"
#import "XCZTimeTools.h"
#import "XCZPersonInfoLookImageView.h"
#import "XCZConfig.h"
#import "AFNetworking.h"
#import "MBProgressHUD+ZHM.h"
#import "DiscoveryConfig.h"
#import "XCZCircleDetailViewController.h"
#import "XCZCircleDetailWriteView.h"
#import "XCZPersonWebViewController.h"

@interface XCZPersonInfoLookImageViewController()<XCZPersonInfoLookImageViewDataSource, XCZPersonInfoLookImageViewDelegate, XCZCircleDetailWriteViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *navBackView;
@property (weak, nonatomic) IBOutlet UILabel *navTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *navNumLabel;
@property (weak, nonatomic) IBOutlet UIView *navMoreView;

@property (weak, nonatomic) IBOutlet UIView *pictureView;
@property (weak, nonatomic) XCZPersonInfoLookImageView *lookImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UITextField *bottomTextField;
@property (weak, nonatomic) UIView *textFieldZheGaiView;
@property (weak, nonatomic) IBOutlet UIView *bottomPraiseView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomPraiseIconView;
@property (weak, nonatomic) IBOutlet UILabel *bottomPraiseLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomDetailsView;
@property (nonatomic, weak) XCZCircleDetailWriteView *writeView;

@property (nonatomic, strong) NSArray *share_images;
@property (nonatomic, assign) int currentImageNum;
@property (nonatomic, weak) UIImage *currentImage;

@property (nonatomic, strong) NSDictionary *artDict; // 主界面主数据
@property (assign, nonatomic) int zan; // 是否已经点过赞了
@property (nonatomic, copy) NSString *postContentText; // 发出的内容
@property (assign, nonatomic) int goType; // 1:bottomTextField上遮盖被点击 2:点赞按钮被点击 3:发送按钮被点击 4:获取文章作者id
@property (nonatomic, copy) NSString *tieziUser_id;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@end

@implementation XCZPersonInfoLookImageViewController

@synthesize artDict = _artDict;

- (void)setCurrentImageNum:(int)currentImageNum
{
    _currentImageNum = currentImageNum;
    
    self.navNumLabel.text = [NSString stringWithFormat:@"%d／%ld", currentImageNum, (unsigned long)self.share_images.count];
}

- (void)setZan:(int)zan
{
    _zan = zan;
    
    if (zan) { // 已经点过赞了
        self.bottomPraiseLabel.text = [NSString stringWithFormat:@"（%d）", zan];
    } else { // 没有点过赞
        self.bottomPraiseLabel.text = [NSString stringWithFormat:@"（%d）", zan];
    }
}

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    
    
     if (self.goType == 1) {
         if (loginStatu) {
             [self goLogining];
//             self.goType = 4;
         } else {
             [self.textFieldZheGaiView removeFromSuperview];
             self.textFieldZheGaiView = nil;
         }
     } else if (self.goType == 2) {
         if (loginStatu) {
             [self goLogining];
         } else {
             NSDictionary *dict = @{
                                    @"type" : [NSString stringWithFormat:@"%d", self.zan],
                                    @"posts_clazz" : @"1",
                                    @"post_id" : [self.row objectForKey:@"post_id"],
                                    @"host" : self.tieziUser_id
                                    };
             [self requestBottomPraise:dict];
         }
     } else if (self.goType == 3) {
         if (loginStatu) {
             [self goLogining];
         } else {
             NSDictionary *dict = @{
                                    @"type" : @"1",
                                    @"post_id" : self.artDict[@"post_id"],
                                    @"forum_id" : self.artDict[@"forum_id"],
                                    @"reply_content" : self.postContentText,
                                    @"is_anony" : @"0",
                                    };
             [self requestReplyPost:dict];
         }
     } else if (self.goType == 4) {
         loginStatu ?  : [self requestZZUser_id];
     }
}

- (void)setArtDict:(NSDictionary *)artDict
{
    _artDict = artDict;
    self.goType = 4;
    [self requestLoginDetection];
}

- (NSDictionary *)artDict
{
    if (!_artDict) {
        _artDict = [NSDictionary dictionary];
    }
    return _artDict;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setupSubViews];
    self.goType = 4;
    [self requestLoginDetection];
    [self requestDetailsNet];
    [self changeNot]; // 通知处理
    
    [self.navBackView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backViewDidClick)]];
    [self.navMoreView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navMoreViewDidClick)]];
    [self.bottomPraiseView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomPraiseViewDidClick)]];
    [self.bottomDetailsView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bottomDetailsViewDidClick)]];
}

- (void)changeNot
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNot:) name:@"discoveryPageViewControllerKeyboardWillShowToSubClassVCNot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNot:) name:@"discoveryPageViewControllerKeyboardWillHideToSubClassVCNot" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
    if ([self.row objectForKey:@"post_id"]) {
        [self requestZZUser_id];
    }
}

- (void)backViewDidClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navMoreViewDidClick
{
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageWriteToSavedPhotosAlbum(self.currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }];
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:saveAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - 网络请求部分
- (void)requestDetailsNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/PostDetailAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 0] , @"post_id":[self.row objectForKey:@"post_id"]};
    
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
            if (taskId == 2620) {
                self.zan = [[[[dict objectForKey:@"rows"] firstObject] objectForKey:@"zan"] intValue];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestZZUser_id
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/NJsonDispatcher.do"];
    NSDictionary *parameters = @{
                                 @"post_id":[self.row objectForKey:@"post_id"],
                                 @"taskId": @"2665"
                                 };
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSString *tieziUser_id = [[[[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"] firstObject] objectForKey:@"user_id"];
        self.tieziUser_id = tieziUser_id;
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestBottomPraise:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/DianZanAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([responseObject[@"error"] containsString:@"未登录"]) {
            [MBProgressHUD ZHMShowError:@"未登录"];
        } else if ([responseObject[@"error"] intValue] == 201) {
            [self requestDetailsNet];
        } else if ([responseObject[@"error"] intValue] == 333) {
            [self requestDetailsNet];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        ZHMLog(@"error:%@", error);
        //        [self endHeaderRefresh];
    }];
}

- (void)requestReplyPost:(NSDictionary *)dict
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ReplyPostAction.do"];
    NSDictionary *parameters = dict;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"error"] intValue] == 201) {
            [MBProgressHUD ZHMShowSuccess:@"评论成功"];
            [self requestDetailsNet];
        } else {
            [MBProgressHUD ZHMShowError:@"评论失败"];
            [self requestDetailsNet];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.navigationController setNavigationBarHidden:YES animated:NO];
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

#pragma mark -  界面创建及显示部分
- (void)setupSubViews
{
    XCZPersonInfoLookImageView *lookImageView = [[XCZPersonInfoLookImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64 - 84)];
    lookImageView.backgroundColor = [UIColor blackColor];
    lookImageView.delegate = self;
    lookImageView.dataSource = self;
    [self.pictureView addSubview:lookImageView];
    self.lookImageView = lookImageView;
    
     NSString *showTime = [XCZTimeTools formateDatePicture:[self.row objectForKey:@"create_time"] withFormate:@"YYYY-MM-dd HH:mm:ss"];
    self.navTimeLabel.text = showTime;
    [self.row objectForKey:@"share_image"];
    self.contentLabel.text = [self.row objectForKey:@"content"];

    [self createTextFieldZheGaiView];
}

- (void)createTextFieldZheGaiView
{
    UIView *textFieldZheGaiView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.bottomTextField.bounds.size.width, self.bottomTextField.bounds.size.height)];
    [self.bottomTextField addSubview:textFieldZheGaiView];
    self.textFieldZheGaiView = textFieldZheGaiView;
    [self.textFieldZheGaiView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldZheGaiViewDidClick:)]];
}

- (NSArray *)bannersForBannerView:(XCZPersonInfoLookImageView *)bannerView
{
    NSArray *share_images = [self changeImage:_row[@"share_image"] andImageArray:[NSMutableArray array]];
    self.share_images = share_images;
    return share_images;
}

- (void)bannerView:(XCZPersonInfoLookImageView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo
{
    
}

- (void)bannerView:(XCZPersonInfoLookImageView *)bannerView currentImageNum:(int)currentImageNum currentImage:(UIImage *)image
{
    self.currentImageNum = currentImageNum;
    self.currentImage = image;
}

#pragma mark - 触发事件点击
- (void)bottomPraiseViewDidClick
{
    self.goType = 2;
    [self requestLoginDetection];
}

- (void)bottomDetailsViewDidClick
{
    NSString *identifier;
    NSString *post_clazz = _row[@"post_clazz"];
    if ([post_clazz intValue] == 1) {
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 2) { // 投票贴，暂时没有
        identifier = @"CellWZ";
    } else if ([post_clazz intValue] == 3) {
        NSMutableArray *imageArray = [NSMutableArray array];
        imageArray = [self changeImage:_row[@"share_image"] andImageArray:imageArray];
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
        if (!((NSString *)_row[@"share_image"]).length) {
            identifier = @"CellC1";
        } else {
            imageArray = [self changeImage:_row[@"share_image"] andImageArray:imageArray];
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
    [self jumpToXCZCircleDetailViewController:[self.row objectForKey:@"post_id"] andReuseIdentifier:identifier];
}

- (void)textFieldZheGaiViewDidClick:(UIGestureRecognizer *)grz
{
    self.goType = 1;
    [self requestLoginDetection];
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

#pragma mark - 跳转控制器
/**
 *  跳到话题详情
 */
- (void)jumpToXCZCircleDetailViewController:(NSString *)post_id andReuseIdentifier:(NSString *)reuseIdentifier
{
    XCZCircleDetailViewController *circleDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
    circleDetailVC.reuseIdentifier = reuseIdentifier;
    circleDetailVC.post_id = post_id;
    circleDetailVC.deleteJumpToMessageMyTopic = YES;
    [self.navigationController pushViewController:circleDetailVC animated:YES];
}

#pragma mark - XCZCircleDetailWriteViewDelegate
- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderLeftBtnDidClick:(UIButton *)commentHeaderLeftBtn
{
    [self.view endEditing:YES];
}

- (void)circleDetailWriteView:(XCZCircleDetailWriteView *)circleDetailWriteView commentHeaderRightBtnDidClickWithText:(NSString *)text
{
    self.goType = 3;
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (text.length) {
        [self.view endEditing:YES];
        self.postContentText = text;
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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo
{
    if(error != NULL){
        [MBProgressHUD ZHMShowError:@"保存图片失败"];
    }else{
        [MBProgressHUD ZHMShowError:@"保存图片成功"];
    }
}

@end
