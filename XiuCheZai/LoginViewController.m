//
//  LoginViewController.m
//  XiuCheZai
//
//  Created by QSH on 16/3/17.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "LoginViewController.h"
#import "RSADataEncryptor.h"
#import "Config.h"
#import "AFNetworking.h"

#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface LoginViewController ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;

@end

@implementation LoginViewController

- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
        [_manager.requestSerializer setValue:[NSString stringWithFormat:@"%@ %@/%@",
                                              [_manager.requestSerializer valueForHTTPHeaderField:@"User-Agent"], @"APP8673h", [Config version]] forHTTPHeaderField:@"User-Agent"];
    }
    return _manager;
}

- (NSString *)escapeHTMLString:(NSString *)html {
    html = [html stringByReplacingOccurrencesOfString:@"＜" withString:@"<"];
    html = [html stringByReplacingOccurrencesOfString:@"＞" withString:@">"];

    html = [html stringByReplacingOccurrencesOfString:@"#3D;" withString:@"="];
    html = [html stringByReplacingOccurrencesOfString:@"#quot;" withString:@"\""];
    html = [html stringByReplacingOccurrencesOfString:@"#0A;" withString:@""];
    html = [html stringByReplacingOccurrencesOfString:@"#apos;" withString:@"'"];
    return html;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *txt_zh = @"13505766266";
    NSString *txt_pwd = @"123456";
    
    NSString *publicKey = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCIyirbChVxQFk3n5ZDyBksvMEmdDIWM+52iGIgItINV0ivasC2MpE1OzFzwgLt2nv14LXJTRmawLf1cduRhVWT13ldhidL601KE23Wabo30TKNJmMR0gLPD2PTq5JjmuwxSEd5AIdGm3OIaRrScQ24PlEbho2+ApTLjzCknGkY1wIDAQAB";
    RSADataEncryptor *encryptor = [[RSADataEncryptor alloc] initWithPublicKey:publicKey];
    NSString * encryptedString = [encryptor encryptString:txt_pwd];
    NSLog(@"encryptedString : %@", encryptedString);
    NSString *URLString = [NSString stringWithFormat:@"%@%@", [Config baseURL], @"/Login/LoginAction.do"];
    NSDictionary *parameters = @{@"txt_zh":txt_zh, @"txt_pwd":encryptedString};
    [self.manager POST:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSLog(@"/Login/LoginAction.do Result : %@", responseObject);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {}];
    
    NSString *html = @"＜div id#3D;#quot;articleContent#quot;＞#0A;＜p＞#0A;＜span style#3D;#quot;line-height:2;#quot;＞11月14日，国家发改委的一纸通知让国内成品油调价史再创新纪录—“八连跌”，而今年国内油价的涨跌比也再次被刷新，4涨12跌。＜/span＞ #0A;＜/p＞#0A;＜p＞#0A;＜span style#3D;#quot;line-height:2;#quot;＞国内油价#apos;八连跌#apos;分析称九连跌概率大＜/span＞";

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
    [webView loadHTMLString:[self escapeHTMLString:html] baseURL:nil];
    [self.view addSubview:webView];
    
    /*
    BMKMapView *mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320.0, 480.0)];
    self.view = mapView;
     */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
