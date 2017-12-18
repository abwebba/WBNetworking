# WBNetworking

## 基于AFNetworking封装的网络框架 <br>

### 特点：<br>
1、可快速更换其他网络框架。<br>
2、每个接口的业务逻辑都可以方便的做个性化处理。<br>
3、Controller（调用者）销毁了，接口会自动取消请求，节省网络资源。<br>
4、可通过闭包、代理回调请求的数据。<br>
5、轻便、使用简单。<br>
<br>
### ###########集成方法<br>
1、把WBNetworking加到你的项目里。<br>
2、引入AFNetworking。<br>
<br>
### ###########目录结构描述<br>
``` C
├── Configurations          // 配置文件
├── RequestGenerator        // 生产请求类
├── URLResponse             // 组装响应类
├── APIProxy                // 请求管理类
├── BaseAPIManager          // API基础类
├── Kit                     // 存放工具
└── Communication           // 通讯
    ├── Entity
    │ ├── BaseJson          // 基础Json类
    │ ├── Param             // 存放请求实体
    │ └── Results           // 存放响应实体
    └── API                 // 存放接口
```

### ###########基本使用方法<br>
1、创建文件继承 WBAPIManager。<br>
2、遵循 WBAPIManager 协议。<br>
3、实现方法
``` Objective-C
- (NSString *)methodName;
```
``` Objective-C
- (WBAPIManagerRequestType)requestType;
```
4、startRequest 开始请求。<br>
<br>

## 接口例子<br>
``` Objective-C
@interface DemoApi : WBBaseAPIManager <WBAPIManager>

@end
```

``` Objective-C
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
```

## 调用例子<br>
``` Objective-C
@interface ViewController () <WBAPIManagerCallBackDelegate>
@property (nonatomic, strong) DemoWeatherApi *weatherApi;
@end
```

``` Objective-C
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadWeatherApi];
    // [self loadWeatherApiDelegate];
}

// 本例子使用闭包回调数据
- (void)loadWeatherApi {
    self.weatherApi = [DemoWeatherApi new];
    self.weatherApi.refreshCache = YES; // 强制刷新缓存数据
    [self.weatherApi paramWithCity:@"深圳市"];
    
    // 使用闭包回调
    [self.weatherApi startWithCompletionBlock:^(WBAPIManagerErrorType errorType, WBCommResponse *response) {
        if (response.status == StatusCode_Succeed) {
            // 请求正确、数据转成模型
            DemoWeatherResults *data = [self.weatherApi fetchData:response];
            NSLog(@"天气数据：%@", data);
            
        } else {
            // error
            NSLog(@"错误信息：%@", response.message);
        }
    }];
}

// 本例子使用代理回调数据
- (void)loadWeatherApiDelegate {
    self.weatherApi = [DemoWeatherApi new];
    self.weatherApi.delegate = self; 
    [self.weatherApi paramWithCity:@"深圳市"];
    [self.weatherApi startRequest];
}

#pragma mark - WBAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(WBBaseAPIManager *)manager response:(WBCommResponse *)response {
    if ([manager isEqual:self.weatherApi]) {
        DemoLunarResults *data = [self.weatherApi fetchData:response];
        NSLog(@"农历数据：%@", data);
    }
}

- (void)managerCallAPIDidFailed:(WBBaseAPIManager *)manager response:(WBCommResponse *)response {
    if ([manager isEqual:self.weatherApi]) {
        NSLog(@"错误信息：%@", response.message);
    }
}
@end
```
