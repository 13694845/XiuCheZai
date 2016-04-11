//
//  ViewController.m
//  XiuCheZai
//
//  Created by QSH on 15/12/18.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "HomeViewController.h"
#import "BannerView.h"
#import "MenuViewController.h"
#import "WebViewController.h"
#import "Config.h"
#import "AFNetworking.h"

@interface HomeViewController () <UIScrollViewDelegate, BannerDelegate>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *myCarButton;
@property (weak, nonatomic) IBOutlet BannerView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *buttonPageA;
@property (weak, nonatomic) IBOutlet UIView *buttonPageB;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

@property (weak, nonatomic) IBOutlet UIView *floatView;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    
    self.topView.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:0.0];
    self.bannerView.delegate = self;
    for (UIView *view in self.bannerView.subviews) {
        [view removeFromSuperview];
    }
    [self.floatView removeFromSuperview];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@/%@", [manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]];
    [manager.requestSerializer setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"statu"] isEqualToString:@"0"]) {
            [self.myCarButton setTitle:nil forState:UIControlStateNormal];
            [self.myCarButton setBackgroundImage:[UIImage imageNamed:@"home_mycar.png"] forState:UIControlStateNormal];
            [self.myCarButton removeTarget:self action:@selector(toLogin:) forControlEvents:UIControlEventTouchUpInside];
            [self.myCarButton addTarget:self action:@selector(toMyCar:) forControlEvents:UIControlEventTouchUpInside];
        } else {
            [self.myCarButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self.myCarButton setTitle:@"登录" forState:UIControlStateNormal];
            [self.myCarButton removeTarget:self action:@selector(toMyCar:) forControlEvents:UIControlEventTouchUpInside];
            [self.myCarButton addTarget:self action:@selector(toLogin:) forControlEvents:UIControlEventTouchUpInside];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.buttonPageA.frame.origin.x == self.buttonPageB.frame.origin.x) {
        CGRect rectA = self.buttonPageA.frame;
        rectA.origin.x = 0;
        self.buttonPageA.frame = rectA;
        CGRect rectB = self.buttonPageB.frame;
        rectB.origin.x = self.buttonPageB.bounds.size.width;
        self.buttonPageB.frame = rectB;
        self.pageControl.currentPage = 0;
        UISwipeGestureRecognizer *swipeGestureRecognizerA = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeButtonPage:)];
        swipeGestureRecognizerA.direction = UISwipeGestureRecognizerDirectionLeft;
        [self.buttonPageA addGestureRecognizer:swipeGestureRecognizerA];
        UISwipeGestureRecognizer *swipeGestureRecognizerB = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeButtonPage:)];
        swipeGestureRecognizerB.direction = UISwipeGestureRecognizerDirectionRight;
        [self.buttonPageB addGestureRecognizer:swipeGestureRecognizerB];
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *urlString = @"https://itunes.apple.com/lookup?id=1064830136";
    NSDictionary *parameters = nil;
    [manager POST:urlString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (((NSNumber *)[responseObject objectForKey:@"resultCount"]).intValue) {}
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)swipeButtonPage:(UISwipeGestureRecognizer *)recognizer {
    CGRect rectA = self.buttonPageA.frame;
    CGRect rectB = self.buttonPageB.frame;
    if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        rectA.origin.x -= self.buttonPageA.bounds.size.width;
        rectB.origin.x -= self.buttonPageB.bounds.size.width;
        self.pageControl.currentPage = 1;
    } else {
        rectA.origin.x += self.buttonPageA.bounds.size.width;
        rectB.origin.x += self.buttonPageB.bounds.size.width;
        self.pageControl.currentPage = 0;
    }
    [UIView animateWithDuration:0.4 animations:^{
        self.buttonPageA.frame = rectA;
        self.buttonPageB.frame = rectB;
    }];
}

#define BANNER_HEIGHT 170.0

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    self.topView.alpha = 1.0 + offset.y / 10.0;
    if (offset.y >= 0 && offset.y <= BANNER_HEIGHT) {
        self.topView.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0 / BANNER_HEIGHT * offset.y];
    }
}

- (IBAction)toMenu:(id)sender {
    MenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
    [self addChildViewController:menuViewController];
    menuViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
    CGRect rect = menuViewController.view.frame;
    rect.origin.x -= rect.size.width;
    menuViewController.view.frame = rect;
    [self.view addSubview:menuViewController.view];
    rect.origin.x = 0;
    [UIView animateWithDuration:0.3 animations:^{
        menuViewController.view.frame = rect;
    }];
}

- (IBAction)toSearch:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html"]];
}

- (void)bannerView:(BannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo {
    if ([[bannerInfo objectForKey:@"url"] length])
        [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], [bannerInfo objectForKey:@"url"]]];
}

- (IBAction)toQuickLaunch:(id)sender {
    self.tabBarController.selectedIndex = TabIndexAccessory;
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)toMyCar:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_car/index.html"]];
}

- (void)toLogin:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/Login/login/login.html?url=", [Config baseURL]]];
}

- (IBAction)toWholeMaintain:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/index.html"]];
}

- (IBAction)toPartMaintain:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/product.html?type=2"]];
}

- (IBAction)toReplaceTire:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/product.html?type=1"]];
}

- (IBAction)toAppointMOT:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/annualCheck-car/index.html"]];
}

- (IBAction)toBuyInsurance:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/free_maintain/index/index.html"]];
}

- (IBAction)toDrivingRecorder:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/car-record/index.html"]];
}

- (IBAction)toVideoMusic:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270100&title=%E5%BD%B1%E9%9F%B3%E5%AF%BC%E8%88%AA"]];
}

- (IBAction)toInterior:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270300&title=%E5%86%85%E9%A5%B0%E7%94%A8%E5%93%81"]];
}

- (IBAction)toBrakeBlock:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170700&title=%E5%88%B9%E8%BD%A6%E7%89%87"]];
}

- (IBAction)toACFilter:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=200800&title=%E7%A9%BA%E8%B0%83%E6%BB%A4%E8%8A%AF"]];
}

- (IBAction)toSparkPlug:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=110100&title=%E7%81%AB%E8%8A%B1%E5%A1%9E"]];
}

- (IBAction)toMaintainRecord:(id)sender {
}

- (IBAction)toActivity01:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/award/index.html"]];
}

- (IBAction)toActivity02:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list_maintain/index.html?parts_cate_id=280200&sub_cate_id=280205"]];
}

- (IBAction)toActivity03:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/ad/free_share/index.html"]];
}

- (IBAction)toActivity04:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/99yang/index/9yang.html"]];
}

- (IBAction)toMoreActivity:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/ad/activity/index.html"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
