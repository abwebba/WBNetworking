# WBNetworking
网络框架

基于AFNetworking封装的网络框架

特点：

1、可快速更换其他网络框架。

2、每个接口的业务逻辑都可以方便的做个性化处理。

3、Controller（调用者）销毁了，接口会自动取消请求，节省网络资源。

4、可通过闭包、代理回调请求的数据。

5、轻便、使用简单。


一、集成方法

1、把WBNetworking加到你的项目里。

2、引入AFNetworking。


二、基本使用方法

1、创建文件继承 WBAPIManager。

2、实现遵循<WBAPIManager>协议。
  
3、实现方法 

- (NSString *)methodName;

- (WBAPIManagerRequestType)requestType;

4、startRequest 开始请求。


三、例子

@interface DemoApi : WBBaseAPIManager <WBAPIManager>

@end

@implementation DemoWeatherApi\n
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
