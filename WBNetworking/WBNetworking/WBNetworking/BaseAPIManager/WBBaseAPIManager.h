//
//  WBBaseAPIManager.h
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WBURLResponse.h"
#import "WBCommResponse.h"

@class WBBaseAPIManager;

typedef enum : NSUInteger {
    WBAPIManagerErrorTypeDefault,     // 没有产生过API请求，这个是manager的默认状态。
    WBAPIManagerErrorTypeSuccess,     // API请求成功且返回数据正确。
    WBAPIManagerErrorTypeNoContent,   // API请求成功但返回数据不正确。
    WBAPIManagerErrorTypeTimeout,     // 请求超时。
    WBAPIManagerErrorTypeNoNetWork    // 网络不通。在调用API之前会判断当前网络是否通畅。
} WBAPIManagerErrorType;

typedef enum : NSUInteger {
    WBAPIManagerRequestTypeGet,             // GET
    WBAPIManagerRequestTypePost,            // POST
    WBAPIManagerRequestTypeMultipartPost    // MultipartPost
} WBAPIManagerRequestType;


// 调用者如需使用Delegate回调结果，需要实现此协议
@protocol WBAPIManagerCallBackDelegate <NSObject>
@optional
- (void)managerCallAPIDidSuccess:(WBBaseAPIManager *)manager response:(WBCommResponse *)response;
- (void)managerCallAPIDidFailed:(WBBaseAPIManager *)manager response:(WBCommResponse *)response;
@end

// 回调闭包
typedef void(^RequestCompletionBlock)(WBAPIManagerErrorType errorType, WBCommResponse *response);

/**
 *  WBAPIBaseManager的派生类必须符合这些protocal
 */
@protocol WBAPIManager <NSObject>
@required
/**
 *  接口名(endPoint)
 */
- (NSString *)methodName;

/**
 *  请求类型
 */
- (WBAPIManagerRequestType)requestType;

@optional
/**
 *  主机(不提供，默认使用ServiceHost)
 */
- (NSString *)host;

/**
 *  通知子类开始处理自己的业务逻辑，处理完毕后必须发起请求
 */
- (void)startDeal;

/**
 *  获取上传的二进制流文件组，
 *
 *  @return 上传的文件
 */
- (NSArray<NSData *> *)uploadFiles;

/**
 *  如果需要缓存，实现此方法
 *
 *  @param errorType 错误码
 *  @param response  数据
 */
- (void)shouldCacheWithResponse:(WBAPIManagerErrorType)errorType response:(WBCommResponse *)response;

/**
 *  如获取到缓存中的数据，则不进行网络请求
 *
 *  @return 缓存的数据
 */
- (WBCommResponse *)cacheResponse;

/**
 *  刷新缓存的最小时间间隔
 *
 *  @return 时间间隔
 */
- (NSTimeInterval)refreshCacheMinTimeInterval;

/**
 *  通过子类把数据转换实体
 *
 *  @param response 原始数据
 *
 *  @return 转换后的实体
 */
- (id)fetchData:(WBCommResponse *)response;
@end



@interface WBBaseAPIManager : NSObject

/**
 *  代理回调结果
 */
@property (nonatomic, weak) id<WBAPIManagerCallBackDelegate> delegate;

/**
 *  派生类
 */
@property (nonatomic, weak) NSObject<WBAPIManager> *child;

/**
 *  错误类型
 */
@property (nonatomic, readonly) WBAPIManagerErrorType errorType;

/**
 *  请求参数
 */
@property (nonatomic, strong) NSDictionary *requestParam;

/**
 *  正在加载
 */
@property (nonatomic, assign, readonly) BOOL isLoading;

/**
 *  刷新缓存(在刷新间隔内，不会刷新，刷新间隔可在配置文件设置)
 */
@property (nonatomic, assign) BOOL refreshCache;

/**
 *  刷新缓存直到成功
 */
@property (nonatomic, assign) BOOL refreshCacheUntilSucceed;

/**
 *  开始请求
 *
 *  @return 请求编号
 */
- (NSInteger)startRequest;

/**
 *  闭包回调结果
 *
 *  @param block 回调
 */
- (NSInteger)startWithCompletionBlock:(RequestCompletionBlock)block;

/**
 *  只是通知底层可以开始工作了，但具体何时发出请求由子类决定
 *
 *  @param block 回调闭包
 */
- (void)delayStartWithCompletionBlock:(RequestCompletionBlock)block;

/**
 *  子类直接抛错
 */
- (void)childClassFailedOnCallingAPI;

/**
 *  取消所有请求
 */
- (void)cancelAllRequests;

/**
 *  取消某个请求
 *
 *  @param requestID 请求编号
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

/**
 *  把数据转换成具体的实体
 *
 *  @param reformer 需要转换的数据
 *
 *  @return 转换后的实体
 */
- (id)fetchDataWithReformer:(WBCommResponse *)reformer;
@end
