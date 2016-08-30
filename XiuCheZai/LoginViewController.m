//
//  LoginViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "LoginViewController.h"
#import "RSADataEncryptor.h"
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIyirbChVxQFk3n5ZDyBksvMEmdDIWM+52iGIgItINV0ivasC2MpE1OzFzwgLt2nv14LXJTRmawLf1cduRhVWT13ldhidL601KE23Wabo30TKNJmMR0gLPD2PTq5JjmuwxSEd5AIdGm3OIaRrScQ24PlEbho2+ApTLjzCknGkY1wIDAQAB";
    /*
    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCZFhRlr0UbL+xuLr2Z8kRR+rGyk4bR3UL40r+Y7fkrlm0RAUvyw2VTOJTkXbMi/oGoT1jEr8AZdNH4rUecGV0SYDac3WzHvTyx/xShDwD30s4z6yTOHSCcgkKaqQXHjnpXGQAGzorI1BwDu47gcVRKGgFvRfKhtci1g5kZIu0f1QIDAQAB";
     */
    
    RSADataEncryptor *encryptor = [[RSADataEncryptor alloc] initWithPublicKey:publicKey];
    NSString * encryptedString = [encryptor encryptString:@"密码"];
    NSLog(@"encryptedString : %@", encryptedString);
    
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
    self.view = mapView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
