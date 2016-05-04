//
//  URLEncoder.m
//  XiuCheZai
//
//  Created by QSH on 16/5/4.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "URLEncoder.h"

@implementation URLEncoder

+ (NSString *)encodeURLString:(NSString *)URLString {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)URLString, NULL, (CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8));
}

@end
