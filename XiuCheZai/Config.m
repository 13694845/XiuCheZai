//
//  Config.m
//  XiuCheZai
//
//  Created by QSH on 15/12/14.
//  Copyright © 2015年 QSH. All rights reserved.
//

#import "Config.h"

@interface Config ()

@end

@implementation Config

static NSString *baseURL;
static NSString *version;
static NSArray *banners;

+ (NSString *)baseURL {
    if (!baseURL) baseURL = @"http://m.8673h.com";
    return baseURL;
}

+ (NSString *)version {
    if (!version) version = @"1.4.0";
    return version;
}

+ (NSArray *)banners {
    if (!banners) {
        banners = @[@{@"image":@"banner05.jpg", @"url":@"/service/detail/index.html?uid=6716"},
                    @{@"image":@"banner01.jpg", @"url":@"/ad/free_share/index.html"}];
    }
    return banners;
}

@end
