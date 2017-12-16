//
//  DemoWeatherApi.m
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "DemoWeatherApi.h"
#import "WBCache.h"

@implementation DemoWeatherApi

- (void)paramWithCity:(NSString *)city {
    self.requestParam = @{@"city" : city};
}

#pragma mark - WBAPIManager
- (NSString *)methodName {
    return @"/open/api/weather/json.shtml";
}

- (WBAPIManagerRequestType)requestType {
    return WBAPIManagerRequestTypeGet;
}

/*
 1、如果需要缓存，实现本方法
 2、在里根据自己的业务需求来缓存
 3、我使用的缓存框架是YYCache，可以根据自己的需求用其他的方式缓存也可以
 */
- (void)shouldCacheWithResponse:(WBAPIManagerErrorType)errorType response:(WBCommResponse *)response {
    if (response.status == StatusCode_Succeed) {
        [[WBCache sharedCache] setObject:response.data forKey:NSStringFromClass(self.class)];
    }
}

/*
 如果实现本方法，会把缓存取出来的数据直接返回
 */
- (WBCommResponse *)cacheResponse {
    WBCacheModel *cache = [[WBCache sharedCache] objectForKey:NSStringFromClass(self.class)];
    return [[WBCommResponse alloc] initWithCacheModel:cache];
}

- (id)fetchData:(WBCommResponse *)response {
    return [[DemoWeatherResults alloc] initWithDictionary:(NSDictionary *)response.data error:nil];
}

@end
