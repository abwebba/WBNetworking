# WBNetworking

## 基于AFNetworking封装的网络框架 <br>

### 特点：<br>
1、可快速更换其他网络框架。<br>
2、每个接口的业务逻辑都可以方便的做个性化处理。<br>
3、Controller（调用者）销毁了，接口会自动取消请求，节省网络资源。<br>
4、可通过闭包、代理回调请求的数据。<br>
5、轻便、使用简单。<br>

### ###########集成方法<br>
1、把WBNetworking加到你的项目里。<br>
2、引入AFNetworking。<br>

### ###########目录结构描述<br>
├── Readme.md                   // help<br>
├── app                         // 应用<br>
├── config                      // 配置<br>
│   ├── default.json<br>
│   ├── dev.json                // 开发环境
│   ├── experiment.json         // 实验
│   ├── index.js                // 配置控制
│   ├── local.json              // 本地
│   ├── production.json         // 生产环境
│   └── test.json               // 测试环境
├── data
├── doc                         // 文档
├── environment
├── gulpfile.js
├── locales
├── logger-service.js           // 启动日志配置
├── node_modules
├── package.json
├── app-service.js              // 启动应用配置
├── static                      // web静态资源加载
│   └── initjson
│   	└── config.js 		// 提供给前端的配置
├── test
├── test-service.js
└── tools

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

@implementation DemoWeatherApi

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
