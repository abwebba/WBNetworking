//
//  WBRequestGenerator.m
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBRequestGenerator.h"
#import "WBNetworkingConfiguration.h"
#import <AFNetworking/AFNetworking.h>

@interface WBRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end

@implementation WBRequestGenerator

+ (instancetype)sharedRequestGenerator {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

#pragma mark - public methods
- (NSURLRequest *)generateGETRequestWithRequestParams:(NSDictionary *)requestParams host:(NSString *)host methodName:(NSString *)methodName {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", host, methodName];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:requestParams error:NULL];
    
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams host:(NSString *)host methodName:(NSString *)methodName {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", host, methodName];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:requestParams error:NULL];
    //request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams files:(NSArray<NSData *> *)files host:(NSString *)host methodName:(NSString *)methodName {
    NSString *urlString = [NSString stringWithFormat:@"%@%@", host, methodName];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer multipartFormRequestWithMethod:@"POST" URLString:urlString parameters:requestParams constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSData *data in files) {
            [formData appendPartWithFileData:data name:@"file" fileName:@"FILE" mimeType:@"application/octet-stream"];
        }
        
    } error:nil];
    
    return request;
}

#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer {
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = NetworkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
