//
//  SHA1DataEncryptor.h
//  XiuCheZai
//
//  Created by QSH on 16/4/6.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

@interface SHA1DataEncryptor : NSObject

- (NSString *)encryptString:(NSString *)string;

@end
