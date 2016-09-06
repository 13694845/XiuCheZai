//
//  XCZNewsDetailViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/8/29.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "XCZNewsDetailViewController.h"
#import "XCZNewsDetailModel.h"

@interface XCZNewsDetailViewController ()

@property (nonatomic, strong) XCZNewsDetailModel *newsDetailModel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;

@end

@implementation XCZNewsDetailViewController

- (XCZNewsDetailModel *)newsDetailModel {
    if (_newsDetailModel) _newsDetailModel = [[XCZNewsDetailModel alloc] init];
    return _newsDetailModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 700)];
    
    // ...
    
    self.scrollView.contentSize = self.contentView.bounds.size;
    [self.scrollView addSubview:self.contentView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
