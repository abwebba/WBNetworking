//
//  DemoLunarApi.m
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "DemoLunarApi.h"

@implementation DemoLunarApi

#pragma mark - WBAPIManager
- (NSString *)methodName {
    return @"/open/api/lunar/json.shtml";
}

- (WBAPIManagerRequestType)requestType {
    return WBAPIManagerRequestTypeGet;
}

- (id)fetchData:(WBCommResponse *)response {
    return [[DemoLunarResults alloc] initWithDictionary:(NSDictionary *)response.data error:nil];
}

@end
