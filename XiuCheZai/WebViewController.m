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

@import MapKit;

@interface WebViewController () <UIWebViewDelegate, WXApiDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic) UIButton *backButton;
@property (nonatomic) int backOffset;
@property (nonatomic) UIView *errorView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    
    ((AppDelegate *)[UIApplication sharedApplication].delegate).wxApiDelegate = self;
    [self registerUserAgent];
    self.webView.delegate = self;
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    if (self.errorView.superview) [self.errorView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // [self pickImage];
}

- (void)registerUserAgent {
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@/%@", [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"], @"APP8673h", [Config version]];
    [[NSUserDefaults standardUserDefaults] registerDefaults:[[NSDictionary alloc] initWithObjectsAndKeys:userAgent, @"UserAgent", nil]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // NSLog(@"request.URL : %@", request.URL);
    if ([request.URL.description containsString:@"about:blank"]) {
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"qsh"]) {
        return [self handleCommandWithRequest:request];
    }
    return [self handleNavigationWithRequest:request navigationType:navigationType];
}

- (BOOL)handleCommandWithRequest:(NSURLRequest *)request {
    // NSLog(@"handleCommandWithRequest : %@", request.URL);
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
    // NSLog(@"web.handleNavigationWithRequest : %@", request.URL);
    if ([request.URL.description isEqualToString:[Config baseURL]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/newIndex/index.html"]]) {
        [self goHome];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/service/index/index.html"]]) {
        [self goStore];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Car_Brand/index.html"]]) {
        [self goAccessory];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]]) {
        [self goCart];
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
    
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    NSLog(@"error : %@", error);
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (error.code != -999) {
        [self.webView stopLoading];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[[NSBundle mainBundle] URLForResource:@"error" withExtension:@"html"]]];
        /*
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
        UIButton *backBarButton = [[UIButton alloc] initWithFrame:CGRectMake(10.0, 12.0, 17.0, 17.0)];
        [backBarButton setBackgroundImage:[UIImage imageNamed:@"common_back.png"] forState:UIControlStateNormal];
        [backBarButton addTarget:self action:@selector(goHome) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBarButton];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        self.navigationItem.title = @"网络连接失败";
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 120.0, 120.0)];
        imageView.image = [UIImage imageNamed:@"common_error.png"];
        imageView.center = self.view.center;
        [self.view addSubview:imageView];
        self.errorView = imageView;
         */
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

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // NSString *server = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/WebUploadServlet.action"];
    NSString *server = [NSString stringWithFormat:@"%@%@", [Config webBaseURL], @"/WebUploadServlet.action"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.8);
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:server parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:data name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
                                                                              } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // NSLog(@"uploadProgress : %@", uploadProgress);
        });
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        if (![[responseInfo objectForKey:@"filepath"] length]) {
            // [picker dismissViewControllerAnimated:YES completion:nil];
            [self executeJavascript:[NSString stringWithFormat:@"pickImageResult(\"\")"]];
            return;
        }
        // [picker dismissViewControllerAnimated:YES completion:nil];
        [self executeJavascript:[NSString stringWithFormat:@"pickImageResult(\"%@\")", [responseInfo objectForKey:@"filepath"]]];
        // NSLog(@"filepath : %@", [responseInfo objectForKey:@"filepath"]);
    }];
    [uploadTask resume];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self executeJavascript:[NSString stringWithFormat:@"pickImageResult(\"\")"]];
}

- (void)navigateToPlace:(NSDictionary *)place {
    // NSLog(@"navigateToPlace : %@", place);
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
    // NSLog(@"options : %@", options);
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
    // NSLog(@"options : %@", options);
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
    // NSLog(@"options : %@", options);
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
