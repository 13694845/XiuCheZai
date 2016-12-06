//
//  Double12HomeViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/11/24.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "Double12HomeViewController.h"
#import "MBProgressHUD+ZHM.h"
#import "AFNetworking.h"
#import "XCZConfig.h"
#import "XCZDouble12WebViewController.h"
#import "Double12AwardViewController.h"
#import "XCZShareChannelPickerView.h"
#import "WXApi.h"
#define Double12HomeViewControllerShareId @"1"

@interface Double12HomeViewController ()<UITextFieldDelegate, XCZShareChannelPickerViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backViewTop;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *takeAwardButton;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UIButton *backBtn;
@property (strong, nonatomic) UIButton *shareBtn;
@property (assign, nonatomic) CGFloat detaHeight;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (weak, nonatomic) UIView *coverView;
@property (weak, nonatomic) XCZShareChannelPickerView *shareChannelPickerView;
@property (nonatomic, strong) NSArray *shareRows;
@property (strong, nonatomic) NSDictionary *shareDict;

@end

@implementation Double12HomeViewController

@synthesize shareDict = _shareDict;

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [XCZConfig version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSArray *)shareRows
{
    if (!_shareRows) {
        _shareRows = @[
                       @{
                           @"name" : @"微信",
                           @"ShareMessageChannel": @"ShareMessageChannelWeixinSession",
                           @"icon" : @"bbs_weixinshare"
                           },
                       @{
                           @"name" : @"朋友圈",
                           @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                           @"icon" : @"bbs_pengyouquanshare"
                           },
                       //                          @{
                       //                              @"name" : @"新浪微博",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_xinlangshare"
                       //                              },
                       //                          @{
                       //                              @"name" : @"QQ好友",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_qqshare"
                       //                              },
                       //                          @{
                       //                              @"name" : @"QQ空间",
                       //                              @"ShareMessageChannel": @"ShareMessageChannelWeixinTimeline",
                       //                              @"icon" : @"bbs_qqsharekongjianshare"
                       //                              },
                       ];
    }
    return _shareRows;
}

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    loginStatu ? [self goLogining] : @"";
}

- (void)setShareDict:(NSDictionary *)shareDict
{
    _shareDict = shareDict;
    
    UIView *coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    coverView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self.view addSubview:coverView];
    self.coverView = coverView;
    
    XCZShareChannelPickerView *shareChannelPickerView = [[XCZShareChannelPickerView alloc] init];
    shareChannelPickerView.delegate = self;
    shareChannelPickerView.selfW = self.view.bounds.size.width;
    shareChannelPickerView.shareRows = self.shareRows;
    CGFloat shareChannelPickerViewH = shareChannelPickerView.bounds.size.height;
    shareChannelPickerView.frame = CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, shareChannelPickerViewH);
    [self.view addSubview:shareChannelPickerView];
    
    self.shareChannelPickerView = shareChannelPickerView;
    CGRect shareChannelPickerViewRect = shareChannelPickerView.frame;
    shareChannelPickerViewRect.origin.y = self.view.bounds.size.height - shareChannelPickerViewH;
    [UIView animateWithDuration:0.3 animations:^{
        shareChannelPickerView.frame = shareChannelPickerViewRect;
    }];
    
    [coverView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverViewDidClick:)]];
    
}

- (NSDictionary *)shareDict
{
    if (!_shareDict) {
        _shareDict = [NSDictionary dictionary];
    }
    return _shareDict;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.textView.selectable = NO;
    
    self.backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 100, 44)];
    UIImageView *backImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11, 16, 7, 12)];
    backImageView.image = [UIImage imageNamed:@"bbs_arrow"];
    [self.backBtn addSubview:backImageView];
    UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(backImageView.frame) + 8, 16, self.backBtn.bounds.size.width - CGRectGetMaxX(backImageView.frame) + 8, 12)];
    backLabel.text = @"返回首页";
    backLabel.textColor = [UIColor whiteColor];
    backLabel.font = [UIFont systemFontOfSize:14];
    [self.backBtn addSubview:backLabel];
    [self.view addSubview:self.backBtn];
    
    self.shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 45, 20, 45, 44)];
    [self.shareBtn setImage:[UIImage imageNamed:@"double12_send"] forState:UIControlStateNormal];
    self.shareBtn.imageEdgeInsets = UIEdgeInsetsMake(13.665, 12.835, 13.665, 12.835);
    [self.view addSubview:self.shareBtn];
    
    self.passwordTextField.layer.cornerRadius = 8.0;
    self.takeAwardButton.layer.cornerRadius = 8.0;
    self.passwordTextField.delegate = self;
    
    [self.backBtn addTarget:self action:@selector(backBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self.shareBtn addTarget:self action:@selector(shareBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"Double12LoginStatu"] intValue] == 1) {
    } else {
        [self requestLoginDetection];
    }
}

- (void)backBtnDidClick
{
    [self.view endEditing:YES];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)shareBtnDidClick
{
    [self.view endEditing:YES];
    [self requestShare];
}

- (IBAction)takeAward:(id)sender {
    [self.view endEditing:YES];
    
    [MBProgressHUD ZHMShowMessage:@"请稍候~~"];
    [self requestNet];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    textField.text = ([[textField.text stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]] length]) ? @"" : textField.text;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
    CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    // 第三方键盘回调三次问题，监听仅执行最后一次
    if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
        CGRect keyboardFrame = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
        if ((self.view.bounds.size.height - CGRectGetMaxY(self.takeAwardButton.frame)) < keyboardFrame.size.height) {
            self.detaHeight = keyboardFrame.size.height - (self.backView.bounds.size.height - CGRectGetMaxY(self.takeAwardButton.frame)) + 20.0;
            CGRect viewFrame = self.backView.frame;
            viewFrame.origin.y = -self.detaHeight;
            [UIView animateWithDuration:0.3 animations:^{
                self.backView.frame = viewFrame;
                [self.backViewTop setConstant:-self.detaHeight];
            }];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame = self.backView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.backView.frame = frame;
        self.backViewTop.constant = 0;
    } completion:^(BOOL finished) {
        self.passwordTextField.text = self.passwordTextField.text.length ? self.passwordTextField.text : @"输入口令";
    }];
}

#pragma mark - 网络请求
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

- (void)requestNet
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/GrabRedPackageAction.do"];
    NSDictionary *parameters = @{@"type":[NSString stringWithFormat:@"%d", 1], @"word": self.passwordTextField.text};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"parameters:%@, responseObject:%@", parameters, responseObject);
        [MBProgressHUD ZHMHideHUD];
        if ([responseObject[@"error"] intValue] == 403) { // 未登录
            [self goLogining];
            return;
        }
        
//       responseObject =  @{
//            @"error": @"201",
//            @"msg": @"成功",
//            @"data":  @[
//                       @{
//                           @"get_money": @"5",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"test123",
//                           @"m": @"1"
//                           },
//                       @{
//                           @"get_money": @"103500",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"15868666821",
//                           @"m": @"0"
//                           },
//                       @{
//                           @"get_money": @"5",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"wwwww43",
//                           @"m": @"0"
//                           },
//                       @{
//                           @"get_money": @"5",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"wwwww43",
//                           @"m": @"0"
//                           },
//                       @{
//                           @"get_money": @"5",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"wwwww43",
//                           @"m": @"0"
//                           },
//                       @{
//                           @"get_money": @"5",
//                           @"get_time": @"1580379718000",
//                           @"login_name": @"wwwww43",
//                           @"m": @"0"
//                           }
//                       ]
//            };
        
//       responseObject =  @{
//            @"error": @"201",
//            @"msg": @"成功",
//            @"data":  @{
//                        @"record": @"0",
//                        @"counter": @"1"
//                        }
//            };
        
        if ([[responseObject objectForKey:@"error"] intValue] != 201) {
            [MBProgressHUD ZHMShowError:@"口令错误，请重新输入~"];
            return;
        } else {
            if ([[responseObject objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
                NSDictionary *dict2688 = [NSDictionary dictionary];
                NSDictionary *dict2684 = [NSDictionary dictionary];
                for (NSDictionary *dict in [responseObject objectForKey:@"data"]) {
                    if ([[dict objectForKey:@"taskId"]  isEqualToString:@"2688"]) {
                        if ([[dict objectForKey:@"rows"] count]) {
                            dict2688 = [dict objectForKey:@"rows"];
                        }
                    }
                    if ([[dict objectForKey:@"taskId"] isEqualToString:@"2684"]) {
                        if ([[dict objectForKey:@"rows"] count]) {
                            dict2684 = dict;
                        }
                    }
                }
                Double12AwardViewController *awardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Double12AwardViewController"];
                awardVC.password = self.passwordTextField.text;
                awardVC.type = Double12AwardViewControllerHasRecord;
                if ([[dict2684 objectForKey:@"rows"] count]) {
                   awardVC.records = [dict2684 objectForKey:@"rows"];
                }
                [self.navigationController pushViewController:awardVC animated:YES];
            } else {
                NSDictionary *dataDict = [responseObject objectForKey:@"data"];
                if (![[dataDict objectForKey:@"record"] intValue]) { // 没抢过该红包
                   int counter = [[dataDict objectForKey:@"counter"] intValue];
                    if (counter == -1) {
                        [MBProgressHUD ZHMShowError:@"红包不存在~"];
                    } else if (counter == 0) { // 被抢完了
                        [self jumpToNewPacketOver]; // 跳转到红包被抢完界面
                    } else if (counter > 0) { // 可拆红包
                        [self jumpToNewRedPacket]; // 跳转到可拆红包
                    }
                }
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [MBProgressHUD ZHMHideHUD];
//        NSLog(@"asdddderror:%@", error);
    }];
}

- (void)requestShare
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/ShareActiveServlet.do"];
    NSDictionary *parameters = @{@"share_id": Double12HomeViewControllerShareId};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
//        NSLog(@"responseObjectsss:%@", responseObject);
        self.shareDict = [[responseObject objectForKey:@"data"] firstObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//       NSLog(@"errorssss:%@", error);
    }];
}

#pragma mark - XCZShareChannelPickerViewDelegate
/**
 *  取消按钮被点击
 */
- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView cancelBtnDidClick:(UIButton *)cancelBtn
{
    [self dropOutCoverView];
}

- (void)shareChannelPickerView:(XCZShareChannelPickerView *)shareChannelPickerView iconViewDidClick:(XCZShareChannelIconView *)iconView
{
    NSString *title = [self.shareDict objectForKey:@"share_title"];
    NSString *description = [self.shareDict objectForKey:@"share_content"];
    NSString *share_url = [self.shareDict objectForKey:@"share_url"];

    title = [title stringByReplacingOccurrencesOfString:@"###get_money###" withString:@""];
    description = [description stringByReplacingOccurrencesOfString:@"####get_money####" withString:@""];
    share_url = [share_url stringByReplacingOccurrencesOfString:@"####get_money####" withString:@""];
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = title;
    mediaMessage.description = description;
    [mediaMessage setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.shareDict objectForKey:@"share_img"]]]]];
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = share_url;
    mediaMessage.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = mediaMessage;
    if ([iconView.shareRow[@"ShareMessageChannel"] isEqualToString:@"ShareMessageChannelWeixinSession"]) { // 分享到微信聊天界面
        if ([WXApi isWXAppInstalled]) {
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        } else {
            [MBProgressHUD ZHMShowError:@"没有安装微信"];
        }
    } else if ([iconView.shareRow[@"ShareMessageChannel"] isEqualToString:@"ShareMessageChannelWeixinTimeline"]) { // 分享到微信朋友圈
        if ([WXApi isWXAppInstalled]) {
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
        } else {
            [MBProgressHUD ZHMShowError:@"没有安装微信"];
        }
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
    XCZDouble12WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZDouble12WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)jumpToNewRedPacket
{
    Double12AwardViewController *awardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Double12AwardViewController"];
    awardVC.type = Double12AwardViewControllerNewRedPacket;
    awardVC.password = self.passwordTextField.text;
    [self.navigationController pushViewController:awardVC animated:YES];
}

- (void)jumpToNewPacketOver
{
    Double12AwardViewController *awardVC = [self.storyboard instantiateViewControllerWithIdentifier:@"Double12AwardViewController"];
    awardVC.password = self.passwordTextField.text;
    awardVC.type = Double12AwardViewControllerPacketOver;
    [self.navigationController pushViewController:awardVC animated:YES];
}

- (void)coverViewDidClick:(UIGestureRecognizer *)grz
{
    [self dropOutCoverView];
}

/**
 *  退出分享View
 */
- (void)dropOutCoverView
{
    [self.coverView removeFromSuperview];
    self.coverView = nil;
    CGRect shareChannelPickerViewRect = self.shareChannelPickerView.frame;
    shareChannelPickerViewRect.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.shareChannelPickerView.frame = shareChannelPickerViewRect;
    }];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}



@end
