//
//  TabViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/12.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "TabViewController.h"
#import "Config.h"

@interface TabViewController ()

@property (nonatomic) UIButton *backButton;
@property (nonatomic) int backOffset;

@property (nonatomic) BOOL fullScreen;
@property (nonatomic) BOOL needsRefresh;
@property (nonatomic) BOOL showBack;

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fullScreen = NO;
    self.needsRefresh = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (self.needsRefresh) [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
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

- (BOOL)handleNavigationWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"webView.request : %@", request.URL);
    /*
    if ([request.URL.host isEqualToString:@"m.8673h.com"]) {
        if (self.backButton) [self.backButton removeFromSuperview];
        self.showBack = NO;
    }
     */
    
    self.fullScreen = !([request.URL.description isEqualToString:self.url.description]
                        || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/bbs/index.html"]]
                        || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/bbs/forum/index.html"]]
                        || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/bbs/ad/index.html"]]
                        || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/bbs/car-club/index.html"]]);
    [self viewWillLayoutSubviews];
    
    self.needsRefresh = !([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/save_info/index.html"]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/refund/index.html?orderId="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/community/publish/index.html?session_key="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/community/publish/index.html?post_id="]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/userinfo/index.html"]]
                          || [request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/add_mycar/index.html"]]);
    
    if ([request.URL.description isEqualToString:[Config baseURL]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/newIndex/index.html"]]) {
        [self goHome];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_index/index.html"]]
        && self.tabBarController.selectedIndex != TabIndexMine) {
        [self goMine];
        return NO;
    }
    
    if ([request.URL.host isEqualToString:@"mcashier.95516.com"]) {
        // if (!self.backButton) [self addBackButton];
        if (!self.backButton) [self addBackButtonFor95516];
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
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    if (self.showBack) {
        if (!self.backButton) [self addBackButton];
        self.backOffset++;
        self.showBack = NO;
    }
}

- (void)goBack {
    if (self.webView.isLoading) [self.webView stopLoading];
    if (![self.webView.request.URL.description isEqualToString:self.url.description]) [self.webView goBack];
    else [self goHome];
}

- (void)goHome {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexHome;
    [(UINavigationController *)[self.tabBarController.viewControllers firstObject] popToRootViewControllerAnimated:NO];
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

- (void)addBackButtonFor95516 {
    /*
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(11.0, 8.0, 28.0, 28.0)];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"common_back_150.png"] forState:UIControlStateNormal];
     */
    /*
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(tapBackButton:)];
    self.navigationItem.title = @"银联在线";
    [self.navigationController setNavigationBarHidden:NO animated:NO];
     */
    self.backButton = [[UIButton alloc] initWithFrame:CGRectMake(11.0, 8.0, 60.0, 28.0)];
    self.backButton.backgroundColor = [UIColor colorWithRed:95.0/255.0 green:164/255.0 blue:216.0/255.0 alpha:1.0];
    self.backButton.layer.cornerRadius = 4.0;
    UIImageView *backImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"common_back_150"]];
    backImageView.frame = CGRectMake(0, 0, 28.0, 28.0);
    [self.backButton addSubview:backImageView];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
