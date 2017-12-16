//
//  WBURLResponse.m
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBURLResponse.h"

@interface WBURLResponse()
@property (nonatomic, assign, readwrite) WBURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@end

@implementation WBURLResponse

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(WBURLResponseStatus)status {
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
    }
    return self;
}

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error {
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = responseData ? [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL] : nil;
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
    }
    return self;
}

- (instancetype)initErrorWithRequest:(NSURLRequest *)request requestId:(NSNumber *)requestId {
    self = [super init];
    if (self) {
        self.status = WBURLResponseStatusErrorTimeout;
        self.requestId = [requestId integerValue];
        self.request = request;
    }
    return self;
}

#pragma mark - private methods
- (WBURLResponseStatus)responseStatusWithError:(NSError *)error {
    if (error) {
        WBURLResponseStatus result = WBURLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = WBURLResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return WBURLResponseStatusSuccess;
    }
}

@end
