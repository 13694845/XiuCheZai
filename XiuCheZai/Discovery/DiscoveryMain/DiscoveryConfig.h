//
//  Config.h
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscoveryConfig : NSObject

#pragma mark - 1-颜色部分

/** 文章标题 */
#define kXCZARTICLETITLECOLOR [UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:1.0]
/** 标题 */
#define kXCTITLECOLOR [UIColor colorWithRed:34/255.0 green:34/255.0 blue:34/255.0 alpha:1.0]
/** 正文 */
#define kXCTEXTCOLOR [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0]
/** 次要信息及icon */
#define kXCSECONDARYINFOANDICONCOLOR [UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]
/** 时间及辅助文字 */
#define kXCTIMEANDAUXILIARYTEXTCOLOR [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0]
/** 分割线及标注icon */
#define kXCDIVIDINGLINEANDCALLOUTCOLOR [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0]
/** 背景颜色 */
#define kXCBACKGROUNDCOLOR [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0]

#pragma mark - 2-间距部分

#define XCZNewDetailRemarkRowMarginX 8
#define XCZNewDetailRemarkRowMarginY 8

/** 2.iOS 的设置 */
// 2.1 ios版本
#define iOS6 ([[UIDevice currentDevice].systemVersion doubleValue] >= 6.0)
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
#define iOS7 ([[UIDevice currentDevice].systemVersion doubleValue] >= 7.0)
#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)

// 2.2.用ZHMLog(...)来打印输出
#ifdef DEBUG // 处于开发阶段
#define ZHMLog(...) NSLog(__VA_ARGS__)
#else // 处于发布阶段
#define ZHMLog(...)
#endif

// 3.设备屏幕型号
#define kDevice_Is_iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960),  [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define kDevice_Is_iPhone6Plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)


@end
