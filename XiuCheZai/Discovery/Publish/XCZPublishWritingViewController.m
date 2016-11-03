//
//  XCZPublishWritingViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishWritingViewController.h"
#import "XCZCircleDetailViewController.h"
#import "XCZPublishBrandsViewController.h"
#import "XCZConfig.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZPersonWebViewController.h"
#import "XCZPublishSelectedCityView.h"
#import "XCZCityManager.h"
#import "MBProgressHUD+ZHM.h"
#define XCZPublishWritingViewControllerPWordText @"当下的感想"

@interface XCZPublishWritingViewController ()<XCZPublishBrandsViewControllerDelegate, XCZPublishSelectedCityViewDelegate, UITextViewDelegate>


@property (weak, nonatomic) IBOutlet UIView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *targetingView;
@property (weak, nonatomic) IBOutlet UIView *sendToView;
@property (weak, nonatomic) IBOutlet UITextField *topicField;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) UILabel *commentPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendToTextLabel;
@property (weak, nonatomic) XCZPublishSelectedCityView *selectedCityView;

@property (nonatomic, strong) NSDictionary *defaultAttention;
@property (nonatomic, strong) NSDictionary *location;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录

@end

@implementation XCZPublishWritingViewController

@synthesize defaultAttention = _defaultAttention;

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
   
    loginStatu ? [self goLogining] : [self requestDefaultAttention];
}


- (void)setDefaultAttention:(NSDictionary *)defaultAttention
{
    _defaultAttention = defaultAttention;
    self.sendToTextLabel.text = [self.defaultAttention objectForKey:@"forum_name"];
}

- (NSDictionary *)location
{
    if (!_location) {
        _location = [NSDictionary dictionary];
    }
    return _location;
}

- (NSDictionary *)defaultAttention
{
    if (!_defaultAttention) {
        _defaultAttention = [NSDictionary dictionary];
    }
    return _defaultAttention;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonItemDidClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发表" style:UIBarButtonItemStylePlain target:self action:@selector(navRightBtnDidClick)];
    
    self.contentTextView.delegate = self;
    UILabel *commentPlaceholderLabel = [[UILabel alloc] init];
    commentPlaceholderLabel.userInteractionEnabled = NO;
    commentPlaceholderLabel.text = XCZPublishWritingViewControllerPWordText;
    commentPlaceholderLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    commentPlaceholderLabel.font = [UIFont systemFontOfSize:14];
    commentPlaceholderLabel.frame = CGRectMake(8, 8, 120, 14);
    [self.contentTextView addSubview:commentPlaceholderLabel];
    self.commentPlaceholderLabel = commentPlaceholderLabel;
    
    [self.targetingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(targetingViewDidClick)]];
    [self.sendToView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendToViewDidClick)]];
    [self requestLoginDetection];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  默认关注请求
 */
- (void)requestDefaultAttention
{
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/BbsUserAction.do"];
    NSDictionary *parameters = @{
                                 @"type" : @"5",
                                 };
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            self.defaultAttention = [[responseObject objectForKey:@"data"] firstObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}

- (void)requestSendPost
{
    if (!self.contentTextView.text.length) {
        [MBProgressHUD ZHMShowError:@"说说您当下的感受吧"];
        return;
    }
    
    if (![self.defaultAttention objectForKey:@"forum_id"]) {
        [MBProgressHUD ZHMShowError:@"请重新要发送的板块..."];
        return;
    }
    
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/SendPostAction.do"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *topic;
    if (!self.topicField.text.length) {
        topic = @"";
    } else {
        topic = self.topicField.text;
    }
    
    if (!self.contentTextView.text) {
        [MBProgressHUD ZHMShowError:@"说说您当下的感受吧"];
        return;
    }
    
    params[@"type"] = @"0";
    params[@"forum_id"] = [self.defaultAttention objectForKey:@"forum_id"];
    params[@"province_id"] = [self.location objectForKey:@"province_id"];
    params[@"city_id"] = [self.location objectForKey:@"city_id"];
    params[@"province_id"] = [self.location objectForKey:@"province_id"];
    params[@"area_id"] = [self.location objectForKey:@"area_id"];
    params[@"addr"] = [self.location objectForKey:@"addr"];
    params[@"topic"] = topic;
    params[@"content"] = self.contentTextView.text;
    params[@"post_clazz"] = @"1";
   
    [self.manager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"error"] intValue] == 201) { // 发帖成功
            [MBProgressHUD ZHMShowSuccess:@"发帖成功"];
            NSString *post_id = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"post_id"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCZCircleDetailViewController *writingTopicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
                writingTopicVC.reuseIdentifier = @"CellWZ";
                writingTopicVC.post_id = post_id;
                [self.navigationController pushViewController:writingTopicVC animated:YES];
            });
        } else {
//            NSLog(@"responseObject:%@", responseObject);
            [MBProgressHUD ZHMShowError:@"发帖失败"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
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

- (void)leftBarButtonItemDidClick
{
    [self.view endEditing:YES];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"确定取消发布?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"继续发布" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];

    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)navRightBtnDidClick
{
    [self.view endEditing:YES];
    [self requestSendPost]; // 发帖请求
}

- (void)targetingViewDidClick
{
    if (!self.selectedCityView) {
        XCZPublishSelectedCityView *selectedCityView = [[XCZPublishSelectedCityView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 250)];
        selectedCityView.delegate = self;
        [self.view addSubview:selectedCityView];
        self.selectedCityView = selectedCityView;
        selectedCityView.allProvince = [XCZCityManager allProvince];
    }
    
    CGRect selectedCityViewRect = self.selectedCityView.frame;
    selectedCityViewRect.origin.y = self.view.bounds.size.height - 250;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedCityView.frame = selectedCityViewRect;
    }];
}

- (void)sendToViewDidClick
{
    [self.view endEditing:YES];
    
    XCZPublishBrandsViewController *publishBrandsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishBrandsViewController"];
    publishBrandsVC.delegate = self;
    [self.navigationController pushViewController:publishBrandsVC animated:YES];
}

#pragma mark - XCZPublishBrandsViewControllerDelegate
- (void)publishBrandsViewController:(UIViewController *)viewController didSelectRow:(NSDictionary *)row
{
    self.defaultAttention = row;
}

#pragma mark - XCZPublishSelectedCityViewDelegate
- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerLeftBtnDidClick:(UIButton *)leftBtn
{
    [self closeSelectedCityView];
}

- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerRightBtnDidClickWithSelectedLocation:(NSDictionary *)selectedLocation
{
    [self closeSelectedCityView];
    
    NSString *province_id = [[selectedLocation objectForKey:@"selectedProvinceDict"] objectForKey:@"number"];
      NSString *city_id = [[selectedLocation objectForKey:@"selectedCityDict"] objectForKey:@"number"];
      NSString *area_id = [[selectedLocation objectForKey:@"selectedTownDict"] objectForKey:@"number"];
    NSString *province_name = [[selectedLocation objectForKey:@"selectedProvinceDict"] objectForKey:@"city"];
    NSString *city_name = [[selectedLocation objectForKey:@"selectedCityDict"] objectForKey:@"city"];
    NSString *area_name = [[selectedLocation objectForKey:@"selectedTownDict"] objectForKey:@"city"];
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceName:province_name cityName:city_name andTownName:area_name];
    self.targetingTextLabel.text = addr;
    self.location = @{
                          @"province_id": province_id,
                          @"city_id": city_id,
                          @"area_id": area_id,
                          @"addr": [NSString stringWithFormat:@"%@^%@^%@^", province_name, city_name, area_name],
                  };
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.commentPlaceholderLabel.text = @"";
    } else {
        self.commentPlaceholderLabel.text = XCZPublishWritingViewControllerPWordText;
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
- (void)closeSelectedCityView
{
    CGRect selectedCityViewRect = self.selectedCityView.frame;
    selectedCityViewRect.origin.y = self.view.bounds.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedCityView.frame = selectedCityViewRect;
    } completion:^(BOOL finished) {
//        [self.selectedCityView removeFromSuperview];
    }];
}

@end
