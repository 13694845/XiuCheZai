//
//  WebViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/1/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "Config.h"
#import "URLEncoder.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "GoodsDetailViewController.h"
#import "ChatViewController.h"

@import MapKit;

@interface WebViewController () <UIWebViewDelegate, WXApiDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *manager;

@property (nonatomic) UIButton *backButton;
@property (nonatomic) int backOffset;
@property (nonatomic) BOOL showBack;

@end

@implementation WebViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).wxApiDelegate = self;
    [self registerUserAgent];
    [self updateLocation];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    if ([self isMemberOfClass:[WebViewController class]]) [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)updateLocation {
    NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *longitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
    NSString *latitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/CityLocation.do"];
    NSDictionary *parameters = ![longitude isEqualToString:@"0.000000"] ? @{@"lng":longitude, @"lat":latitude, @"type":@"1"} : @{};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([self isMemberOfClass:[WebViewController class]]) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)registerUserAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@/%@", [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"], @"APP8673h", [Config version]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // NSLog(@"webView.request : %@", request.URL);
    if ([request.URL.description containsString:@"about:blank"]) {
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"qsh"]) {
        return [self handleCommandWithRequest:request];
    }
    return [self handleNavigationWithRequest:request navigationType:navigationType];
}

- (BOOL)handleCommandWithRequest:(NSURLRequest *)request {
    NSString *command = request.URL.host;
    NSDictionary *parameter;
    NSString *query = [request.URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (query) parameter = [NSJSONSerialization JSONObjectWithData:[query dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
    if (parameter) command = [command stringByAppendingString:@":"];
    SEL selector = NSSelectorFromString(command);
    if ([self respondsToSelector:selector]) [self performSelector:NSSelectorFromString(command) withObject:parameter afterDelay:0.0];
    return NO;
}

- (BOOL)handleNavigationWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.description isEqualToString:[Config baseURL]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/newIndex/index.html"]]) {
        [self goHome];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_index/index.html"]]) {
        [self goMine];
        return NO;
    }
    
    if ([request.URL.host isEqualToString:@"mcashier.95516.com"]) {
        if (!self.backButton) [self addBackButton];
        self.backOffset++;
        return YES;
    }
    if ([request.URL.host isEqualToString:@"mobile.abchina.com"]) {
        self.showBack = YES;
        return YES;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_car/index.html"]]) {
        sleep(0.5);
        return YES;
    }
    
    /*
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/massage/massage.jsp"]]) {
        NSLog(@"/massage/massage.jsp");
        [self chatWithUserReceiverId:@"123"];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/massage/communicate.jsp?bid="]]) {
        NSLog(@"/massage/communicate.jsp?bid=");
        [self chatWithUserReceiverId:@"123"];
        return NO;
    }
     */
    
    return YES;
}

- (void)chatWithUserReceiverId:(NSString *)receiverId {
    NSLog(@"chatWithUserReceiverId");
    ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatViewController.receiverId = @"123";
    chatViewController.receiverName = @"lisi";
    chatViewController.receiverAvatar = nil;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)saveCookies {
    NSMutableDictionary *chatSender = [NSMutableDictionary dictionary];
    chatSender[@"senderId"] = @"555";
    chatSender[@"senderName"] = @"zhangsan";
    [[NSUserDefaults standardUserDefaults] setObject:chatSender forKey:@"chatSender"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // [((AppDelegate *)[UIApplication sharedApplication].delegate).chatService stop];
    // [((AppDelegate *)[UIApplication sharedApplication].delegate).chatService start];
}

- (void)recognizeVehicleLicense {
    [self pickImage];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *server = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/CertificatesAction.do?type=2&img_type=6"];
    NSDictionary *parameters = nil;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [self resizeImage:image toSize:CGSizeMake(image.size.width / 2, image.size.height / 2)];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:@"pic" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            hud.progress = uploadProgress.fractionCompleted;
        });
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        [hud hide:YES];
        hud.progress = 0;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:responseObject options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        [self executeJavascript:[NSString stringWithFormat:@"recognizeVehicleLicenseResult('%@')", jsonString]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [hud hide:YES];
        hud.progress = 0;
    }];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.showBack) {
        if (!self.backButton) [self addBackButton];
        self.backOffset++;
        self.showBack = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error.code != -999) {
        [self.webView stopLoading];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"error" withExtension:@"html"]]];
    }
}

- (void)goBack {
    if (self.webView.isLoading) [self.webView stopLoading];
    if ([self.webView canGoBack]) [self.webView goBack];
    else [self.navigationController popViewControllerAnimated:YES];
}

- (void)goHome {
    if (self.webView.isLoading) [self.webView stopLoading];
    if (self.tabBarController.selectedIndex != TabIndexHome) self.tabBarController.selectedIndex = TabIndexHome;
    else [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goStore {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexStore;
}

- (void)goAccessory {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexAccessory;
}

- (void)goCart {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexCart;
}

- (void)goMine {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexMine;
}

- (void)alipayOrder:(NSDictionary *)order {
    NSString *appScheme = @"qsh";
    
    NSMutableArray *orderStrings = [NSMutableArray array];
    for (NSString *key in [order.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        if (![key isEqualToString:@"sign"] && ![key isEqualToString:@"sign_type"]) {
            [orderStrings addObject:[NSString stringWithFormat:@"%@=%@", key, [order objectForKey:key]]];
        }
    }
    [orderStrings addObject:[NSString stringWithFormat:@"sign=\"%@\"", [self encodeString:[order objectForKey:@"sign"]]]];
    [orderStrings addObject:[NSString stringWithFormat:@"sign_type=\"%@\"", [order objectForKey:@"sign_type"]]];
    
    [[AlipaySDK defaultService] payOrder:[orderStrings componentsJoinedByString:@"&"] fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        [self executeJavascript:[NSString stringWithFormat:@"alipayResult(\"%@\")", [resultDic objectForKey:@"resultStatus"]]];
    }];
}

- (void)isWXAppInstalled {
    [self executeJavascript:[NSString stringWithFormat:@"isWXAppInstalledResult(\"%d\")", [WXApi isWXAppInstalled]]];
}

- (void)wxpayOrder:(NSDictionary *)order {
    NSString *partnerId = @"1296087901";
    
    PayReq *payReq = [[PayReq alloc] init];
    payReq.partnerId = partnerId;
    payReq.prepayId = [order objectForKey:@"prepayid"];
    payReq.nonceStr = [order objectForKey:@"noncestr"];
    payReq.timeStamp = ((NSString *)[order objectForKey:@"timestamp"]).intValue;
    payReq.package = @"Sign=WXPay";
    payReq.sign = [order objectForKey:@"sign"];
    
    [WXApi sendReq:payReq];
}

- (void)wxshareMessage:(NSDictionary *)message {
    WXMediaMessage *webpageMessage = [WXMediaMessage message];
    webpageMessage.title = [message objectForKey:@"title"];
    webpageMessage.description = [message objectForKey:@"description"];
    [webpageMessage setThumbImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[message objectForKey:@"thumbImageUrl"]]]]];
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [message objectForKey:@"webpageUrl"];
    webpageMessage.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = webpageMessage;
    if ([[message objectForKey:@"scene"] isEqualToString:@"Session"]) req.scene = WXSceneSession;
    if ([[message objectForKey:@"scene"] isEqualToString:@"Timeline"]) req.scene = WXSceneTimeline;
    if ([[message objectForKey:@"scene"] isEqualToString:@"Favorite"]) req.scene = WXSceneFavorite;
    
    [WXApi sendReq:req];
}

- (void)wxshare:(NSDictionary *)message {
    CGFloat const kImageMaxWidth = 250.0;
    CGFloat const kImageMaxHeight = 250.0;
    
    WXMediaMessage *webpageMessage = [WXMediaMessage message];
    webpageMessage.title = [message objectForKey:@"title"];
    webpageMessage.description = [message objectForKey:@"description"];
    
    UIImage *thumbImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[message objectForKey:@"thumbImageUrl"]]]];
    if (thumbImage.size.width > kImageMaxWidth) {
        thumbImage = [self resizeImage:thumbImage toSize:CGSizeMake(kImageMaxWidth, thumbImage.size.height * (kImageMaxWidth / thumbImage.size.width))];
    }
    if (thumbImage.size.height > kImageMaxHeight) {
        thumbImage = [self resizeImage:thumbImage toSize:CGSizeMake(thumbImage.size.width * (kImageMaxHeight / thumbImage.size.height), kImageMaxHeight)];
    }
    [webpageMessage setThumbImage:thumbImage];
    WXWebpageObject *webpageObject = [WXWebpageObject object];
    webpageObject.webpageUrl = [message objectForKey:@"webpageUrl"];
    webpageMessage.mediaObject = webpageObject;
    
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = webpageMessage;
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if ([WXApi isWXAppInstalled]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"分享给朋友" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            req.scene = WXSceneSession;
            [WXApi sendReq:req];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"分享到朋友圈" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            req.scene = WXSceneTimeline;
            [WXApi sendReq:req];
        }]];
    } else {
        alertController.message = @"没有安装微信";
    }
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)wxlogin {
    SendAuthReq *req = [[SendAuthReq alloc] init];
    req.scope = @"snsapi_userinfo";
    req.state = @"123";
    [WXApi sendReq:req];
}

- (void)onResp:(BaseResp *)resp {
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (resp.errCode) {
            [self executeJavascript:[NSString stringWithFormat:@"wxloginResult(\"\")"]];
            return;
        }
        [self executeJavascript:[NSString stringWithFormat:@"wxloginResult(\"%@\")", ((SendAuthResp *)resp).code]];
        return;
    }
    if ([resp isKindOfClass:[PayReq class]]) {
        [self executeJavascript:[NSString stringWithFormat:@"wxpayResult(\"%d\")", resp.errCode]];
        return;
    }
    if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        [self executeJavascript:[NSString stringWithFormat:@"wxshareMessageResult(\"%d\")", resp.errCode]];
        return;
    }
}

- (void)executeJavascript:(NSString *)javascript  {
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (NSString *)encodeString:(NSString *)string {
    return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                 (__bridge CFStringRef)string,
                                                                                 NULL,
                                                                                 (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8);
}

- (void)addBackButton {
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 12.0, 20.0, 20.0)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"common_back.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:self.backButton];
}

- (void)tapBackButton:(id)sender {
    [self.backButton removeFromSuperview];
    self.backButton = nil;
    [self executeJavascript:[NSString stringWithFormat:@"history.go(%d)", -self.backOffset]];
    self.backOffset = 0;
}

- (void)requestLocation {
    NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *longitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
    NSString *latitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
    [self executeJavascript:[NSString stringWithFormat:@"requestLocationResult(\"%@\", \"%@\")", longitude, latitude]];
}

- (void)requestUserLocation {
    NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    NSString *longitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
    NSString *latitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
    [self executeJavascript:[NSString stringWithFormat:@"requestUserLocationResult(\"%@\", \"%@\")", longitude, latitude]];
}

- (void)showGoodsDetial:(NSDictionary *)goods {
    GoodsDetailViewController *goodsDetailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"GoodsDetailViewController"];
    goodsDetailViewController.hidesBottomBarWhenPushed = YES;
    goodsDetailViewController.goodsId = [goods objectForKey:@"goodsId"];
    [self.navigationController pushViewController:goodsDetailViewController animated:YES];
}

- (void)pickImage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择图片来源" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pickImage:@{@"source":@"Camera"}];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"图库" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self pickImage:@{@"source":@"PhotoLibrary"}];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)pickImage:(NSDictionary *)source {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    if ([[source objectForKey:@"source"] isEqualToString:@"Camera"]) imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([[source objectForKey:@"source"] isEqualToString:@"PhotoLibrary"]) imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)navigateToPlace:(NSDictionary *)place {
    if (![[[[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"] objectForKey:@"longitude"] doubleValue]) {
        NSString *message = @"请在iOS\"设置\"-\"隐私\"-\"定位服务\"中打开";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"未获得授权使用定位" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    NSString *message = [NSString stringWithFormat:@"导航到 %@", [place objectForKey:@"name"]];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择地图APP" message:message preferredStyle:UIAlertControllerStyleActionSheet];
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"百度地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            NSString *destination = [NSString stringWithFormat:@"latlng:%@,%@|name:%@", [place objectForKey:@"latitude"], [place objectForKey:@"longitude"], [place objectForKey:@"name"]];
            [self launchBadiumap:@{@"service":@"direction", @"destination":destination, @"mode":@"driving"}];
        }];
        [alertController addAction:action];
    }
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"高德地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self launchAmap:@{@"service":@"path",
                               @"dlat":[place objectForKey:@"latitude"], @"dlon":[place objectForKey:@"longitude"], @"dname":[place objectForKey:@"name"], @"t":@"0"}];
        }];
        [alertController addAction:action];
    }
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"苹果地图" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self launchIOSMap:place];
    }];
    [alertController addAction:action];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)isBadiumapAppInstalled {
    [self executeJavascript:[NSString stringWithFormat:@"isBadiumapAppInstalledResult(\"%d\")",
                              [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://map/"]]]];
}

- (void)launchBadiumap:(NSDictionary *)options {
    NSString *origin = [options objectForKey:@"origin"];
    if (!origin.length) {
        NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
        NSString *longitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
        NSString *latitude = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
        origin = [NSString stringWithFormat:@"latlng:%@,%@|name:当前位置", latitude, longitude];
    }
    NSString *URLString = [NSString stringWithFormat:@"baidumap://map/%@?origin=%@&destination=%@&mode=%@&coord_type=wgs84", [options objectForKey:@"service"],
                           [URLEncoder encodeURLString:origin], [URLEncoder encodeURLString:[options objectForKey:@"destination"]], [options objectForKey:@"mode"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

- (void)isAmapAppInstalled {
    [self executeJavascript:[NSString stringWithFormat:@"isAmapAppInstalledResult(\"%d\")",
                             [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]]];
}

- (void)launchAmap:(NSDictionary *)options {
    NSString *slat = [options objectForKey:@"slat"];
    NSString *slon = [options objectForKey:@"slon"];
    NSString *sname = [options objectForKey:@"sname"];
    if (!slat.length) {
        NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
        slon = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"longitude"] doubleValue]];
        slat = [NSString stringWithFormat:@"%.6f", [[locationInfo objectForKey:@"latitude"] doubleValue]];
        sname = @"当前位置";
    }
    NSString *URLString =
        [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%@&slon=%@&sname=%@&did=BGVIS2&dlat=%@&dlon=%@&dname=%@&dev=1&m=0&t=%@",
                slat, slon, [URLEncoder encodeURLString:sname],
                [options objectForKey:@"dlat"], [options objectForKey:@"dlon"], [URLEncoder encodeURLString:[options objectForKey:@"dname"]], [options objectForKey:@"t"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
}

- (void)launchIOSMap:(NSDictionary *)options {
    NSDictionary *locationInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLocation"];
    CLLocationCoordinate2D originCoordinate = CLLocationCoordinate2DMake([[locationInfo objectForKey:@"latitude"] doubleValue],
                                                                         [[locationInfo objectForKey:@"longitude"] doubleValue]);
    MKMapItem *originMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:originCoordinate addressDictionary:nil]];
    originMapItem.name = @"当前位置";
    CLLocationCoordinate2D destinationCoordinate = CLLocationCoordinate2DMake([[options objectForKey:@"latitude"] doubleValue], [[options objectForKey:@"longitude"] doubleValue]);
    MKMapItem *destinationMapItem = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:destinationCoordinate addressDictionary:nil]];
    destinationMapItem.name = [options objectForKey:@"name"];
    NSArray *items = @[originMapItem, destinationMapItem];
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                    MKLaunchOptionsMapTypeKey:[NSNumber numberWithInteger:MKMapTypeStandard],
                                    MKLaunchOptionsShowsTrafficKey:@YES};
    [MKMapItem openMapsWithItems:items launchOptions:launchOptions];
}

- (void)pickPlaceAroundService:(NSDictionary *)service {
    service = @{@"serviceId":@"3255",
                @"serviceName":@"黄岩检测站椒江分站（仅限蓝牌车）",
                @"serviceAddress":@"台州市疏港大道椒江段2250号3幢一楼",
                @"serviceLongitude":@"121.463111",
                @"serviceLatitude":@"28.641178"};
    NSDictionary *place = @{@"placeName":@"黄岩检测站椒江分站（仅限蓝牌车）",
                            @"placeAddress":@"台州市疏港大道椒江段2250号3幢一楼",
                            @"placeLongitude":@"121.463111",
                            @"placeLatitude":@"28.641178"};
    [self feeForPlace:place aroundService:service];
}

- (void)feeForPlace:(NSDictionary *)place aroundService:(NSDictionary *)service {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/KiloCalculateServlet.do"];
    NSDictionary *parameters = @{@"lng":place[@"placeLongitude"], @"lat":place[@"placeLatitude"], @"type":@"5", @"user_id":service[@"serviceId"], @"is_fee":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"parameters : %@", parameters);
        NSLog(@"responseObject : %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
