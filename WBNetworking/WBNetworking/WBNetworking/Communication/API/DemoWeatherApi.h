//
//  DemoWeatherApi.h
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "WBBaseAPIManager.h"
#import "DemoWeatherResults.h"

@interface DemoWeatherApi : WBBaseAPIManager <WBAPIManager>
- (void)paramWithCity:(NSString *)city;
@end
