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
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *server = [NSString stringWithFormat:@"%@%@", [Config webBaseURL], @"/Action/CertificatesAction.do?type=2&img_type=6"];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSData *data = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.5);
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:server parameters:nil
                                                                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                                                                                  [formData appendPartWithFileData:data name:@"file" fileName:@"filename.jpg" mimeType:@"image/jpeg"];
                                                                              } error:nil];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress *uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
        });
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        NSDictionary *responseInfo = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableLeaves error:nil];
        NSLog(@"responseInfo : %@", responseInfo[@"msg"]);
        /*
        if (![[responseInfo objectForKey:@"filepath"] length]) {
            [self executeJavascript:[NSString stringWithFormat:@"pickImageResult(\"\")"]];
            return;
        }
        [self executeJavascript:[NSString stringWithFormat:@"pickImageResult(\"%@\")", [responseInfo objectForKey:@"filepath"]]];
         */
    }];
    [uploadTask resume];
}

@end
