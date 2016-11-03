//
//  XCZDiscoveryViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDiscoveryFrameViewController.h"
#import "XCZNewsViewController.h"
#import "XCZCircleViewController.h"
#import "XCZActivityViewController.h"
#import "XCZClubViewController.h"
#import "XCZMessageViewController.h"
#import "XCZPublishWritingViewController.h"
#import "XCZPublishPhoneViewController.h"
#import "XCZPublishOrdersTableViewController.h"
#import "XCZConfig.h"
#import "XCZPersonWebViewController.h"

typedef NS_OPTIONS(NSUInteger, DiscoveryContentTransition) {
    DiscoveryContentTransitionScrollLeft     = 1 << 0,
    DiscoveryContentTransitionScrollRight    = 1 << 1
};

typedef NS_OPTIONS(NSUInteger, DiscoveryLoginOverJumpType) {
    DiscoveryLoginOverJumpTypePosting          = 1 << 0,
    DiscoveryLoginOverJumpTypeDryingSingle     = 1 << 1
};

@interface XCZDiscoveryFrameViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (assign, nonatomic) int currentIndex;
@property (nonatomic, strong) UIImage *publishImage;
@property (assign, nonatomic) int loginStatu; // 登录状态, 0为已经登录, 1为未登录
@property (assign, nonatomic) DiscoveryLoginOverJumpType jumpType;
@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation XCZDiscoveryFrameViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [XCZConfig version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (void)setLoginStatu:(int)loginStatu
{
    _loginStatu = loginStatu;
    
    if (self.jumpType == DiscoveryLoginOverJumpTypePosting) {
        loginStatu ? [self goLogining] : [self jumpToPublishPhoneViewController]; // 跳转到发帖控制器
    } else if (self.jumpType == DiscoveryLoginOverJumpTypeDryingSingle) {
        loginStatu ? [self goLogining] : [self jumpToPublishOrdersTableViewController]; // 跳到晒单
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:229.0/255.0 green:21.0/255.0 blue:45.0/255.0 alpha:1.0];
    
    for (UIButton *button in self.buttons) [button addTarget:self action:@selector(switchContent:) forControlEvents:UIControlEventTouchUpInside];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZNewsViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZCircleViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZActivityViewController"]];
    [self addChildViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"XCZClubViewController"]];
    
    [self.buttons.firstObject setAlpha:1.0];
    UIViewController *viewController = self.childViewControllers.firstObject;
    viewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:viewController.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.translucent = NO;
    self.tabBarController.tabBar.hidden = NO;
}

- (void)switchContent:(id)sender {
    int newIndex = [self.buttons indexOfObject:sender];
    if (newIndex != self.currentIndex) {
        [sender setAlpha:1.0];
        [self.buttons[self.currentIndex] setAlpha:0.7];
        [self transitionFromViewController:self.childViewControllers[self.currentIndex] toViewController:self.childViewControllers[newIndex]
                                  duration:0.2 options:newIndex > self.currentIndex ? DiscoveryContentTransitionScrollLeft : DiscoveryContentTransitionScrollRight];
        self.currentIndex = newIndex;
    }
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
                            duration:(NSTimeInterval)duration options:(DiscoveryContentTransition)options {
    CGRect rect = self.contentView.bounds;
    if (options & DiscoveryContentTransitionScrollLeft) {
        rect.origin.x += rect.size.width;
    }
    if (options & DiscoveryContentTransitionScrollRight) {
        rect.origin.x -= rect.size.width;
    }
    toViewController.view.frame = rect;
    [self.contentView addSubview:toViewController.view];
    
    [UIView animateWithDuration:duration animations:^{
        toViewController.view.frame = self.contentView.bounds;
        CGRect rect = self.contentView.bounds;
        if (options & DiscoveryContentTransitionScrollLeft) {
            rect.origin.x -= rect.size.width;
        }
        if (options & DiscoveryContentTransitionScrollRight) {
            rect.origin.x += rect.size.width;
        }
        fromViewController.view.frame = rect;
    } completion:^(BOOL finished) {
        [fromViewController.view removeFromSuperview];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/**
 *  nav右边消息图标被点击
 */
- (IBAction)messageBtnDidClick:(id)sender {
    XCZMessageViewController *messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZMessageViewController"];
    [self.navigationController pushViewController:messageVC animated:YES];
}

- (IBAction)addBtnDidClick:(id)sender {
    UIAlertController *alertCtr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *oneAction = [UIAlertAction actionWithTitle:@"发帖" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.jumpType = DiscoveryLoginOverJumpTypePosting;
        [self requestLoginDetection];
    }];
    UIAlertAction *twoAction = [UIAlertAction actionWithTitle:@"晒单" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.jumpType = DiscoveryLoginOverJumpTypeDryingSingle;
        [self requestLoginDetection];
    }];
    
    [alertCtr addAction:cancelAction];
    [alertCtr addAction:oneAction];
    [alertCtr addAction:twoAction];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

- (void)requestLoginDetection
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], @"/Action/LoginDetectionAction.do"];
    NSDictionary *parameters = nil;
    [self.manager POST:urlString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.loginStatu = [responseObject[@"statu"] intValue];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error:%@", error);
    }];
}

#pragma mark - 去登录等方法
- (void)goLogining
{
    NSString *overUrlStrPin = [NSString stringWithFormat:@"/bbs/car-club/index.html"];
    NSString *overUrlStr = [NSString stringWithFormat:@"%@%@", [XCZConfig baseURL], overUrlStrPin];
    [self launchWebViewWithURLString:[NSString stringWithFormat:@"%@%@%@", [XCZConfig baseURL], @"/Login/login/login.html?url=", overUrlStr]];
}

- (void)launchWebViewWithURLString:(NSString *)urlString {
    XCZPersonWebViewController *webViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPersonWebViewController"];
    webViewController.url = [NSURL URLWithString:urlString];
    webViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:webViewController animated:YES];
}

#pragma mark - 跳转控制器
- (void)jumpToPublishPhoneViewController
{
    XCZPublishPhoneViewController *phoneVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishPhoneViewController"];
    phoneVC.image = self.publishImage;
    [self.navigationController pushViewController:phoneVC animated:YES];
}

- (void)jumpToPublishOrdersTableViewController
{
    XCZPublishOrdersTableViewController *orderTableVC = [self.storyboard instantiateViewControllerWithIdentifier:@"XCZPublishOrdersTableViewController"];
    [self.navigationController pushViewController:orderTableVC animated:YES];
}




@end
