//
//  WBRequestGenerator.h
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBNetworkingConfiguration.h"

@interface WBRequestGenerator : NSObject

+ (instancetype)sharedRequestGenerator;

- (NSURLRequest *)generateGETRequestWithRequestParams:(NSDictionary *)requestParams
                                                 host:(NSString *)host
                                           methodName:(NSString *)methodName;
- (NSURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams
                                                  host:(NSString *)host
                                            methodName:(NSString *)methodName;
- (NSURLRequest *)generatePOSTRequestWithRequestParams:(NSDictionary *)requestParams
                                                 files:(NSArray<NSData *> *)files
                                                  host:(NSString *)host
                                            methodName:(NSString *)methodName;
@end
