//
//  AddMyCarViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "AddMyCarViewController.h"

@interface AddMyCarViewController ()

@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *ownerTextField;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *plateNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *mileageTextField;
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UITextField *engineNoTextField;

@end

@implementation AddMyCarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = @"添加车型";
    
    // UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"行驶证" style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)scan {
    NSLog(@"scan");
}

@end
