//
//  WBNetworkingConfiguration.h
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#ifndef WBNetworkingConfiguration_h
#define WBNetworkingConfiguration_h

typedef enum : NSUInteger {
    StatusCode_Succeed = 200,    // 请求成功
    StatusCode_SystemError = 400,   // 系统错误
} StatusCode;

typedef enum : NSUInteger {
    WBURLResponseStatusSuccess, // http code 200，至于业务数据是否完整，由上层的WBBaseAPIManager来决定。
    WBURLResponseStatusErrorTimeout,
    WBURLResponseStatusErrorNoNetwork,
} WBURLResponseStatus;


static NSString *ServiceHost = @"http://www.sojson.com";

static NSTimeInterval NetworkingTimeoutSeconds = 10.0f; // 请求最大等待时间
static NSTimeInterval RefreshCacheMinTimeIntervalSeconds = 20.0f; // 刷新缓存的最小时间间隔

// 提示语
static NSString *ServerErrorHint =   @"服务繁忙，请重新尝试";   // 服务器报错
static NSString *ResponseErrorHint = @"网络不给力，请稍后再试"; // 超时
static NSString *NoNetworkHint =     @"请检查您手机的网络";    // 没网络
static NSString *DataErrorHint =     @"数据异常";

#endif
