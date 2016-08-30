//
//  XCZDiscoveryViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/19.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZDiscoveryViewController.h"
#import "XCZNewsViewController.h"
#import "XCZCircleViewController.h"
#import "XCZActivityViewController.h"
#import "XCZClubViewController.h"

typedef NS_OPTIONS(NSUInteger, DiscoveryContentTransition) {
    DiscoveryContentTransitionScrollLeft     = 1 << 0,
    DiscoveryContentTransitionScrollRight    = 1 << 1
};

@interface XCZDiscoveryViewController ()

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (assign, nonatomic) int currentIndex;

@end

@implementation XCZDiscoveryViewController

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
