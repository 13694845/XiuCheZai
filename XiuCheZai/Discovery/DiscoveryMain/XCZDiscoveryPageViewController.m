//
//  XCZContentViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDiscoveryPageViewController.h"
#import "XCZConfig.h"
#import "XCZNewsViewController.h"
#import "XCZCityManager.h"
#import "XCZPersonInfoLookImageViewController.h"
#import "XCZShareChannelPickerView.h"
#import "WXApi.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZNewsDetailViewController.h"
#import "XCZCircleDetailViewController.h"
#import "XCZActivityDetailViewController.h"
#import "XCZCircleDetailALayerViewController.h"
#import "XCZNewDetailALayerViewController.h"
#import "XCZDiscoveryFrameViewController.h"
#import "XCZPersonInfoLookImageViewController.h"

@interface XCZDiscoveryPageViewController ()<XCZShareChannelPickerViewDelegate, XCZNewsDetailViewControllerDelegate, XCZCircleDetailViewControllerDelegate, XCZActivityDetailViewControllerDelegate, XCZCircleDetailALayerViewControllerDelegate, XCZNewDetailALayerViewControllerDelegate>

@property(nonatomic, assign)CGRect keyboardFrame;
@property (weak, nonatomic) XCZShareChannelPickerView *shareChannelPickerView;
@property (weak, nonatomic) UITextField *bottomTextField;
@property (weak, nonatomic) UIView *coverView;
@property (nonatomic, strong) NSArray *shareRows;
@property (nonatomic, strong) NSDictionary *currentMessage;

@end

@implementation XCZDiscoveryPageViewController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor]};
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    
    NSMutableDictionary *textAttrs=[NSMutableDictionary dictionary];
    textAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:14];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    
    if (self.class == [XCZNewsDetailViewController class]) {
        XCZNewsDetailViewController *newsDetailsVC = (XCZNewsDetailViewController *)self;
        newsDetailsVC.delegate = self;
    }
    if (self.class == [XCZCircleDetailViewController class]) {
        XCZCircleDetailViewController *circleDetailsVC = (XCZCircleDetailViewController *)self;
        circleDetailsVC.delegate = self;
    }
    if (self.class == [XCZActivityDetailViewController class]) {
        XCZActivityDetailViewController *activityDetailsVC = (XCZActivityDetailViewController *)self;
        activityDetailsVC.delegate = self;
    }
    if (self.class == [XCZNewDetailALayerViewController class]) {
        XCZNewDetailALayerViewController *newDetailALayerVC = (XCZNewDetailALayerViewController *)self;
        newDetailALayerVC.delegate = self;
    }
    if (self.class == [XCZCircleDetailALayerViewController class]) {
        XCZCircleDetailALayerViewController *circleDetailALayerVC = (XCZCircleDetailALayerViewController *)self;
        circleDetailALayerVC.delegate = self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    [self.view endEditing:YES];
}

- (void)loadData {
    
}

- (void)refreshData {}

- (void)keyboardWillShow:(NSNotification *)notification
{
    if ([self.bottomTextField isFirstResponder]) {
        CGRect begin = [[[notification userInfo] objectForKey:@"UIKeyboardFrameBeginUserInfoKey"] CGRectValue];
        CGRect end = [[[notification userInfo] objectForKey:@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        // 第三方键盘回调三次问题，监听仅执行最后一次
        if(begin.size.height>0 && (begin.origin.y-end.origin.y>0)){
            CGRect keyboardFrame = [notification.userInfo[@"UIKeyboardBoundsUserInfoKey"] CGRectValue];
            self.keyboardFrame = keyboardFrame;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryPageViewControllerKeyboardWillShowToSubClassVCNot" object:nil userInfo:@{@"keyboardHeight": @(keyboardFrame.size.height)}];
            CGRect viewRect = self.view.frame;
            viewRect.origin.y = -keyboardFrame.size.height + 64;
            [UIView animateWithDuration:0.3 animations:^{
                self.view.frame = viewRect;
            } completion:^(BOOL finished) {}];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect viewRect = self.view.frame;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"discoveryPageViewControllerKeyboardWillHideToSubClassVCNot" object:nil userInfo:@{@"keyboardHeight": @(self.keyboardFrame.size.height)}];
    if (self.class == [XCZNewsDetailViewController class] || self.class == [XCZCircleDetailViewController class] || self.class == [XCZActivityDetailViewController class] || self.class == [XCZNewDetailALayerViewController class] || self.class == [XCZCircleDetailALayerViewController class]) {
        viewRect.origin.y = 64;
    } else {
        viewRect.origin.y = 0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = viewRect;
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shareMessage:(NSDictionary *)message {
    self.currentMessage = message;
    
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

- (void)coverViewDidClick:(UIGestureRecognizer *)grz
{
    [self dropOutCoverView];
}

#pragma mark - 详情页代理方法
- (void)detailViewController:(UIViewController *)viewController bottomTextField:(UITextField *)bottomTextField
{
    self.bottomTextField = bottomTextField;
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
    CGFloat const kImageMaxWidth = 250.0;
    CGFloat const kImageMaxHeight = 250.0;
    
    WXMediaMessage *mediaMessage = [WXMediaMessage message];
    mediaMessage.title = [self.currentMessage objectForKey:@"title"];
    mediaMessage.description = [self.currentMessage objectForKey:@"description"];
    UIImage *thumbImage = self.currentMessage[@"thumbImage"];
        if (thumbImage.size.width > kImageMaxWidth) {
        thumbImage = [self resizeImage:thumbImage toSize:CGSizeMake(kImageMaxWidth, thumbImage.size.height * (kImageMaxWidth / thumbImage.size.width))];
    }
    if (thumbImage.size.height > kImageMaxHeight) {
        thumbImage = [self resizeImage:thumbImage toSize:CGSizeMake(thumbImage.size.width * (kImageMaxHeight / thumbImage.size.height), kImageMaxHeight)];
    }
    [mediaMessage setThumbImage:thumbImage];
    
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [self.currentMessage objectForKey:@"webpageUrl"];
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

#pragma mark - 私有方法
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
- (NSString *)timeWithTimeIntervalString:(NSString *)time13String
{
    // 格式化时间
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    // 毫秒值转化为秒
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[time13String doubleValue]/ 1000.0];
    NSString* dateString = [formatter stringFromDate:date];
    return dateString;
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}


@end
