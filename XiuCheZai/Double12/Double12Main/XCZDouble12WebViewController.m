//
//  XCZDouble12WebViewController.m
//  XiuCheZai
//
//  Created by 企商汇 on 16/11/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDouble12WebViewController.h"
#import "XCZConfig.h"

@interface XCZDouble12WebViewController ()



@end

@implementation XCZDouble12WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (BOOL)handleNavigationWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
//    NSLog(@"description:%@", request.URL.description);
//    
//    if ([request.URL.description isEqualToString:[Config baseURL]]
//        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/"]]
//        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"]]
//        || [request.URL.description isEqualToString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/newIndex/index.html"]]) {
//        [self goHome];
//        return NO;
//    }
//    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Login/login/login.html"]]) {
        return YES;
    }
    
    if ([request.URL.description containsString:[NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/bbs/car-club/index.html"]]) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return NO;
    }
    
    [super handleNavigationWithRequest:request navigationType:navigationType];
    return YES;
}

- (void)goHome {
    if (self.webView.isLoading) [self.webView stopLoading];
    if (self.tabBarController.selectedIndex != TabIndexHome) self.tabBarController.selectedIndex = TabIndexHome;
    else [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)backBtnDidClick:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:@(1) forKey:@"Double12LoginStatu"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.navigationController popViewControllerAnimated:YES];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
