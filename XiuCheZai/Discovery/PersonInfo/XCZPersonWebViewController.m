//
//  XCZPersonWebViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/26.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonWebViewController.h"
#import "XCZConfig.h"

@interface XCZPersonWebViewController()

@property (nonatomic) UIButton *backButton;
@property (nonatomic) int backOffset;

@property (nonatomic) BOOL fullScreen;
@property (nonatomic) BOOL needsRefresh;

@end


@implementation XCZPersonWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.needsRefresh = YES;
}

- (void)viewWillLayoutSubviews {
    if (!self.fullScreen) {
        self.tabBarController.tabBar.hidden = NO;
        CGRect rect = [UIScreen mainScreen].bounds;
        rect.size.height -= self.tabBarController.tabBar.bounds.size.height;
        self.view.frame = rect;
    } else {
        self.tabBarController.tabBar.hidden = YES;
        self.view.frame = [UIScreen mainScreen].bounds;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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
    self.fullScreen = ![request.URL.description isEqualToString:self.url.description]
    || [self.url.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/community/index/"]];
    [self viewWillLayoutSubviews];
    
    self.needsRefresh = !([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/save_info/index.html"]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/refund/index.html?orderId="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/community/publish/index.html?session_key="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/community/publish/index.html?post_id="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/userinfo/index.html"]]
                          /*
                           || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/service/index/index.html"]]
                           || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Car_Brand/index.html"]]
                           */
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/add_mycar/index.html"]]);
    
    if ([request.URL.description isEqualToString:[XCZConfig baseURL]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/index.html"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/newIndex/index.html"]]) {
        [self goHome];
        return NO;
    }
    /*
     if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/shopping-cart/index.html"]]
     && self.tabBarController.selectedIndex != TabIndexCart) {
     [self goCart];
     return NO;
     }
     if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/shopping-cart/index.html"]]
     && navigationType == UIWebViewNavigationTypeBackForward) {
     [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/shopping-cart/index.html"]]]];
     return NO;
     }
     */
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/my_index/index.html"]]
        && self.tabBarController.selectedIndex != TabIndexMine) {
        [self goMine];
        return NO;
    }
    
    if ([request.URL.host isEqualToString:@"mcashier.95516.com"]) {
        if (!self.backButton) [self addBackButton];
        self.backOffset++;
        return YES;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/m-center/my_car/index.html"]]) {
        sleep(0.5);
        return YES;
    }
    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Login/login/login.html"]]) {
        NSLog(@"来到了登录这里");
        return YES;
    }
    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/bbs/car-club/index.html"]]) { // bbs首页
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    
    return YES;
}

- (void)goBack {
    if (self.webView.isLoading) [self.webView stopLoading];
    if ([self.webView.request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/detail/index.html?goodsId"]]) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    if (![self.webView.request.URL.description isEqualToString:self.url.description]) [self.webView goBack];
    else [self goHome];
}

- (void)goHome {
    if (self.webView.isLoading) [self.webView stopLoading];
    if (self.tabBarController.selectedIndex != TabIndexHome) self.tabBarController.selectedIndex = TabIndexHome;
    else [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)goCart {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexCart;
}

- (void)goMine {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexMine;
}

- (void)addBackButton {
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(11.0, 8.0, 28.0, 28.0)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"common_back_150.png"] forState:UIControlStateNormal];
    [self.backButton addTarget:self action:@selector(tapBackButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.webView addSubview:self.backButton];
}

- (void)tapBackButton:(id)sender {
    [self.backButton removeFromSuperview];
    self.backButton = nil;
    [self executeJavascript:[NSString stringWithFormat:@"history.go(%d)", -self.backOffset]];
    self.backOffset = 0;
}

- (void)executeJavascript:(NSString *)javascript  {
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

//- (void)launchWebViewWithURLString:(NSString *)urlString
//{
//    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
//    webViewController.url = [NSURL URLWithString:urlString];
//    webViewController.hidesBottomBarWhenPushed = YES;
////    self.navigationController
//    NSLog(@"来到来哦这里:%@", self.navCtr);
//    
//    [self.navCtr pushViewController:webViewController animated:YES];
//
//}


@end
