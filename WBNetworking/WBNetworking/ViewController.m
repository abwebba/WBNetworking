//
//  ViewController.m
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "ViewController.h"

#import "DemoWeatherApi.h"
#import "DemoLunarApi.h"

@interface ViewController () <WBAPIManagerCallBackDelegate>
@property (nonatomic, strong) DemoWeatherApi *weatherApi;
@property (nonatomic, strong) DemoLunarApi *lunarApi;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // [self loadWeatherApi];
    [self loadLunarApi];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWeatherApi {
    // 本例子使用闭包回调数据
    self.weatherApi = [DemoWeatherApi new];
    self.weatherApi.refreshCache = YES; // 强制刷新缓存数据
    [self.weatherApi paramWithCity:@"深圳市"];
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

- (void)loadLunarApi {
    // 本例子使用代理回调数据
    self.lunarApi = [DemoLunarApi new];
    self.lunarApi.delegate = self;
    [self.lunarApi startRequest];
}

#pragma mark - WBAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(WBBaseAPIManager *)manager response:(WBCommResponse *)response {
    if ([manager isEqual:_lunarApi]) {
        DemoLunarResults *data = [self.lunarApi fetchData:response];
        NSLog(@"农历数据：%@", data);
    }
}

- (void)managerCallAPIDidFailed:(WBBaseAPIManager *)manager response:(WBCommResponse *)response {
    if ([manager isEqual:_lunarApi]) {
        NSLog(@"错误信息：%@", response.message);
    }
}
@end
