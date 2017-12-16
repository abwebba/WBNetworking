//
//  WBBaseAPIManager.m
//  WBNetworking
//
//  Created by zwb on 16/6/2.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBBaseAPIManager.h"
#import "WBApiProxy.h"
#import "AFNetworkReachabilityManager.h"

@interface WBBaseAPIManager ()

/**
 *  是否加载中
 */
@property (nonatomic, assign, readwrite) BOOL isLoading;

/**
 *  闭包
 */
@property (nonatomic, copy) RequestCompletionBlock block;

/**
 *  错误类型
 */
@property (nonatomic, readwrite) WBAPIManagerErrorType errorType;

/**
 *  请求编号集合
 */
@property (nonatomic, strong) NSMutableArray *requestIdList;

@end

@implementation WBBaseAPIManager

- (instancetype)init {
    self = [super init];
    if (self) {
        _delegate = nil;
        _errorType = WBAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(WBAPIManager)]) {
            self.child = (NSObject<WBAPIManager> *)self;
        } else {
            NSAssert(NO, @"The child must be implemented 'WBAPIManager' protocol.");
        }
    }
    return self;
}

- (void)dealloc {
    [self cancelAllRequests];
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(WBURLResponse *)response {
    self.isLoading = NO;

    [self removeRequestIdWithRequestID:response.requestId];
    
    WBCommResponse *commResponse = [[WBCommResponse alloc] initWithData:response.responseData error:nil];
    if (!commResponse) {
        [self failedOnCallingAPI:response withErrorType:WBAPIManagerErrorTypeNoContent];
        return;
        
    } else if ([self.child respondsToSelector:@selector(host)]) {
        commResponse.status = StatusCode_Succeed;
        commResponse.data = response.content;
    }
    
    commResponse.requestId = response.requestId;
    
    self.errorType = WBAPIManagerErrorTypeSuccess;

    // 提示语
    if (self.errorType != WBAPIManagerErrorTypeSuccess) {
        commResponse.message = ResponseErrorHint;
    }

    // 如果派生类需要缓存Response，实现下面的协议
    if ([self.child respondsToSelector:@selector(shouldCacheWithResponse:response:)]) {
        [self.child shouldCacheWithResponse:self.errorType response:commResponse];
        
        // 缓存刷新完毕
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[NSString stringWithFormat:@"%@-Load", NSStringFromClass(self.class)]];
    }
    
    // 把结果通过代理回调给调用者
    if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:response:)]) {
        [self.delegate managerCallAPIDidSuccess:self response:commResponse];
    }
    
    // 把结果通过闭包回调给调用者
    if (self.block) {
        self.block(self.errorType, commResponse);
    }
}

- (void)failedOnCallingAPI:(WBURLResponse *)response withErrorType:(WBAPIManagerErrorType)errorType {
    self.isLoading = NO;
    
    [self removeRequestIdWithRequestID:response.requestId];
    
    WBCommResponse *commResponse = [WBCommResponse new];
    commResponse.requestId = response.requestId;
    
    self.errorType = response.status == WBURLResponseStatusErrorTimeout ? WBAPIManagerErrorTypeTimeout : errorType;
    
    // 提示语
    if (self.errorType == WBAPIManagerErrorTypeNoNetWork) {
        commResponse.message = NoNetworkHint;
    } else if (self.errorType == WBAPIManagerErrorTypeNoContent) {
        commResponse.message = DataErrorHint;
    } else if (self.errorType == WBAPIManagerErrorTypeTimeout) {
        commResponse.message = ResponseErrorHint;
    } else {
        commResponse.message = ServerErrorHint;
    }
    
    // 把结果通过代理回调给调用者
    if ([self.delegate respondsToSelector:@selector(managerCallAPIDidFailed:response:)]) {
        [self.delegate managerCallAPIDidFailed:self response:commResponse];
    }
    
    // 把结果通过闭包回调给调用者
    if (self.block) {
        self.block(self.errorType, commResponse);
    }
}

#pragma mark - publish methods
/**
 *  开始请求
 *
 *  @return 请求编号
 */
- (NSInteger)startRequest {
    NSInteger requestId = 0;
    if ([self isCache]) {
        return requestId;
        
    } else if ([self isReachable]) {
        self.isLoading = YES;
        requestId = [self callApi];
        return requestId;
        
    } else {
        [self failedOnCallingAPI:nil withErrorType:WBAPIManagerErrorTypeNoNetWork];
        return requestId;
    }
    return requestId;
}

/**
 *  开始请求，结果通过闭包回调
 *
 *  @param block 回调闭包
 *
 *  @return 请求编号
 */
- (NSInteger)startWithCompletionBlock:(RequestCompletionBlock)block {
    self.block = block;
    return [self startRequest];
}

/**
 *  只是通知底层可以开始工作了，但具体何时发出请求由子类决定
 *
 *  @param block 回调闭包
 */
- (void)delayStartWithCompletionBlock:(RequestCompletionBlock)block {
    self.block = block;
    if ([self.child respondsToSelector:@selector(startDeal)]) {
        [self.child startDeal];
    }
}

/**
 *  子类直接抛错
 */
- (void)childClassFailedOnCallingAPI {
    WBURLResponse *response = [[WBURLResponse alloc] init];
    [self failedOnCallingAPI:response withErrorType:WBAPIManagerErrorTypeDefault];
}

/**
 *  取消所有请求
 */
- (void)cancelAllRequests {
    [[WBApiProxy sharedApiProxy] cancelRequestWithRequestIDList:self.requestIdList];
    //[self.requestIdList removeAllObjects];
}

/**
 *  取消某个请求
 *
 *  @param requestID 请求编号
 */
- (void)cancelRequestWithRequestId:(NSInteger)requestID {
    [self removeRequestIdWithRequestID:requestID];
    [[WBApiProxy sharedApiProxy] cancelRequestWithRequestID:@(requestID)];
}

/**
 *  把数据转换成具体的实体
 *
 *  @param reformer 需要转换的数据
 *
 *  @return 转换后的实体
 */
- (id)fetchDataWithReformer:(WBCommResponse *)reformer {
    if ([self.child respondsToSelector:@selector(fetchData:)]) {
        return [self.child fetchData:reformer];
    }
    return nil;
}

#pragma mark - private methods
/**
 *  正式发起请求
 *
 *  @return 请求编号
 */
- (NSInteger)callApi {
    
    NSInteger requestId = 0;
    NSString *host = ServiceHost;
    if ([self.child respondsToSelector:@selector(host)]) {
        host = [self.child host];
    }
    
    __weak typeof(self) weakSelf = self;
    switch (self.child.requestType) {
        // GET请求
        case WBAPIManagerRequestTypeGet: {
            requestId = [[WBApiProxy sharedApiProxy] callGETWithParams:self.requestParam host:host methodName:self.child.methodName success:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf successedOnCallingAPI:response];
            } fail:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf failedOnCallingAPI:response withErrorType:WBAPIManagerErrorTypeDefault];
            }];
            break;
        }
        // POST请求
        case WBAPIManagerRequestTypePost: {
            requestId = [[WBApiProxy sharedApiProxy] callPOSTWithParams:self.requestParam host:host methodName:self.child.methodName success:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf successedOnCallingAPI:response];
            } fail:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf failedOnCallingAPI:response withErrorType:WBAPIManagerErrorTypeDefault];
            }];
            break;
        }
        // 上传文件
        case WBAPIManagerRequestTypeMultipartPost: {
            requestId = [[WBApiProxy sharedApiProxy] callMultipartPOSTWithParams:self.requestParam host:host methodName:self.child.methodName files:self.child.uploadFiles success:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf successedOnCallingAPI:response];
            } fail:^(WBURLResponse *response) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [strongSelf failedOnCallingAPI:response withErrorType:WBAPIManagerErrorTypeDefault];
            }];
            break;
        }
            
        default:
            break;
    }
    [self.requestIdList addObject:@(requestId)];
    return requestId;
}

/**
 *  删除某请求
 *
 *  @param requestId 请求编号
 */
- (void)removeRequestIdWithRequestID:(NSInteger)requestId {
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
            break;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

#pragma mark - getters and setters
/**
 *  获取请求编号列表
 */
- (NSMutableArray *)requestIdList {
    if (_requestIdList == nil) {
        self.requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

/**
 *  检测网络是否正常
 */
- (BOOL)isReachable {
    BOOL isReachability;
    if ([AFNetworkReachabilityManager sharedManager].networkReachabilityStatus == AFNetworkReachabilityStatusUnknown) {
        isReachability = YES;
    } else {
        isReachability = [[AFNetworkReachabilityManager sharedManager] isReachable];
    }
    
    if (!isReachability) {
        self.errorType = WBAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

/**
 *  是否正在加载
 */
- (BOOL)isLoading {
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

/**
 *  是否获取缓存中数据
 */
- (BOOL)isCache {
    if ([self.child respondsToSelector:@selector(cacheResponse)]) {
        WBCommResponse *commResponse = [self.child cacheResponse];
        
        if (self.refreshCacheUntilSucceed) {
            // 标记开始刷新缓存
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[NSString stringWithFormat:@"%@-Load", NSStringFromClass([self class])]];
        }
        
        // 确保刷新成功
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@-Load", NSStringFromClass([self class])]]) {
            return NO;
        }
        
        // 有缓存数据，先直接返回
        if (commResponse) {
            self.errorType = WBAPIManagerErrorTypeSuccess;
            // 把结果通过代理回调给调用者
            if ([self.delegate respondsToSelector:@selector(managerCallAPIDidSuccess:response:)]) {
                [self.delegate managerCallAPIDidSuccess:self response:commResponse];
            }
            
            // 把结果通过闭包回调给调用者
            if (self.block) {
                self.block(self.errorType, commResponse);
            }
            
            /*
                1、上层要求刷新缓存
                2、已缓存时长大于最少缓存时间间隔
                满足以上所有条件则进行网络请求
             */
            NSTimeInterval interval = RefreshCacheMinTimeIntervalSeconds;
            if ([self.child respondsToSelector:@selector(refreshCacheMinTimeInterval)]) {
                interval = [self.child refreshCacheMinTimeInterval];
                self.refreshCache = YES;
            }
            return !(self.refreshCache && -[commResponse.cacheTime timeIntervalSinceNow] > interval);
    
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
}
@end
