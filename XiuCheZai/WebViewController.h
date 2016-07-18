//
//  WebViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/1/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

typedef NS_ENUM(int, TabIndex) {
    TabIndexHome = 0,
    TabIndexStore,
    TabIndexAccessory,
    TabIndexCart,
    TabIndexMine
};

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSURL *url;

- (void)recognizeVehicleLicense;
- (void)fillOutFormWithVehicleLicense:(NSDictionary *)vehicleLicenseInfo;

@end
