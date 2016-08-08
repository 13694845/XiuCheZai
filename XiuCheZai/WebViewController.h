//
//  WebViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/1/13.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic) NSURL *url;

@end
