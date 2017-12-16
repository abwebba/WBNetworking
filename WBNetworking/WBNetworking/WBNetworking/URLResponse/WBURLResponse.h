//
//  WBURLResponse.h
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBNetworkingConfiguration.h"

@interface WBURLResponse : NSObject

@property (nonatomic, readonly, assign) WBURLResponseStatus status;
@property (nonatomic, readonly, copy) NSString *contentString;
@property (nonatomic, readonly, copy) id content;
@property (nonatomic, readonly, assign) NSInteger requestId;
@property (nonatomic, readonly, copy) NSURLRequest *request;
@property (nonatomic, readonly, copy) NSData *responseData;

- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(WBURLResponseStatus)status;
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error;
- (instancetype)initErrorWithRequest:(NSURLRequest *)request requestId:(NSNumber *)requestId;
@end
