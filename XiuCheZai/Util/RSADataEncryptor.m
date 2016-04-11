//
//  RSADataEncryptor.m
//  XiuCheZai
//
//  Created by QSH on 16/3/18.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "RSADataEncryptor.h"
#import "openssl_wrapper.h"
#import "rsa.h"
#include "pem.h"
#include "md5.h"
#include "bio.h"
#include "sha.h"
#include <string.h>

@implementation RSADataEncryptor

- (id)initWithPublicKey:(NSString *)publicKey {
    if (self = [super init]) {
        _publicKey = [publicKey copy];
    }
    return self;
}

- (NSString *)formatPublicKey:(NSString *)publicKey {
    
    NSMutableString *result = [NSMutableString string];
    
    [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    
    int count = 0;
    
    for (int i = 0; i < [publicKey length]; ++i) {
        
        unichar c = [publicKey characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 76) {
            [result appendString:@"\n"];
            count = 0;
        }
        
    }
    
    [result appendString:@"\n-----END PUBLIC KEY-----\n"];
    
    return result;
    
}

- (NSString *)encryptString:(NSString *)string {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [documentPath stringByAppendingPathComponent:@"RSAPublicKey"];
    
    NSString *formatKey = [self formatPublicKey:_publicKey];
    [formatKey writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    
    char *public_key_file_path = (char *)[path cStringUsingEncoding:NSUTF8StringEncoding];
    BIO *bio_public = NULL;
    RSA *rsa_public = NULL;
    bio_public = BIO_new(BIO_s_file());
    BIO_read_filename(bio_public, public_key_file_path);
    rsa_public = PEM_read_bio_RSA_PUBKEY(bio_public, NULL, NULL, NULL);
    
    const char *message = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int messageLength = strlen(message);
    unsigned char *en = (unsigned char *)malloc(256);
    int encrypt_ok = RSA_public_encrypt(messageLength, (unsigned char *)message, (unsigned char *)en, rsa_public, RSA_PKCS1_PADDING);
    
    NSString *encryptedString = nil;
    if (encrypt_ok) {
        encryptedString = base64StringFromData([NSData dataWithBytes:en length:encrypt_ok]);
    }
    
    free(en);
    BIO_free_all(bio_public);
    return encryptedString;
}

@end
