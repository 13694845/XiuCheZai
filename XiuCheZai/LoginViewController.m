//
//  LoginViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "LoginViewController.h"
#import "RSADataEncryptor.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIyirbChVxQFk3n5ZDyBksvMEmdDIWM+52iGIgItINV0ivasC2MpE1OzFzwgLt2nv14LXJTRmawLf1cduRhVWT13ldhidL601KE23Wabo30TKNJmMR0gLPD2PTq5JjmuwxSEd5AIdGm3OIaRrScQ24PlEbho2+ApTLjzCknGkY1wIDAQAB";
    RSADataEncryptor *encryptor = [[RSADataEncryptor alloc] initWithPublicKey:publicKey];
    NSString * encryptedString = [encryptor encryptString:@"password"];
    NSLog(@"encryptedString : %@", encryptedString);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
