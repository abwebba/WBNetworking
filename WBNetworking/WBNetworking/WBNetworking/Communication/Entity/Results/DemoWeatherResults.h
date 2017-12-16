//
//  DemoWeatherResults.h
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "WBBaseJSONModel.h"

@protocol ForecastResults <NSObject>
@end

@interface ForecastResults : WBBaseJSONModel
@property (nonatomic, strong) NSString *fengxiang;
@property (nonatomic, strong) NSString *fengli;
@property (nonatomic, strong) NSString *high;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *low;
@property (nonatomic, strong) NSString *date;
@end


@interface DemoWeatherResults : WBBaseJSONModel
@property (nonatomic, strong) NSString *wendu;
@property (nonatomic, strong) NSString *ganmao;
@property (nonatomic, strong) NSArray<ForecastResults> *forecast;
@end

