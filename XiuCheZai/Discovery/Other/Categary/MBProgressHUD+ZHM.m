//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+ZHM.h"

@implementation MBProgressHUD (ZHM)
#pragma mark 显示信息
+ (void)ZHMShow:(NSString *)text icon:(NSString *)icon view:(UIView *)view andDelay:(CGFloat)delay
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
//    hud.label.text = text;
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"MBProgressHUD.bundle/%@", icon]]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1.2秒之后再消失
    [hud hide:YES afterDelay:delay?delay:1.2];
}

#pragma mark 显示错误信息
+ (void)ZHMShowError:(NSString *)error toView:(UIView *)view{
    [self ZHMShow:error icon:@"error.png" view:view andDelay:1.2];
}

+ (void)ZHMShowSuccess:(NSString *)success toView:(UIView *)view
{
    [self ZHMShow:success icon:@"success.png" view:view andDelay:1.2];
}

#pragma mark 显示一些信息
+ (MBProgressHUD *)ZHMShowMessage:(NSString *)message toView:(UIView *)view {
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = message;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    hud.dimBackground = YES;
    return hud;
}

+ (void)ZHMShowSuccess:(NSString *)success
{
    [self ZHMShowSuccess:success toView:nil];
}

+ (void)ZHMShowError:(NSString *)error
{
    [self ZHMShowError:error toView:nil];
}

+ (MBProgressHUD *)ZHMShowMessage:(NSString *)message
{
    return [self ZHMShowMessage:message toView:nil];
}

+ (void)ZHMHideHUDForView:(UIView *)view
{
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    [self hideHUDForView:view animated:YES];
}

+ (void)ZHMHideHUD
{
    [self ZHMHideHUDForView:nil];
}
@end
