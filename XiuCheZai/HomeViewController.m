//
//  ViewController.m
//  XiuCheZai
//
//  Created by QSH on 15/12/18.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "HomeViewController.h"
#import "BannerView.h"
#import "ReminderView.h"
#import "RecommenderCollectionViewCell.h"
#import "MenuViewController.h"
#import "ScannerViewController.h"
#import "WebViewController.h"
#import "Config.h"
#import "AFNetworking.h"
#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "ChatViewController.h"

@import AVFoundation;

@interface HomeViewController () <UIScrollViewDelegate, ScannerViewControllerDelegate, BannerViewDataSource, BannerViewDelegate, ReminderViewDataSource,
                                    UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *buttonPageA;
@property (weak, nonatomic) IBOutlet UIView *buttonPageB;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIButton *myCarButton;
@property (weak, nonatomic) IBOutlet BannerView *bannerView;
@property (weak, nonatomic) IBOutlet ReminderView *reminderView;
@property (weak, nonatomic) IBOutlet UICollectionView *recommenderCollectionView;

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (copy, nonatomic) NSArray *banners;
@property (copy, nonatomic) NSArray *buttons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *iconButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *textButtons;
@property (copy, nonatomic) NSString *reminderText;
@property (copy, nonatomic) NSArray *recommenders;

@end

@implementation HomeViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSArray *)banners {
    if (!_banners) _banners = [[NSUserDefaults standardUserDefaults] objectForKey:@"banners"];
    return _banners;
}

- (NSArray *)buttons {
    if (!_buttons) _buttons = [[NSUserDefaults standardUserDefaults] objectForKey:@"buttons"];
    return _buttons;
}

- (NSString *)reminderText {
    if (!_reminderText) _reminderText = @"";
    return _reminderText;
}

- (NSArray *)recommenders {
    if (!_recommenders) _recommenders = [NSArray array];
    return _recommenders;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.topView.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:0.0];
    for (UIView *view in self.bannerView.subviews) [view removeFromSuperview];
    for (UIView *view in self.reminderView.subviews) [view removeFromSuperview];
    for (UIButton *iconButton in self.iconButtons) [iconButton setBackgroundImage:nil forState:UIControlStateNormal];
    for (UIButton *textButton in self.textButtons) [textButton setTitle:nil forState:UIControlStateNormal];
    [self refreshButtons];
    
    self.bannerView.dataSource = self;
    self.bannerView.delegate = self;
    self.reminderView.dataSource = self;
    self.recommenderCollectionView.dataSource = self;
    self.recommenderCollectionView.delegate = self;
    
    [self updateVersion];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    
    [self loadData];
}

- (void)loadData {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if ([[responseObject objectForKey:@"statu"] isEqualToString:@"0"]) {
            [self.myCarButton setTitle:nil forState:UIControlStateNormal];
            // [self.myCarButton setBackgroundImage:[UIImage imageNamed:@"home_mycar_box.png"] forState:UIControlStateNormal];
            [self.myCarButton removeTarget:self action:@selector(toLogin:) forControlEvents:UIControlEventTouchUpInside];
            [self.myCarButton addTarget:self action:@selector(toMyCar:) forControlEvents:UIControlEventTouchUpInside];
            [self defaultCarIcon];
        } else {
            [self.myCarButton setBackgroundImage:nil forState:UIControlStateNormal];
            [self.myCarButton setTitle:@"登录" forState:UIControlStateNormal];
            [self.myCarButton removeTarget:self action:@selector(toMyCar:) forControlEvents:UIControlEventTouchUpInside];
            [self.myCarButton addTarget:self action:@selector(toLogin:) forControlEvents:UIControlEventTouchUpInside];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LunBoAction.do"];
    parameters = @{@"page_id":@"4", @"ad_id":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *banners = [[responseObject objectForKey:@"data"] objectForKey:@"detail"];
        banners = [[banners reverseObjectEnumerator] allObjects];
        if (![self.banners isEqualToArray:banners]) {
            self.banners = banners;
            [self.bannerView reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:banners forKey:@"banners"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LunBoAction.do"];
    parameters = @{@"page_id":@"14", @"ad_id":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *buttons = [[responseObject objectForKey:@"data"] objectForKey:@"detail"];
        if (![self.buttons isEqualToArray:buttons]) {
            self.buttons = buttons;
            [self refreshButtons];
            [[NSUserDefaults standardUserDefaults] setObject:buttons forKey:@"buttons"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/XiaoLaBaAction.do"];
    parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![[responseObject objectForKey:@"data"] count]) {
            self.reminderText = @"手机下单 直供省钱 预约省时 联保省心";
            [self.reminderView reloadData];
            return;
        }
        NSMutableArray *reminders = [NSMutableArray array];
        for (NSDictionary *reminderInfo in [responseObject objectForKey:@"data"]) {
            NSString *text = [NSString stringWithFormat:@"%@在%@/%@km需要%@",
                                      [reminderInfo objectForKey:@"car_no"],
                                      [reminderInfo objectForKey:@"remindtime"],
                                      [reminderInfo objectForKey:@"remindkilo"],
                                      [reminderInfo objectForKey:@"about"]];
            [reminders addObject:text];
        }
        NSString *reminderText = [reminders componentsJoinedByString:@"\n"];
        if (![self.reminderText isEqualToString:reminderText]) {
            self.reminderText = reminderText;
            [self.reminderView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/MobileIndexAction.do"];
    parameters = @{@"site":@"2", @"code":@"1", @"position":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *recommenders = [[responseObject objectForKey:@"data"] objectForKey:@"goods"];
        if (![self.recommenders isEqualToArray:recommenders]) {
            self.recommenders = recommenders;
            [self.recommenderCollectionView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)refreshButtons {
    NSString *const kBannerImageKey = @"img_src";
    NSString *const kBannerTitleKey = @"ad_title";
    
    for (UIButton *iconButton in self.iconButtons) {
        [iconButton setBackgroundImage:nil forState:UIControlStateNormal];
        [iconButton removeTarget:self action:@selector(toLaunchWebView:) forControlEvents:UIControlEventTouchUpInside];
    }
    for (UIButton *textButton in self.textButtons) {
        [textButton setTitle:nil forState:UIControlStateNormal];
        [textButton removeTarget:self action:@selector(toLaunchWebView:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *iconButton = self.iconButtons[i];
        iconButton.tag = i;
        [iconButton sd_setBackgroundImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [Config imgBaseURL], [self.buttons[i] objectForKey:kBannerImageKey]]] forState:UIControlStateNormal];
        [iconButton addTarget:self action:@selector(toLaunchWebView:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *textButton = self.textButtons[i];
        textButton.tag = i;
        [textButton setTitle:[self.buttons[i] objectForKey:kBannerTitleKey] forState:UIControlStateNormal];
        [textButton addTarget:self action:@selector(toLaunchWebView:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)toLaunchWebView:(UIButton *)sender {
    NSString *const kBannerURLKey = @"link";
    
    NSString *URLString = [self.buttons[sender.tag] objectForKey:kBannerURLKey];
    if ([URLString containsString:@"/ad/dubele12/index.html"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Double12" bundle:nil];
        UIViewController *double12HomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Double12HomeViewController"];
        double12HomeViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:double12HomeViewController animated:YES];
        return;
    }
    
    if ([self.buttons[sender.tag] objectForKey:kBannerURLKey])
        [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], [self.buttons[sender.tag] objectForKey:kBannerURLKey]]];
}

- (void)defaultCarIcon {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/McenterQueryMyCarAction.do"];
    NSDictionary *parameters = @{@"user_id":@"user_id", @"type":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *defaultCars = [[[responseObject objectForKey:@"data"] firstObject] objectForKey:@"rows"];
        NSString *defaultCarId = [[defaultCars firstObject] objectForKey:@"car_id"];
        NSArray *cars = [[[responseObject objectForKey:@"data"] lastObject] objectForKey:@"rows"];
        for (NSDictionary *car in cars) {
            if ([car[@"car_id"] isEqualToString:defaultCarId]) {
                // NSString *brandIcon = [NSString stringWithFormat:@"http://m.8673h.com/images/brand/%@.png", car[@"brand_id"]];
                NSString *brandIcon = [NSString stringWithFormat:@"%@/images/brand/%@.png", [Config baseURL], car[@"brand_id"]];
                [self.myCarButton sd_setBackgroundImageWithURL:[NSURL URLWithString:brandIcon] forState:UIControlStateNormal];
                return;
            }
        }
        [self.myCarButton setBackgroundImage:[UIImage imageNamed:@"home_mycar_box.png"] forState:UIControlStateNormal];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (void)updateVersion {
    NSString *URLString = @"https://itunes.apple.com/lookup?id=1064830136";
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *results = [responseObject objectForKey:@"results"];
        if (results.count) {
            NSString *storetVersion = [results.firstObject objectForKey:@"version"];
            NSString *appVersion = [Config appVersion];
            if ([self compareVersion:appVersion withVersion:storetVersion] < 0) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发现新版本" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"马上升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/xiu-che-zi/id1064830136?mt=8"]];
                    return;
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
}

- (int)compareVersion:(NSString *)versionA withVersion:(NSString *)versionB {
    if ([versionA isEqualToString:versionB]) return 0;
    NSArray *subVersionsA = [versionA componentsSeparatedByString:@"."];
    NSArray *subVersionsB = [versionB componentsSeparatedByString:@"."];
    if (subVersionsA.count != 3 || subVersionsB.count != 3) return 0;
    for (int i = 0; i < 3; i++) {
        int a = [subVersionsA[i] intValue];
        int b = [subVersionsB[i] intValue];
        if (a != b) return a - b;
    }
    return 0;
}

- (void)viewWillLayoutSubviews {
    CGSize size = self.contentView.bounds.size;
    if (size.width == 320.0) size.height += 30.0;
    if (size.width == 375.0) size.height += 0;
    if (size.width == 414.0) size.height -= 25.0;
    self.scrollView.contentSize = size;
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat const kBannerHeight = 170.0;
    
    if (scrollView == self.scrollView) {
        CGPoint offset = scrollView.contentOffset;
        self.topView.alpha = 1.0 + offset.y / 10.0;
        if (offset.y >= 0 && offset.y <= kBannerHeight) {
            self.topView.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0 / kBannerHeight * offset.y];
        }
    }
}

- (IBAction)toMenu:(id)sender {
    if (!self.childViewControllers.count) {
        MenuViewController *menuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuViewController"];
        [self addChildViewController:menuViewController];
        menuViewController.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.6];
        CGRect rect = menuViewController.view.frame;
        rect.origin.x -= rect.size.width;
        rect.size.height = [UIScreen mainScreen].bounds.size.height - self.tabBarController.tabBar.bounds.size.height;
        menuViewController.view.frame = rect;
        [self.view addSubview:menuViewController.view];
        rect.origin.x = 0;
        [UIView animateWithDuration:0.3 animations:^{
            menuViewController.view.frame = rect;
        }];
    }
}

- (IBAction)toScanner:(id)sender {
    NSError *error;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSString *message = @"请在iOS\"设置\"-\"隐私\"-\"相机\"中打开";
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"未获得授权使用摄像头" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    ScannerViewController *scannerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ScannerViewController"];
    scannerViewController.hidesBottomBarWhenPushed = YES;
    scannerViewController.delegate = self;
    [self.navigationController pushViewController:scannerViewController animated:YES];
}

- (void)scannerViewController:(ScannerViewController *)scannerViewController didFinishScanningCodeWithInfo:(NSDictionary *)info {
    [scannerViewController.navigationController popViewControllerAnimated:NO];
    NSLog(@"scannerViewController : %@", [info objectForKey:@"url"]);
    
    if ([[info objectForKey:@"url"] hasPrefix:@"http://"]) {
        if ([[info objectForKey:@"url"] hasPrefix:@"http://m.8673h.com"]) {
            [self launchWebViewWithURLString:[info objectForKey:@"url"]]; return;
        }
        if ([[info objectForKey:@"url"] hasPrefix:@"http://192.168.2.4:8080"]) {
            [self launchWebViewWithURLString:[info objectForKey:@"url"]]; return;
        }
        if ([[info objectForKey:@"url"] hasPrefix:@"http://a.zj-qsh.com"]) {
            [self launchWebViewWithURLString:[info objectForKey:@"url"]]; return;
        }
        return;
    }
    
    if ([[info objectForKey:@"url"] hasPrefix:@"Qsh://"]) {
        NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoginDetectionAction.do"];
        NSDictionary *parameters = nil;
        [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([[responseObject objectForKey:@"statu"] isEqualToString:@"0"]) {
                if ([[info objectForKey:@"url"] hasPrefix:@"Qsh://"]) {
                    [self receiveCardWithURLString:[info objectForKey:@"url"]]; return;
                }
            } else {
                NSString *url = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"];
                [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/Login/login/login.html?url=", url]]; return;
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
        return;
    }
    
    if ([[info objectForKey:@"url"] length] == 13) {
        NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LoginDetectionAction.do"];
        NSDictionary *parameters = nil;
        [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([[responseObject objectForKey:@"statu"] isEqualToString:@"0"]) {
                [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/getCard/index.html?recharge=", [info objectForKey:@"url"]]]; return;
            } else {
                NSString *url = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/index.html"];
                [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/Login/login/login.html?url=", url]]; return;
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
        return;
    }
}

- (void)receiveCardWithURLString:(NSString *)url {
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/ErWeiMaAction.do"];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    url = [[url componentsSeparatedByString:@"//"] lastObject];
    NSArray *kvs = [url componentsSeparatedByString:@"&"];
    for (NSString *kv in kvs) {
        NSString *k = [[kv componentsSeparatedByString:@"="] firstObject];
        NSString *v = [[kv componentsSeparatedByString:@"="] lastObject];
        if (k && v) [parameters setValue:v forKey:k];
    }
    if ([parameters[@"code"] isEqualToString:@"0"]) {
        [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/getCard/index.html?ext=", parameters[@"ext"]]]; return;
    }
    if ([parameters[@"code"] isEqualToString:@"1"]) {
        [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
            if ([[responseObject objectForKey:@"error"] isEqualToString:@"201"]) {
                NSString *message = [NSString stringWithFormat:@"恭喜您成功领取 %@", [responseObject objectForKey:@"data"]];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"领取成功" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"立即查看" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/hongbao/index.html?type=1"];
                    if ([parameters[@"code"] hasPrefix:@"B-"]) {
                        URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/hongbao/index.html"];
                    }
                    [self launchWebViewWithURLString:URLString];
                }];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            } else {
                NSString *message = [responseObject objectForKey:@"msg"];
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"领取失败" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"关闭" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    }
}

- (IBAction)toSearch:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/search/index.html"] animated:NO];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

- (void)launchWebViewWithURLString:(NSString *)urlString animated:(BOOL)animated {
    WebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"WebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:animated];
}

- (void)toMyCar:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/my_car/index.html"]];
}

- (void)toLogin:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [Config baseURL], @"/Login/login/login.html?url=", [Config baseURL]]];
}

- (IBAction)toMeirong:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/main-car/index.html"]];
}

- (IBAction)toWholeMaintain:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/index.html"]];
    
    /*
    ChatViewController *chatViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatViewController.receiverId = @"3432";
    chatViewController.receiverName = @"BoBo";
    chatViewController.receiverAvatar = @"group1/M00/00/6A/wKgCBFfD6ZyAO3zmAAgKHyYE5OE360.jpg";
    chatViewController.isContact = @"1";
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
     */
}

- (IBAction)toPartMaintain:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/small_mantain/index.html?type=2"]];
}

- (IBAction)toReplaceTire:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/maintenance/small_mantain/index.html?type=1"]];
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
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/free_jc/index.html"]];
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

- (IBAction)toB21:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270100&title=%E5%BD%B1%E9%9F%B3%E5%AF%BC%E8%88%AA"]];
}

- (IBAction)toA14:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/make-money/index/index.html"]];
}

- (IBAction)toMaintainRecord:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/MaintainFiles/FirstFile/index.html"]];
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

- (NSArray *)bannersForBannerView:(BannerView *)bannerView {
    return self.banners;
}

- (void)bannerView:(BannerView *)bannerView didSelectBanner:(NSDictionary *)bannerInfo {
    // **********
    NSString *URLString = bannerInfo[kBannerURLKey];
    if ([URLString containsString:@"/ad/dubele12/index.html"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Double12" bundle:nil];
        UIViewController *double12HomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Double12HomeViewController"];
        double12HomeViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:double12HomeViewController animated:YES];
        return;
    }
    
    if ([bannerInfo objectForKey:kBannerURLKey])
        [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], [bannerInfo objectForKey:kBannerURLKey]]];
}

- (NSString *)textForReminderView:(ReminderView *)reminderView {
    return self.reminderText;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.recommenders.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const kImageSize = @"250x250";
    
    RecommenderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    NSString *imagePath = [self.recommenders[indexPath.row] objectForKey:@"goods_main_img"];
    NSString *imageURLString = [NSString stringWithFormat:@"%@/%@_%@.%@", [Config imgBaseURL], imagePath.stringByDeletingPathExtension, kImageSize, imagePath.pathExtension];
    [cell.goodsImageView sd_setImageWithURL:[NSURL URLWithString:imageURLString]];
    cell.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%@", [self.recommenders[indexPath.row] objectForKey:@"price3"]];
    cell.goodsPriceStrikethroughLabel.attributedText =
                    [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@", [self.recommenders[indexPath.row] objectForKey:@"price2"]] attributes:
                                                        @{NSStrikethroughStyleAttributeName:@(NSUnderlineStyleSingle|NSUnderlinePatternSolid),
                                                          NSStrikethroughColorAttributeName:[UIColor colorWithRed:153.0/255.0 green:153.0/255.0 blue:153.0/255.0 alpha:1.0]}];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@/detail/index.html?goodsId=%@", [Config baseURL], [self.recommenders[indexPath.row] objectForKey:@"goods_id"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidDisappear:(BOOL)animated {
    for (UIViewController *viewController in self.childViewControllers) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

@end
