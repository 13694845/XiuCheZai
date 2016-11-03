//
//  MBProgressHUD+MJ.h
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (MJ)
+ (void)ZHMShowSuccess:(NSString *)success toView:(UIView *)view;
+ (void)ZHMShowError:(NSString *)error toView:(UIView *)view;

+ (MBProgressHUD *)ZHMShowMessage:(NSString *)message toView:(UIView *)view;


+ (void)ZHMShowSuccess:(NSString *)success;
+ (void)ZHMShowError:(NSString *)error;

+ (MBProgressHUD *)ZHMShowMessage:(NSString *)message;

+ (void)ZHMHideHUDForView:(UIView *)view;
+ (void)ZHMHideHUD;

@end
