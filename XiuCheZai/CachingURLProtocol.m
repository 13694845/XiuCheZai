//
//  CachingURLProtocol.m
//  XiuCheZai
//
//  Created by QSH on 16/4/5.
//  Copyright © 2016年 QSH. All rights reserved.
//

#import "CachingURLProtocol.h"
#import "URLCache.h"
#import "SHA1DataEncryptor.h"

@interface CachingURLProtocol () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic) NSURLConnection *connection;
@property (nonatomic) NSURLResponse *response;
@property (nonatomic) NSMutableData *data;

@end

static NSString *const kCachingURLHeader = @"CachingURLHeader";

@implementation CachingURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    if (![request valueForHTTPHeaderField:kCachingURLHeader]) {
        // NSArray *cachingPathExtension = @[@"png", @"jpg", @"JPG", @"woff", @"ttf", @"svg", @"css", @"js"];
        NSArray *cachingPathExtension = @[@"png", @"jpg", @"JPG", @"woff", @"css"];
        if ([cachingPathExtension containsObject:request.URL.pathExtension]) {
            // NSLog(@"cached URL : %@", request.URL);
            return YES;
        }
    }
    // NSLog(@"not cached URL : %@", request.URL);
    return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (NSString *)cachePathForRequest:(NSURLRequest *)request {
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    SHA1DataEncryptor *encryptor = [[SHA1DataEncryptor alloc] init];
    NSString *fileName = [encryptor encryptString:request.URL.absoluteString];
    // NSLog(@"cachePath : %@", [cachePath stringByAppendingPathComponent:fileName]);
    return [cachePath stringByAppendingPathComponent:fileName];
}

- (void)startLoading {
    URLCache *cache = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachePathForRequest:self.request]];
    if (cache) {
        NSURLRequest *redirectRequest = cache.redirectRequest;
        NSURLResponse *response = cache.response;
        NSData *data = cache.data;
        if (!redirectRequest) {
            [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
            [self.client URLProtocol:self didLoadData:data];
            [self.client URLProtocolDidFinishLoading:self];
        } else {
            [self.client URLProtocol:self wasRedirectedToRequest:redirectRequest redirectResponse:response];
        }
    } else {
        NSMutableURLRequest *connectionRequest = [self.request mutableCopy];
        [connectionRequest setValue:@"" forHTTPHeaderField:kCachingURLHeader];
        self.connection = [NSURLConnection connectionWithRequest:connectionRequest delegate:self];
    }
}

- (void)stopLoading {
    [self.connection cancel];
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
    if (response) {
        NSMutableURLRequest *redirectableRequest = [request mutableCopy];
        [redirectableRequest setValue:nil forHTTPHeaderField:kCachingURLHeader];
        NSString *cachePath = [self cachePathForRequest:self.request];
        URLCache *cache = [[URLCache alloc] init];
        cache.redirectRequest = redirectableRequest;
        cache.response = response;
        cache.data = self.data;
        [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
        [self.client URLProtocol:self wasRedirectedToRequest:redirectableRequest redirectResponse:response];
        return redirectableRequest;
    } else {
        return request;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self appendData:data];
}

- (void)appendData:(NSData *)data {
    if (!self.data) self.data = [data mutableCopy];
    else [self.data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    NSString *cachePath = [self cachePathForRequest:self.request];
    URLCache *cache = [[URLCache alloc] init];
    cache.response = self.response;
    cache.data = self.data;
    [NSKeyedArchiver archiveRootObject:cache toFile:cachePath];
    
    self.connection = nil;
    self.data = nil;
    self.response = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    self.connection = nil;
    self.data = nil;
    self.response = nil;
}

@end
