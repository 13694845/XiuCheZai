//
//  Double12HomeViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/11/24.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "Double12HomeViewController.h"

@interface Double12HomeViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *takeAwardButton;

@end

@implementation Double12HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tabBarController.tabBar.translucent = NO;
    self.view.backgroundColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    
    self.passwordTextField.layer.cornerRadius = 8.0;
    self.takeAwardButton.layer.cornerRadius = 8.0;
}

- (IBAction)takeAward:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Double12" bundle:nil];
    UIViewController *double12HomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Double12AwardViewController"];
    double12HomeViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:double12HomeViewController animated:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end