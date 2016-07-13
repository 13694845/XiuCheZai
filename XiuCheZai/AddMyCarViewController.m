//
//  AddMyCarViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "AddMyCarViewController.h"

@interface AddMyCarViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

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
    /*
    UIImagePickerController *imagePickController = [[UIImagePickerController alloc] init];
    imagePickController.delegate = self;
    imagePickController.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePickController.showsCameraControls = NO;
    imagePickController.edgesForExtendedLayout = UIRectEdgeNone;
    CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
    imagePickController.cameraViewTransform = CGAffineTransformTranslate(t, 0, [UIScreen mainScreen].bounds.size.height * 0.125);
    self.imagePickController = imagePickController;
    //添加自定义信息层
    self.scanView = [[ScanView alloc] init];
    self.scanView.frame = self.view.bounds;
    self.scanView.backgroundColor = [UIColor clearColor];//设定透明背景色
    imagePickController.cameraOverlayView = self.scanView;
    [self presentViewController:imagePickController animated:YES completion:nil];
    [self.scanView.scanOverBtn addTarget:self action:@selector(scanOverBtnDidClick) forControlEvents:UIControlEventTouchUpInside];
     */
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    // imagePickerController.showsCameraControls = NO;
    
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
}

@end
