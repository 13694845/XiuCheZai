//
//  URLCache.h
//  XiuCheZai
//
//  Created by QSH on 16/4/5.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface URLCache : NSObject <NSCoding>

@property (nonatomic) NSURLRequest *redirectRequest;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) NSData *data;

@end
