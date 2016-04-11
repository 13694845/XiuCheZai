//
//  SHA1DataEncryptor.m
//  XiuCheZai
//
//  Created by QSH on 16/4/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "SHA1DataEncryptor.h"

@implementation SHA1DataEncryptor

- (NSString *)encryptString:(NSString *)string {
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
