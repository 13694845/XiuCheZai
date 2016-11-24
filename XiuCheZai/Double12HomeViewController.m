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
    
    CGRect rect = self.passwordTextField.frame;
    rect.size.height += 30.0;
    self.passwordTextField.frame = rect;
    self.passwordTextField.layer.cornerRadius = 8.0;
    self.takeAwardButton.layer.cornerRadius = 8.0;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
