//
//  ScannerViewController.h
//  XiuCheZai
//
//  Created by QSH on 16/5/3.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ScannerViewController;

@protocol ScannerViewControllerDelegate <NSObject>

- (void)scannerViewController:(ScannerViewController *)scannerViewController didFinishScanningCodeWithInfo:(NSDictionary *)info;

@end

@interface ScannerViewController : UIViewController

@property (weak, nonatomic) id <ScannerViewControllerDelegate> delegate;

@end
