//
//  WBCacheModel.m
//  WBNetworking
//
//  Created by zwb on 16/6/23.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBCacheModel.h"

@implementation WBCacheModel
- (id)initWithData:(id<NSObject>)data {
    if (data) {
        self = [super init];
        if (self) {
            self.cacheTime = [NSDate date];
            self.data = data;
        }
        return self;
        
    } else {
        return nil;
    }
}
@end
