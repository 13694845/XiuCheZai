//
//  XCZPersonWebViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/9/26.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZPersonWebViewController.h"
#import "XCZConfig.h"
#import "XCZDiscoveryFrameViewController.h"

@interface XCZPersonWebViewController()

@property (nonatomic) UIButton *backButton;
@property (nonatomic) int backOffset;

@property (nonatomic) BOOL fullScreen;
@property (nonatomic) BOOL needsRefresh;

@end


@implementation XCZPersonWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)handleNavigationWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/index.html"]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Login/login/login.html"]]) {
        return YES;
    }
    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/bbs/car-club/index.html"]]) { // bbs首页
        [[NSUserDefaults standardUserDefaults] setObject:@(0) forKey:@"discoverLoginStatu"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    [super handleNavigationWithRequest:request navigationType:navigationType];
    return YES;
}


@end
