//
//  XCZPublishOrderTopicViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/14.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPublishOrderViewController.h"
#import "XCZPublishOrderProductView.h"
#import "XCZPublishTextPhoneView.h"
#import "XCZPublishTextPhoneButton.h"
#import "XCZPublishPositioningSendView.h"
#import "XCZPublishSelectedCityView.h"
#import "XCZConfig.h"
#import "MBProgressHUD+ZHM.h"
#import "XCZCityManager.h"
#import "XCZPublishBrandsViewController.h"
#import "XCZPersonWebViewController.h"
#import "XCZCircleDetailViewController.h"
#import "SGImagePickerController.h"

@interface XCZPublishOrderViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate, XCZPublishTextPhoneViewDelegate, XCZPublishSelectedCityViewDelegate, XCZPublishBrandsViewControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, weak) UIView *writingView;
@property (nonatomic, weak) XCZPublishTextPhoneView *textPhoneView;
@property (nonatomic, assign) NSInteger selectedPhoneBtnTag;
@property (nonatomic, weak) XCZPublishPositioningSendView *targetingView;
@property (nonatomic, weak) XCZPublishPositioningSendView *sendToView;
@property (weak, nonatomic) XCZPublishSelectedCityView *selectedCityView;
@property (weak, nonatomic) XCZPublishOrderProductView *productView;
@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, strong) NSDictionary *defaultAttention;
@property (nonatomic, strong) NSDictionary *currentPositioning;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (nonatomic, strong) NSArray *showImages;
@property (nonatomic, strong) UIImage *chouImage;
@property (nonatomic, copy) NSString *imageStrs;
@property (strong, nonatomic) AFHTTPSessionManager *phoneManager;

@end

@implementation XCZPublishOrderViewController

@synthesize location = _location;
@synthesize defaultAttention = _defaultAttention;

- (AFHTTPSessionManager *)phoneManager {
    if (!_phoneManager) {
        _phoneManager = [AFHTTPSessionManager manager];
        [_phoneManager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                                   [_phoneManager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [XCZConfig version]] forHTTPHeaderField:@"User-Agent"];
        _phoneManager.responseSerializer=[AFHTTPResponseSerializer serializer];
    }
    return _phoneManager;
}

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    loginStatu ? [self goLogining] : [self requestDefaultAttention];
}

- (NSArray *)showImages
{
    if (!_showImages) {
        _showImages = [NSArray array];
    }
    return _showImages;
}

- (NSDictionary *)location
{
    if (!_location) {
        _location = [NSDictionary dictionary];
    }
    return _location;
}

- (void)setLocation:(NSDictionary *)location
{
    _location = location;
}

- (void)setDefaultAttention:(NSDictionary *)defaultAttention
{
    _defaultAttention = defaultAttention;
    self.sendToView.textShow = defaultAttention[@"forum_name"];
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
    [self assistedSetup];
    [self createSubView];
    
    [self.targetingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(targetingViewDidClick)]];
    [self.sendToView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendToViewDidClick)]];
    [self requestLoginDetection];
    [self requestPositioning];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assistedSetup
{
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.delegate = self;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"bbs_arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(goBack)];
}

- (void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createSubView
{
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 64)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = CGSizeMake(self.contentView.bounds.size.width, self.contentView.bounds.size.height);
    
    UIView *writingView = [[UIView alloc] init];
    writingView.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, 312);
    [self.contentView addSubview:writingView];
    self.writingView = writingView;
    
    XCZPublishOrderProductView *productView = [[XCZPublishOrderProductView alloc] init];
    productView.frame = CGRectMake(16, 16, self.contentView.bounds.size.width - 32, 91);
    productView.layer.masksToBounds = YES;
    productView.layer.borderWidth = 1.0;
    productView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0].CGColor;
    productView.order_good = self.order_good;
    [writingView addSubview:productView];
    
    XCZPublishTextPhoneView *textPhoneView = [[XCZPublishTextPhoneView alloc] initWithFrame:CGRectMake(0, 16 + 91, self.contentView.bounds.size.width, 222)];
    textPhoneView.isNoTopic = YES;
    textPhoneView.delegate = self;
    textPhoneView.titleField.delegate = self;
    textPhoneView.textView.delegate = self;
    [writingView addSubview:textPhoneView];
    self.textPhoneView = textPhoneView;
    
    self.productView.layer.cornerRadius = 5.0;
    self.productView.layer.borderWidth = 1.0;
    self.productView.layer.borderColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1.0].CGColor;
    self.productView.frame = CGRectMake(16, 16, self.contentView.bounds.size.width - 32, 91);
    [self.scrollView insertSubview:self.productView atIndex:100];
    
    XCZPublishPositioningSendView *targetingView = [[XCZPublishPositioningSendView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(textPhoneView.frame) + 16, self.contentView.bounds.size.width, 40)];
    [self.contentView addSubview:targetingView];
    self.targetingView = targetingView;
    NSMutableDictionary *targetRow = [NSMutableDictionary dictionary];
    targetRow[@"icon"] = @"bbs_location.png";
    targetRow[@"name"] = @"定位到";
    self.targetingView.row = targetRow;
    
    XCZPublishPositioningSendView *sendToView = [[XCZPublishPositioningSendView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(targetingView.frame), self.contentView.bounds.size.width, 40)];
    [self.contentView addSubview:sendToView];
    self.sendToView = sendToView;
    
    NSMutableDictionary *sendRow = [NSMutableDictionary dictionary];
    sendRow[@"icon"] = @"bbs_send_to.png";
    sendRow[@"name"] = @"发送到";
    self.sendToView.row = sendRow;
}

#pragma mark - 网络请求
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
    NSString *content = [self.textPhoneView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    if (!content.length) {
        [MBProgressHUD ZHMShowError:@"说说您当下的感受吧"];
        return;
    }
    if (![self.defaultAttention objectForKey:@"forum_id"]) {
        [MBProgressHUD ZHMShowError:@"请选择要发送的板块..."];
        return;
    }
    [self.textPhoneView.textView resignFirstResponder];
    
    NSString *share_image = self.imageStrs ? self.imageStrs : @"";
    NSString *post_clazz = @"4";
    NSString *goods_clazz = (self.status == 1) ? @"0" : @"1";
    NSString *goods_id = (self.status == 1) ? self.order_good[@"order_id"] : self.order_good[@"goods_id"];
    NSDictionary *goods_info = @{
                                 @"id" : goods_id,
                                 @"name" : self.order_good[@"goods_name"],
                                 @"img" : self.order_good[@"goods_main_img"],
                                 @"num" : self.order_good[@"goods_num"],
                                 @"amount" : self.order_good[@"amounts"],
                                 @"property" : self.order_good[@"property_json"],
                                 };
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:goods_info options:NSJSONWritingPrettyPrinted error:nil];
    NSString *good_infoStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/SendPostAction.do"];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = @"0";
    params[@"topic"] = @"";
    params[@"forum_id"] = [self.defaultAttention objectForKey:@"forum_id"];
    params[@"province_id"] = [self.location objectForKey:@"province_id"];
    params[@"city_id"] = [self.location objectForKey:@"city_id"];
    params[@"province_id"] = [self.location objectForKey:@"province_id"];
    params[@"area_id"] = [self.location objectForKey:@"area_id"];
    params[@"addr"] = [self.location objectForKey:@"addr"];
    params[@"content"] = content;
    params[@"share_image"] = share_image;
    params[@"post_clazz"] = post_clazz;
    params[@"goods_clazz"] = goods_clazz;
    params[@"goods_id"] = goods_id;
    params[@"goods_info"] = good_infoStr;
    
    [self.manager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
//        NSLog(@"msg:%@", responseObject[@"msg"]);
//        NSLog(@"params:%@", params);
        if ([[responseObject objectForKey:@"error"] intValue] == 201) { // 发帖成功
            [MBProgressHUD ZHMShowSuccess:@"发帖成功"];
            NSString *post_id = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"post_id"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                XCZCircleDetailViewController *writingTopicVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleDetailViewController"];
                writingTopicVC.reuseIdentifier = @"CellC";
                writingTopicVC.post_id = post_id;
                writingTopicVC.jumpToHome = YES;
                [self.navigationController pushViewController:writingTopicVC animated:YES];
            });
        } else {
            [MBProgressHUD ZHMShowError:[NSString stringWithFormat:@"发帖失败,%@", responseObject[@"msg"]]];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        NSLog(@"error:%@", error);
    }];
}


- (void)requestPostImage:(UIImage *)currentImage andIndex:(NSInteger)currentIndex andImages:(NSArray *)images
{
    [MBProgressHUD ZHMShowMessage:@"正在处理中..."];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/WebUploadServlet.action"];
    
    [self.phoneManager POST:URLString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        // 1.取文件名 随机数 + ios + 类型(图片为Image) + 时间(201412111537)年月日时分秒
        int random = arc4random() % 1000;
        int random2 = (arc4random() % 501) + 500;
        NSString *userType = [NSString stringWithFormat:@"%d%@%@%d", random, @"ios", @"Image", random2];
        NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
        dataFormatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *timeStr = [dataFormatter stringFromDate:[NSDate date]];
        NSString *fileName = [userType stringByAppendingString:[NSString stringWithFormat:@"%@.jpg", timeStr]];
        NSData *imgData = UIImageJPEGRepresentation(currentImage, 1.0);
        [formData appendPartWithFileData:imgData name:@"file" fileName:fileName mimeType:@"image/jpeg"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        //                 NSLog(@"uploadProgress:%@", uploadProgress);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [MBProgressHUD ZHMHideHUD];
        NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if ([responseInfo[@"error"] intValue]) {
            NSString *imageStr = [responseInfo objectForKey:@"filepath"];
            self.textPhoneView.selectedPhoneBtnTag = self.selectedPhoneBtnTag;
            self.textPhoneView.imageDict = @{@"image": currentImage, @"imageStr": imageStr};
            int index = currentIndex;
            index ++;
            if (images) {
                if (self.textPhoneView.phoneBtns.count <= 1 + index) {
                    self.selectedPhoneBtnTag = index;
                } else {
                    self.selectedPhoneBtnTag += 1;
                }
                
                if (index <images.count && index) {
                    [self requestPostImage:images[index] andIndex:index andImages:images];
                }
            } else {
                self.textPhoneView.selectedPhoneBtnTag = self.selectedPhoneBtnTag;
                self.textPhoneView.imageDict = @{@"image": currentImage, @"imageStr": imageStr};
            }
        } else {
            [MBProgressHUD ZHMShowError:[NSString stringWithFormat:@"%@%@", @"上传失败!", @"文件太大"]];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [MBProgressHUD ZHMHideHUD];
        [MBProgressHUD ZHMShowError:@"失败，请检查网络"];
        [self dismissViewControllerAnimated:YES completion:nil];
        NSLog(@"error:%@", error);
    }];
}

- (void)requestPositioning
{
    NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *longitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
    NSString *latitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/CityLocation.do"];
    NSDictionary *params = ![longitude isEqualToString:@"0.000000"] ? @{@"lng": longitude, @"lat": latitude, @"type": @"1"} : @{};
    [self.manager POST:URLString parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.currentPositioning = responseObject;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {}];
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

#pragma mark - 按钮点击方法
- (IBAction)leftBtnDidClick:(id)sender {
    [self.view endEditing:YES];
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:@"确定取消发布?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确认取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"继续发布" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [self.navigationController presentViewController:alertCtr animated:YES completion:nil];
}

- (IBAction)rightBtnDidClick:(id)sender {
    [self requestSendPost];
}

- (void)targetingViewDidClick
{
    self.scrollView.userInteractionEnabled = NO;
    XCZPublishSelectedCityView *selectedCityView = [[XCZPublishSelectedCityView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 250)];
    selectedCityView.delegate = self;
    if (self.currentPositioning.count) {
        NSString *provinceid = ([[self.currentPositioning objectForKey:@"provinceid"] isEqual:[NSNull null]] || ![[self.currentPositioning objectForKey:@"provinceid"] length]) ? @"" : [self.currentPositioning objectForKey:@"provinceid"];
        NSString *cityid = ([[self.currentPositioning objectForKey:@"cityid"] isEqual:[NSNull null]] || ![[self.currentPositioning objectForKey:@"cityid"] length]) ? @"" : [self.currentPositioning objectForKey:@"cityid"];
        NSString *areaid = ([[self.currentPositioning objectForKey:@"areaid"] isEqual:[NSNull null]] || ![[self.currentPositioning objectForKey:@"areaid"] length]) ? @"" : [self.currentPositioning objectForKey:@"areaid"];
        selectedCityView.currentLocation = @{@"provinceid": provinceid, @"cityid": cityid,@"areaid": areaid};
    } else {
        selectedCityView.currentLocation = @{@"provinceid": @"330000",@"cityid": @"331000",@"townid": @"331001"};
    }
    [self.view addSubview:selectedCityView];
    self.selectedCityView = selectedCityView;
    selectedCityView.allProvince = [XCZCityManager allProvince];

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

#pragma mark - 键盘通知方法 scrollView及textField,textView代理
- (void)keyboardWillShow:(NSNotification *)notification
{
    self.targetingView.userInteractionEnabled = NO;
    self.sendToView.userInteractionEnabled = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.targetingView.userInteractionEnabled = YES;
    self.sendToView.userInteractionEnabled = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (![scrollView isKindOfClass:[UITextView class]]) {
         [self.view endEditing:YES];
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length) {
        self.textPhoneView.commentPlaceholderLabel.text = @"";
    } else {
        self.textPhoneView.commentPlaceholderLabel.text = XCZPublishTextPhoneViewPWordText;
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        return YES; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - XCZPublishBrandsViewControllerDelegate
- (void)publishBrandsViewController:(UIViewController *)viewController didSelectRow:(NSDictionary *)row
{
    self.defaultAttention = row;
}

#pragma mark - XCZPublishTextPhoneViewDelegate
- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtnDidClick:(XCZPublishTextPhoneButton *)selectedPhoneButton
{
    self.selectedPhoneBtnTag = selectedPhoneButton.tag;
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photoAlbumgraph:UIImagePickerControllerSourceTypePhotoLibrary]; // 选择相册
    }];
    UIAlertAction *twoAction = [UIAlertAction actionWithTitle:@"拍摄" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self photograph:UIImagePickerControllerSourceTypeCamera]; // 调用拍照
    }];
    
    UIAlertAction *threeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIAlertController *delecetdAlertCtr = [UIAlertController alertControllerWithTitle:@"要删除这张照片吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *delecetdCancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }];
        UIAlertAction *delecetdOneAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            self.textPhoneView.selectedPhoneBtnTag = self.selectedPhoneBtnTag;
            self.textPhoneView.removeImageDict = @{@"image": selectedPhoneButton.currentImage};
        }];
        [delecetdAlertCtr addAction:delecetdCancelAction];
        [delecetdAlertCtr addAction:delecetdOneAction];
        [self presentViewController:delecetdAlertCtr animated:YES completion:nil];
    }];
    
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [alertCtr addAction:twoAction];
    if(selectedPhoneButton.currentImage)[alertCtr addAction:threeAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView lastPhoneButton:(XCZPublishTextPhoneButton *)lastPhoneButton height:(CGFloat)height
{
    CGRect textPhoneViewRect = self.textPhoneView.frame;
    textPhoneViewRect.size.height = height + 16;
    self.textPhoneView.frame = textPhoneViewRect;
    
    CGRect writingViewRect = self.writingView.frame;
    writingViewRect.size.height =  height;
    self.writingView.frame = writingViewRect;
    
    CGRect targetingViewRect = self.targetingView.frame;
    targetingViewRect.origin.y = CGRectGetMaxY(self.textPhoneView.frame) + 16;
    self.targetingView.frame = targetingViewRect;
    
    CGRect sendToViewRect = self.sendToView.frame;
    sendToViewRect.origin.y = CGRectGetMaxY(self.targetingView.frame);
    self.sendToView.frame = sendToViewRect;
    
    [self.scrollView insertSubview:textPhoneView atIndex:200];
    [self.scrollView insertSubview:self.targetingView atIndex:200];
    [self.scrollView insertSubview:self.sendToView atIndex:200];
    [self.textPhoneView frameHasChange];
}

- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtns:(NSArray *)phoneBtns
{
    NSString *imageStrs;
    for (int i = 0; i<phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = phoneBtns[i];
        //        NSLog(@"phoneBtnimageDict:%@", phoneBtn.imageDict);
        if (phoneBtn.imageDict) {
            imageStrs = i == 0 ? [NSString stringWithFormat:@"%@", [phoneBtn.imageDict objectForKey:@"imageStr"]] : [NSString stringWithFormat:@"%@,%@", imageStrs , [phoneBtn.imageDict objectForKey:@"imageStr"]];
        }
    }
    self.imageStrs = imageStrs;
}

- (void)textPhoneView:(XCZPublishTextPhoneView *)textPhoneView phoneBtnRemoveOver:(NSArray *)phoneBtns
{
    NSString *imageStrs;
    for (int i = 0; i<phoneBtns.count; i++) {
        XCZPublishTextPhoneButton *phoneBtn = phoneBtns[i];
        if (phoneBtn.imageDict) {
            imageStrs = (i == 0) ? [NSString stringWithFormat:@"%@", [phoneBtn.imageDict objectForKey:@"imageStr"]] : [NSString stringWithFormat:@"%@,%@", imageStrs , [phoneBtn.imageDict objectForKey:@"imageStr"]];
        }
    }
    self.imageStrs = imageStrs;
}

#pragma mark - XCZPublishSelectedCityViewDelegate
- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerLeftBtnDidClick:(UIButton *)leftBtn
{
    [self closeSelectedCityView];
    self.scrollView.userInteractionEnabled = YES;
}

- (void)publishSelectedCityView:(XCZPublishSelectedCityView *)selectedCityView headerRightBtnDidClickWithSelectedLocation:(NSDictionary *)selectedLocation
{
    [self closeSelectedCityView];
    self.scrollView.userInteractionEnabled = YES;
    NSString *province_id = [[selectedLocation objectForKey:@"selectedProvinceDict"] objectForKey:@"number"];
    NSString *city_id = [[selectedLocation objectForKey:@"selectedCityDict"] objectForKey:@"number"];
    NSString *area_id = [[selectedLocation objectForKey:@"selectedTownDict"] objectForKey:@"number"];
    NSString *province_name = [[selectedLocation objectForKey:@"selectedProvinceDict"] objectForKey:@"city"];
    NSString *city_name = [[selectedLocation objectForKey:@"selectedCityDict"] objectForKey:@"city"];
    NSString *area_name = [[selectedLocation objectForKey:@"selectedTownDict"] objectForKey:@"city"];
    
    NSString *addr = [XCZCityManager splicingProvinceCityTownNameWithProvinceName:province_name cityName:city_name andTownName:area_name];
    self.targetingView.textShow = addr;
    
    self.location = @{
                      @"province_id": province_id,
                      @"city_id": city_id,
                      @"area_id": area_id,
                      @"addr": [NSString stringWithFormat:@"%@^%@^%@^", province_name, city_name, area_name],
                      };
}

#pragma mark - 拍照相册处理
- (void)photoAlbumgraph:(UIImagePickerControllerSourceType)sourceType
{
    SGImagePickerController *imgCtr = [[SGImagePickerController alloc] init];
    //返回选中的原图
    [self presentViewController:imgCtr animated:YES completion:nil];
    [imgCtr setDidFinishSelectImages:^(NSArray *images) {
        NSMutableArray *newImages = [NSMutableArray array];
        for (UIImage *image in images) {
            [self compressionImage:image andCompressionQuality:XCZPublishTextPhoneViewPhoneQuality];
            if (self.chouImage) {
                [newImages addObject:self.chouImage];
            }
        }
        
        if ([newImages firstObject]) {
            if (self.textPhoneView.phoneBtns.count - 1 + images.count > 9) {
                [MBProgressHUD ZHMShowError:@"图片大于9张，请重新选取!"];
            } else {
                [self requestPostImage:[newImages firstObject] andIndex:0 andImages:newImages];
            }
        }
    }];
}
- (void)photograph:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    imagePickController.delegate = self;
    imagePickController.sourceType = sourceType;
    //    imagePickController.showsCameraControls = NO;
    [self presentViewController:imagePickController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *oImage = info[@"UIImagePickerControllerOriginalImage"];
    [self compressionImage:oImage andCompressionQuality:XCZPublishTextPhoneViewPhoneQuality];
    [self requestPostImage:self.chouImage andIndex:0 andImages:nil];
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

- (void)dealloc
{
    self.phoneManager = nil;
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

/**
 *  缩小图片到指定尺寸大小
 *
 *  @param image 原始图片
 *  @param size  目标大小
 *
 *  @return 生成图片
 */
-(UIImage *)compressOriginalImage:(UIImage *)image toSize:(CGSize)size{
    UIImage * resultImage = image;
    UIGraphicsBeginImageContext(size);
    [resultImage drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIGraphicsEndImageContext();
    return image;
}

- (void)compressionImage:(UIImage *)image andCompressionQuality:(CGFloat)quality
{
    NSData *imageData = UIImageJPEGRepresentation(image, quality);
    UIImage *newImage = [UIImage imageWithData:imageData];
    
    if (imageData.length/1024 >= 160) {
        UIImage *scImage = [self scaleToSize:newImage size:CGSizeMake(newImage.size.width * XCZPublishTextPhoneViewPhoneScaleToSize, newImage.size.height * XCZPublishTextPhoneViewPhoneScaleToSize)];
        NSData *data = UIImageJPEGRepresentation(scImage, quality);
        [self compressionImage:[UIImage imageWithData:data] andCompressionQuality:quality];
    } else {
        self.chouImage = newImage;
    }
}

#pragma mark 裁剪照片
-(UIImage *)scaleToSize:(UIImage *)image size:(CGSize)size
{
    //创建一个bitmap的context
    //并把他设置成当前的context
    UIGraphicsBeginImageContext(size);
    //绘制图片的大小
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //从当前context中创建一个改变大小后的图片
    UIImage *endImage=UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return endImage;
}

@end
