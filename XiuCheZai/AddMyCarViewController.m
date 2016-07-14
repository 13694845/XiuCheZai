//
//  AddMyCarViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/7/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "AddMyCarViewController.h"
#import "Config.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"

@interface AddMyCarViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) MBProgressHUD *hud;

@property (weak, nonatomic) IBOutlet UITextField *modelTextField;
@property (weak, nonatomic) IBOutlet UITextField *ownerTextField;
@property (weak, nonatomic) IBOutlet UITextField *telTextField;
@property (weak, nonatomic) IBOutlet UITextField *plateNoTextField;
@property (weak, nonatomic) IBOutlet UITextField *registerDateTextField;
@property (weak, nonatomic) IBOutlet UITextField *mileageTextField;
@property (weak, nonatomic) IBOutlet UITextField *vinTextField;
@property (weak, nonatomic) IBOutlet UITextField *engineNoTextField;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@end

@implementation AddMyCarViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:196.0/255.0 green:0/255.0 blue:1.0/255.0 alpha:1.0];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationItem.title = @"添加车型";
    // UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"common_back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"行驶证" style:UIBarButtonItemStylePlain target:self action:@selector(recognizeVehicleLicense)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
    self.okButton.layer.cornerRadius = 8.0;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)recognizeVehicleLicense {
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // NSString *server = [NSString stringWithFormat:@"%@%@", [Config webBaseURL], @"/Action/CertificatesAction.do?type=2&img_type=6"];
    NSString *server = @"http://v.juhe.cn/certificates/query.php";
    NSDictionary *parameters = @{@"key":@"a1f24fa8cb9e8de0c5cbc7ee3e2fd060", @"cardType":@"6"};
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeAnnularDeterminate;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [self resizeImage:image toSize:CGSizeMake(image.size.width / 2, image.size.height / 2)];
    NSData *data = UIImageJPEGRepresentation(image, 0.8);
    [self.manager POST:server parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"pic" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
    } progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%f", uploadProgress.fractionCompleted);
            self.hud.progress = uploadProgress.fractionCompleted;
        });
    } success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"responseObject : %@", responseObject);
        [self.hud hide:YES];
        self.hud.progress = 0;
        [self fillOutFormWithVehicleLicense:responseObject[@"result"]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.hud hide:YES];
        self.hud.progress = 0;
    }];
}

- (void)fillOutFormWithVehicleLicense:(NSDictionary *)vehicleLicenseInfo {
    self.ownerTextField.text = vehicleLicenseInfo[@"所有人"];
    self.plateNoTextField.text = vehicleLicenseInfo[@"号牌号码"];
    self.registerDateTextField.text = vehicleLicenseInfo[@"注册日期"];
    self.vinTextField.text = vehicleLicenseInfo[@"车辆识别代号"];
    self.engineNoTextField.text = vehicleLicenseInfo[@"发动机号码"];
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizedImage;
}

@end
