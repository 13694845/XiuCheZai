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

@end

@implementation TabViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // NSLog(@"Tab URL : %@", request.URL);
    if ([request.URL.description containsString:@"about:blank"]) {
        return NO;
    }
    if ([request.URL.scheme isEqualToString:@"qsh"]) {
        NSString *command = request.URL.host;
        NSDictionary *parameter;
        NSString *query = [request.URL.query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if (query) parameter = [NSJSONSerialization JSONObjectWithData:[query dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
        if (parameter) command = [command stringByAppendingString:@":"];
        SEL selector = NSSelectorFromString(command);
        if ([self respondsToSelector:selector]) [self performSelector:NSSelectorFromString(command) withObject:parameter afterDelay:0.0];
        return NO;
    }
    
    if ([request.URL.description isEqualToString:[Config baseURL]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"]]
        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/newIndex/index.html"]]) {
        [self goHome];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]]
        && self.tabBarController.selectedIndex != TabIndexCart) {
        [self goCart];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]]
        && navigationType == UIWebViewNavigationTypeBackForward) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/shopping-cart/index.html"]]]];
        return NO;
    }
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_index/index.html"]]
        && self.tabBarController.selectedIndex != TabIndexMine) {
        [self goMine];
        return NO;
    }
    
    if ([request.URL.host isEqualToString:@"mcashier.95516.com"]) {
        if (!self.backButton) [self addBackButton];
        self.backOffset++;
        return YES;
    }
    
    if ([request.URL.description containsString:self.url.description]) {
        self.tabBarController.tabBar.hidden = NO;
        CGRect rect = [UIScreen mainScreen].bounds;
        rect.size.height -= self.tabBarController.tabBar.bounds.size.height;
        self.view.frame = rect;
    } else {
        self.tabBarController.tabBar.hidden = YES;
        self.view.frame = [UIScreen mainScreen].bounds;
    }
    
    return YES;
}

- (void)goBack {
    if (self.webView.isLoading) [self.webView stopLoading];
    if (![self.webView.request.URL.description isEqualToString:self.url.description]) [self.webView goBack];
    else [self goHome];
}

- (void)goHome {
    if (self.webView.isLoading) [self.webView stopLoading];
    self.tabBarController.selectedIndex = TabIndexHome;
    [((UINavigationController *)self.tabBarController.selectedViewController) popToRootViewControllerAnimated:NO];
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

- (void)executeJavascript:(NSString *)javascript  {
    [self.webView stringByEvaluatingJavaScriptFromString:javascript];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
