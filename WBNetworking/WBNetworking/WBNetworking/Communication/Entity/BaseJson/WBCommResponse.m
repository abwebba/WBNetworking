//
//  WBCommResponse.m
//  WBNetworking
//
//  Created by zwb on 16/5/12.
//  Copyright © 2016年 zwb. All rights reserved.
//

#import "WBCommResponse.h"
#import "WBNetworkingConfiguration.h"

@implementation WBCommResponse
- (id)initWithCacheModel:(WBCacheModel *)cache {
    if (cache) {
        self = [super init];
        if (self) {
            self.status = StatusCode_Succeed;
            self.cacheTime = cache.cacheTime;
            self.data = cache.data;
        }
        return self;
        
    } else {
        return nil;
    }
}
@end
