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
    
    self.bannerView.dataSource = self;
    self.bannerView.delegate = self;
    self.reminderView.dataSource = self;
    self.recommenderCollectionView.dataSource = self;
    self.recommenderCollectionView.delegate = self;
    
    NSString *URLString = @"https://itunes.apple.com/lookup?id=1064830136";
    NSDictionary *parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (((NSNumber *)[responseObject objectForKey:@"resultCount"]).intValue) {
            NSString *storeVersion = [[[responseObject objectForKey:@"results"] firstObject] objectForKey:@"version"];
            // NSLog(@"storeVersion : %@", storeVersion);
            NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
            // NSLog(@"appVersion : %@", appVersion);
            if (![storeVersion isEqualToString:appVersion]) {
                NSString *message = @"获取新版修车仔，体验更多功能";
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"发现新版本" message:message preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/xiu-che-zi/id1064830136"]];
                }];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"下次再说" style:UIAlertActionStyleDefault handler:nil];
                [alertController addAction:cancelAction];
                [alertController addAction:okAction];
                [self presentViewController:alertController animated:YES completion:nil];
            }
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
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
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/LunBoAction.do"];
    parameters = @{@"page_id":@"4", @"ad_id":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *banners = [[responseObject objectForKey:@"data"] objectForKey:@"detail"];
        if (self.banners.hash != banners.hash) {
            self.banners = banners;
            [self.bannerView reloadData];
            [[NSUserDefaults standardUserDefaults] setObject:banners forKey:@"banners"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/MaintainRemind.do"];
    parameters = nil;
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![[responseObject objectForKey:@"data"] count]) {
            self.reminderText = @"即将开启：#保养提醒 #到店检测 #车品特惠";
            [self.reminderView reloadData];
            return;
        }
        NSDictionary *reminderInfo = [[responseObject objectForKey:@"data"] firstObject];
        NSString *reminderText = [NSString stringWithFormat:@"%@在%@/%@km需要%@",
                                  [reminderInfo objectForKey:@"car_no"],
                                  [reminderInfo objectForKey:@"remindtime"],
                                  [reminderInfo objectForKey:@"remindkilo"],
                                  [reminderInfo objectForKey:@"about"]];
        if (self.reminderText.hash != reminderText.hash) {
            self.reminderText = reminderText;
            [self.reminderView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Action/MobileIndexAction.do"];
    parameters = @{@"site":@"2", @"code":@"1", @"position":@"1"};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *recommenders = [[responseObject objectForKey:@"data"] objectForKey:@"goods"];
        if (self.recommenders.hash != recommenders.hash) {
            self.recommenders = recommenders;
            [self.recommenderCollectionView reloadData];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
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
    [self launchWebViewWithURLString:[info objectForKey:@"url"]];
}

- (IBAction)toSearch:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html"]];
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

- (IBAction)toWholeMaintain:(id)sender {    // Page A
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
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/m-center/free_jc/index.html"]];
}

- (IBAction)toInterior:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270300&title=%E5%86%85%E9%A5%B0%E7%94%A8%E5%93%81"]];
}

- (IBAction)toBrakeBlock:(id)sender {   // Page B
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=170700&title=%E5%88%B9%E8%BD%A6%E7%89%87"]];
}

- (IBAction)toACFilter:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=200800&title=%E7%A9%BA%E8%B0%83%E6%BB%A4%E8%8A%AF"]];
}

- (IBAction)toSparkPlug:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=110100&title=%E7%81%AB%E8%8A%B1%E5%A1%9E"]];
}

- (IBAction)toB14:(id)sender {
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@", [Config baseURL], @"/list/category.html?pjfl=270100&title=%E5%BD%B1%E9%9F%B3%E5%AF%BC%E8%88%AA"]];
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

@end
