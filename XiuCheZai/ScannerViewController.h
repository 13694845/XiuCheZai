//
//  ScannerViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/5/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScannerViewController;

@protocol scannerViewControllerDelegate <NSObject>

- (void)scannerViewController:(ScannerViewController *)scannerViewController didSelectBanner:(NSDictionary *)bannerInfo;

@end

@interface ScannerViewController : UIViewController

@end
