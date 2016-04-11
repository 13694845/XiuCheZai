//
//  RSADataEncryptor.h
//  XiuCheZai
//
//  Created by QSH on 16/3/18.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSADataEncryptor : NSObject {
    NSString *_publicKey;
}

- (id)initWithPublicKey:(NSString *)publicKey;
- (NSString *)encryptString:(NSString *)string;

@end
