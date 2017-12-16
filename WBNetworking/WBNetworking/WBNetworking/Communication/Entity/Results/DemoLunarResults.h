//
//  DemoLunarResults.h
//  WBNetworking
//
//  Created by zwb on 2017/12/16.
//  Copyright © 2017年 zwb. All rights reserved.
//

#import "WBBaseJSONModel.h"

@interface DemoLunarResults : WBBaseJSONModel
@property (nonatomic, assign) int year;
@property (nonatomic, assign) int month;
@property (nonatomic, assign) int day;
@property (nonatomic, assign) int lunarYear;
@property (nonatomic, assign) int lunarMonth;
@property (nonatomic, assign) int lunarDay;
@property (nonatomic, strong) NSString *cyclicalYear;
@property (nonatomic, strong) NSString *cyclicalMonth;
@property (nonatomic, strong) NSString *cyclicalDay;
@end
